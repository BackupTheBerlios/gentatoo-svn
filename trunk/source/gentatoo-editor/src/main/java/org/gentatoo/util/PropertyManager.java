package org.gentatoo.util;

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

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;

import javax.servlet.ServletContext;

public class PropertyManager {

	/**
	 * Relative path to proprty file
	 */
	private static final String PROPERTY_FILE = "/WEB-INF/classes/META-INF/cocoon/properties/gentatoo.properties";
	
	/**
	 * Home directory for blob cache
	 */
	public static final String BLOB_CACHE_FOLDER = "org.gentatoo.blobCache.homeDir";
	
	/**
	 * instance of Manager
	 */
	private static PropertyManager instance;
	
	/**
	 * Property file
	 */
	private Properties properties;
	
	private PropertyManager(ServletContext context)
	{
		if(context !=null)
		{
			properties = new Properties();
			try {
				properties.load(new FileInputStream(context.getRealPath(PROPERTY_FILE)));
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}	
	}
	
	/**
	 * Method gets a property by is name
	 * @param name
	 * @return
	 */
	public synchronized String getPropertyByName(String name){
		
		return properties.getProperty(name);
	}

	/**
	 * Returns instance of PropertyManager
	 * @return
	 */
	public synchronized static PropertyManager getInstance(ServletContext context) {
		
		if(instance == null)
		{
			instance = new PropertyManager(context);
		}
		return instance;
	}
	
}
