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

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import org.gentatoo.util.BlobCacheManager;

/**
 * Listener which listens to the HttpSessionEvents of the sessions.
 * 
 * @author jhoechstaedter
 *
 */
public class HttpSessionListenerImpl implements HttpSessionListener{
	
	/**
	 * Is called, when the session is created.
	 * 
	 * Has no functionality here.
	 * 
	 */
	public void sessionCreated(HttpSessionEvent sessionEvent){

	}

	/**
	 * Is called when the sesion is destroyed.
	 * 
	 * Forces clearing the cache folder for large objects for current session.
	 * 
	 */
	public void sessionDestroyed(HttpSessionEvent sessionEvent){
		
		HttpSession session = sessionEvent.getSession();
		BlobCacheManager.getInstance(session.getServletContext()).deleteCacheFolder(session.getId());	
	}
		
}
