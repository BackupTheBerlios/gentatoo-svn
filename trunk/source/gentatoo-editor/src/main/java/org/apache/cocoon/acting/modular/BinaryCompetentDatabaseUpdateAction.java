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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;

import org.apache.avalon.framework.configuration.Configuration;
import org.apache.avalon.framework.configuration.ConfigurationException;
import org.apache.avalon.framework.service.ServiceException;
import org.apache.cocoon.acting.modular.DatabaseUpdateAction;

/**
 * Updates a record in a database. The action can update one or more
 * tables, and can update more than one row to a table at a time.
 *
 */
public class BinaryCompetentDatabaseUpdateAction extends DatabaseUpdateAction {

	 /**
     * Get the String representation of the PreparedStatement.  This is
     * mapped to the Configuration object itself, so if it doesn't exist,
     * it will be created.
     *
     * @param table the table's configuration object
     * @return the insert query as a string
     */
    protected CacheHelper getQuery( Configuration table, Map modeTypes, Map defaultModeNames )
        throws ConfigurationException, ServiceException {

        LookUpKey lookUpKey = new LookUpKey( table, modeTypes );
        CacheHelper queryData = null;
        synchronized( this.cachedQueryData ) {
            queryData = (CacheHelper) this.cachedQueryData.get( lookUpKey );
            if (queryData == null) {
                Configuration[] keys = table.getChild("keys").getChildren("key");
                Configuration[] values = table.getChild("values").getChildren("value");

                queryData = new CacheHelper( keys.length, keys.length + values.length );
                fillModes( keys,   true,  defaultModeNames, modeTypes, queryData );
                fillModes( values, false, defaultModeNames, modeTypes, queryData );

                StringBuffer queryBuffer = new StringBuffer("UPDATE ");
                queryBuffer.append(table.getAttribute("name"));

                if (values.length > 0){
                	
                	queryBuffer.append(" SET ");
                    int cols = 0;
                    for (int i = 0; i < queryData.columns.length; i++) {
                        if ( !queryData.columns[i].isKey ) {
                            
                        	if(this.isColumnTypeLargeObject(queryData,i))
                        	{
                        		//System.out.println("blob ignored / create query");
                        		//handle blob should not be necessary here
                        		
                        	}
                        	else
                        	{
                        		
                        		if ( cols > 0 ) {
                                    queryBuffer.append(", ");
                                }   
                                cols++;
                                queryBuffer
                                    .append( queryData.columns[i].columnConf.getAttribute( "name" ) )
                                    .append( "= ?" );
                        		
                        	}
                        	
                        }
                    }
                }
                
                queryBuffer.append(" WHERE ");
                for (int i = 0; i < queryData.columns.length; i++) {
                    if ( queryData.columns[i].isKey ) {
                        if ( i > 0 ) {
                            queryBuffer.append(" AND ");
                        }
                        queryBuffer
                            .append( queryData.columns[i].columnConf.getAttribute( "name" ) )
                            .append( "= ?" );
                    }
                }

                queryData.queryString = queryBuffer.toString();

                this.cachedQueryData.put( lookUpKey, queryData );
            }
        }
        
        return queryData;
    }

    /**
     * Figures out, if column with given index contains large object.
     * 
     * @param queryData
     * @param columnIndex
     * @return
     * @throws ConfigurationException
     */
    private boolean isColumnTypeLargeObject(CacheHelper queryData, int columnIndex) throws ConfigurationException{
    	
    	Column col = queryData.columns[columnIndex];
    	
    	String colType = col.columnConf.getAttribute("type");
    	
    	return this.isLargeObject(colType);
    	
    }

    /**
     * set all necessaries and execute the query
     */
    protected int processRow ( Map objectModel, Connection conn, PreparedStatement statement, String outputMode,
                               Configuration table, CacheHelper queryData, Object[][] columnValues, 
                               int rowIndex, Map results )
        throws SQLException, ConfigurationException, Exception {


        int currentIndex = 1;

        // ordering is different for UPDATE than for INSERT: values, keys
        for (int i = 0; i < queryData.columns.length; i++) {
            Column col = queryData.columns[i];
            
            if ( !col.isKey ) {
                
            	if(this.isColumnTypeLargeObject(queryData,i))
            	{
            		//System.out.println("blob ignored / create query");
            		//TODO: handle blob
            		
            	}
            	else
            	{
            		
            		this.setColumn( objectModel, outputMode, results, table, col.columnConf, rowIndex,
                            columnValues[ i ][ ( col.isSet ? rowIndex : 0 ) ], statement, currentIndex );
            		currentIndex++;
            		
            	}
            	
            }
        }
        for (int i = 0; i < queryData.columns.length; i++) {
            Column col = queryData.columns[i];
            if ( col.isKey ) {
                this.setColumn( objectModel, outputMode, results, table, col.columnConf, rowIndex,
                                columnValues[ i ][ ( col.isSet ? rowIndex : 0 ) ], statement, currentIndex );
                currentIndex++;
            }
        }
        int rowCount = statement.executeUpdate();
        return rowCount;
    }

}
