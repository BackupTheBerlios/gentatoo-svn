package org.gentatoo.servlet;

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

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.http.HttpSession;

import org.gentatoo.util.BlobCacheManager;

/**
 * Implementation of ServletContextListener.
 * 
 * Clears cache folder on initialisation of servlet context and when the 
 * servlet comtext gets destroyed.
 * @author jhoechstaedter
 *
 */
public class ServletContextListenerImpl implements ServletContextListener{

	/**
	 * Method is calle on initialisation of servelt context.
	 * 
	 */
	public void contextInitialized(ServletContextEvent contextEvent) {
		
		//deleting blob cache folder should not be necessary here
		//BlobCacheManager.getInstance(contextEvent.getServletContext()).deleteWholeCacheFolder();
	}

	/**
	 * Method is called when servlet context gets destroyed.
	 * 
	 * Deletes whole blob cache folder.
	 */
	public void contextDestroyed(ServletContextEvent contextEvent) {
		
		BlobCacheManager.getInstance(contextEvent.getServletContext()).deleteWholeCacheFolder();
	}

}
