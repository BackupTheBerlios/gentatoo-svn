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
import org.apache.avalon.framework.service.ServiceSelector;
import org.apache.cocoon.components.modules.database.AutoIncrementModule;

public class BinaryCompetentDatabaseAddAction extends DatabaseAddAction{

	/**
     * Fetch all values for all columns that are needed to do the
     * database operation.
     */
    protected Object[][] getColumnValues( Configuration tableConf, CacheHelper queryData,
                                          Map objectModel )
        throws ConfigurationException, ServiceException {

        Object[][] columnValues = new Object[ queryData.columns.length ][];
        for ( int i = 0; i < queryData.columns.length; i++ ){
        	if(this.isColumnTypeLargeObject(queryData,i))
        	{	
        		//ignore blob	
        	}
        	else
        	{
        		columnValues[i] = this.getColumnValue( tableConf, queryData.columns[i], objectModel );
        	}
        	
        	
        }
        return columnValues;
    }
	
	 /**
     * set all necessary ?s and execute the query
     */
    protected int processRow ( Map objectModel, Connection conn, PreparedStatement statement, String outputMode,
                               Configuration table, CacheHelper queryData, Object[][] columnValues,
                               int rowIndex, Map results )
        throws SQLException, ConfigurationException, Exception {

        int currentIndex = 1;
        for (int i = 0; i < queryData.columns.length; i++) {
            Column col = queryData.columns[i];
            if ( col.isAutoIncrement && col.isKey ) {
                currentIndex += setKeyAuto( table, col, currentIndex, rowIndex,
                                            conn, statement, objectModel, outputMode, results );
            } else {
            	if(this.isColumnTypeLargeObject(queryData,i))
            	{	
            		//ignore blob	
            	}
            	else
            	{
            		this.setOutput( objectModel, outputMode, results, table, col.columnConf, rowIndex,
                            columnValues[ i ][ ( col.isSet ? rowIndex : 0 ) ]);
            		this.setColumn( statement, currentIndex, col.columnConf, 
                            columnValues[ i ][ ( col.isSet ? rowIndex : 0 ) ]);
            		currentIndex++;
            	} 
            }
        }
        int rowCount = statement.executeUpdate();
        // get resulting ids for autoincrement columns
        for (int i = 0; i < queryData.columns.length; i++) {
            if ( queryData.columns[i].isAutoIncrement && queryData.columns[i].isKey ) {
                storeKeyValue( table, queryData.columns[i], rowIndex,
                               conn, statement, objectModel, outputMode, results );
            }
        }
        return rowCount;
    }
    
    /**
     * Get the String representation of the PreparedStatement.  This is
     * mapped to the Configuration object itself, so if it doesn't exist,
     * it will be created.
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
                Configuration[] values = table.getChild("values").getChildren("value");
                Configuration[] keys = table.getChild("keys").getChildren("key");

                queryData = new CacheHelper( keys.length, keys.length + values.length );
                fillModes( keys,   true,  defaultModeNames, modeTypes, queryData );
                fillModes( values, false, defaultModeNames, modeTypes, queryData );

                StringBuffer queryBuffer = new StringBuffer("INSERT INTO ");
                StringBuffer valueBuffer = new StringBuffer(") VALUES (");

                queryBuffer.append(table.getAttribute("name"));
                queryBuffer.append(" (");
                int actualColumns = 0;

                for (int i = 0; i < queryData.columns.length; i++) {
                    if ( actualColumns > 0 ) {
                    	if(this.isColumnTypeLargeObject(queryData,i))
                    	{	
                    		//ignore blob	
                    	}
                    	else
                    	{
                        	queryBuffer.append( ", " );
                            valueBuffer.append( ", " );
                    	}
                    }
                    if ( queryData.columns[i].isKey && queryData.columns[i].isAutoIncrement ) {

                        ServiceSelector autoincrSelector = null;
                        AutoIncrementModule autoincr = null;
                        try {
                            autoincrSelector = (ServiceSelector) this.manager.lookup(DATABASE_MODULE_SELECTOR); 
                            if (queryData.columns[i].mode != null && 
                                autoincrSelector != null && 
                                autoincrSelector.isSelectable(queryData.columns[i].mode)){
                                autoincr = (AutoIncrementModule) autoincrSelector.select(queryData.columns[i].mode);
                                
                                if ( autoincr.includeInQuery() ) {
                                    actualColumns++;
                                    queryBuffer.append( queryData.columns[i].columnConf.getAttribute( "name" ) );
                                    if ( autoincr.includeAsValue() ) {
                                        valueBuffer.append( "?" );
                                    } else {
                                        valueBuffer.append(
                                                           autoincr.getSubquery( table, queryData.columns[i].columnConf,
                                                                                 queryData.columns[i].modeConf ) );
                                    }
                                }
                            } else {
                                if (getLogger().isErrorEnabled())
                                    getLogger().error("Could not find mode description " 
                                                      + queryData.columns[i].mode + " for column #"+i);
                                if (getLogger().isDebugEnabled()) {
                                    getLogger().debug("Column data "+queryData.columns[i]);
                                }
                                throw new ConfigurationException("Could not find mode description "+queryData.columns[i].mode+" for column "+i);
                            }
                            
                        } finally {
                            if (autoincrSelector != null) {
                                if (autoincr != null) 
                                    autoincrSelector.release(autoincr);
                                this.manager.release(autoincrSelector);
                            }
                        }

                    } else {
                    	
                    	if(this.isColumnTypeLargeObject(queryData,i))
                    	{	
                    		//ignore blob	
                    	}
                    	else
                    	{
                            actualColumns++;
                            queryBuffer.append( queryData.columns[i].columnConf.getAttribute( "name" ) );
                            valueBuffer.append( "?" );
                    	}
                    }
                }

                valueBuffer.append(")");
                queryBuffer.append(valueBuffer);

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
}
