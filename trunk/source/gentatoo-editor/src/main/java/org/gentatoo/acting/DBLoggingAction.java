package org.gentatoo.acting;

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
 
import java.util.Enumeration;
import java.util.Map;

import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.acting.AbstractAction;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.cocoon.environment.http.HttpRequest;
import org.apache.cocoon.servlet.multipart.PartOnDisk;
import org.apache.log4j.Logger;
import org.gentatoo.log4j.DBActionLogLevel;

/**
 * Own logging action, which can be called directly from the sitemap.
 * 
 * @author jhoechstaedter
 *
 */
public class DBLoggingAction extends AbstractAction{

	/**
	 * Action handler. 
	 * Fires a Log Event for DBACTION, evaluates the parameter 
	 * named "message" and the query String of the HttpRequest,
	 * and appends the values to the log message.
	 * 
	 */
	public Map act(Redirector arg0, SourceResolver arg1, Map map, String arg3, Parameters parameters) throws Exception {

		HttpRequest request = (HttpRequest)map.get("request");
		StringBuffer bMessage = new StringBuffer(parameters.getParameter("message"));
		
		bMessage.append(" by user: " + request.getRemoteUser());
		
		Enumeration eParameterNames = request.getParameterNames();
		
		while(eParameterNames.hasMoreElements())
		{
			String parameterName = (String)eParameterNames.nextElement();
			String parameterValue = "unknown";
			
			if(request.get(parameterName) instanceof PartOnDisk)
			{
				PartOnDisk filePart = (PartOnDisk)request.get(parameterName);
				parameterValue = filePart.getFileName();	
			}
			else
			{
				parameterValue = request.getParameter(parameterName);
			}
			
			bMessage.append(" / "+ parameterName +": "+ parameterValue); 	
		}
		
		Logger mylogger = Logger.getLogger(DBActionLogLevel.class);
		mylogger.log(DBActionLogLevel.DBACTION, bMessage.toString());
		
		return null;
	}
}
