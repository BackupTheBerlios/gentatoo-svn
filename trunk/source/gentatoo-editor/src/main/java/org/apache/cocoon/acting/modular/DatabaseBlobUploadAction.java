package org.apache.cocoon.acting.modular;

/*
 * Copyright 2008 memoComp, www.memocomp.de
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import org.apache.avalon.excalibur.datasource.DataSourceComponent;
import org.apache.avalon.framework.configuration.Configuration;
import org.apache.avalon.framework.configuration.ConfigurationException;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.avalon.framework.service.ServiceException;
import org.apache.cocoon.acting.modular.DatabaseAction;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.cocoon.servlet.multipart.Part;
import org.apache.cocoon.servlet.multipart.PartOnDisk;

/**
 * Action which uploads a blob from a multi parted HttpRequest into a database.
 * 
 * This action is configured like any other DatabaseAction from Cocoon:
 * 
 * Datasource is given by sitemap parameter "connection". Further the table decsriptor is needed,
 * given by the sitemap parameter "descriptor". All other parameters are fetched from the request.
 * 
 * @author jhoechstaedter
 *
 */
public class DatabaseBlobUploadAction extends DatabaseAction{
	
	DataSourceComponent datasource = null;
	
	Request request = null;
	
	/**
	 * Method is called on activity
	 */
	public Map act(Redirector arg0, SourceResolver resolver, Map objectModel, String arg3, Parameters parameters) throws Exception {
		
		try{
			Configuration conf = this.getConfiguration(parameters.getParameter("descriptor", (String) this.settings.get("descriptor")),
					resolver,true);
			
			request = (Request)ObjectModelHelper.getRequest(objectModel);
			
			datasource = this.getDataSource(conf, parameters);
			
			Part filePart = (Part) request.get(request.getParameter("blobColumn"));
			File file = ((PartOnDisk)filePart).getFile();
			
			this.writeFileToDatabase(this.getQueryString(conf), file);
		}
		catch(Exception e){
			return null;	
		}
		return new HashMap();
	}
	
	/**
	 * writes a file to the db, accorinng to the current datasource
	 * @param query
	 * @param file
	 * @throws SQLException
	 * @throws IOException
	 */
	public void writeFileToDatabase(StringBuffer query, File file) throws SQLException, IOException
	{
		FileInputStream fis = null;
	    PreparedStatement ps = null;
		Connection conn = null;
		    
		try {
			conn = datasource.getConnection();
			conn.setAutoCommit(false);

		    fis = new FileInputStream(file);
		      
		    ps = conn.prepareStatement(query.toString()); 
		    ps.setBinaryStream(1, fis, (int) file.length()); 
		    ps.executeUpdate();
		      
		    conn.commit();
		}
		finally
		{
		      ps.close(); 
		      fis.close();
		}    
		
	}
	
	/**
	 * Method returns the query as String which is needed to upload the blob
	 * @param conf
	 * @return
	 * @throws ConfigurationException
	 */
	public StringBuffer getQueryString(Configuration conf) throws ConfigurationException
	{
		Configuration table = conf.getChild("table");

		String tableName;
		tableName = table.getAttribute("name");

		Configuration[] keys = table.getChild("keys").getChildren("key");
		Configuration[] values = table.getChild("values").getChildren("value");
		
        StringBuffer queryBuffer = new StringBuffer("UPDATE ");
        queryBuffer.append(tableName + " SET ");
        queryBuffer.append(request.getParameter("blobColumn")+" = ? ");
        queryBuffer.append("WHERE ");
        
        for(int i = 0; i < keys.length; i++)
        {
        	String paramValue = request.getParameter(tableName + "." + keys[i].getAttribute("name"));

        	if(paramValue != null)
        	{	
        		queryBuffer.append(tableName +  "." + keys[i].getAttribute("name")+" = " + paramValue + ", ");
        	}	
        }
        
        queryBuffer.setLength(queryBuffer.length() - 2);
		
		return queryBuffer;	
	}

	protected int processRow(Map arg0, Connection arg1, PreparedStatement arg2, String arg3, Configuration arg4, CacheHelper arg5, Object[][] arg6, int arg7, Map arg8) throws SQLException, ConfigurationException, Exception {
		// TODO Auto-generated method stub
		return 0;
	}

	protected String selectMode(boolean arg0, Map arg1) {
		// TODO Auto-generated method stub
		return null;
	}

	protected boolean honourAutoIncrement() {
		// TODO Auto-generated method stub
		return false;
	}

	Object[][] getColumnValues(Configuration arg0, CacheHelper arg1, Map arg2) throws ConfigurationException, ServiceException {
		// TODO Auto-generated method stub
		return null;
	}

	protected CacheHelper getQuery(Configuration arg0, Map arg1, Map arg2) throws ConfigurationException, ServiceException {
		// TODO Auto-generated method stub
		return null;
	}

}
