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

import java.util.Map;

import org.apache.avalon.framework.configuration.Configuration;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.acting.AbstractComplementaryConfigurableAction;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.cocoon.environment.http.HttpRequest;

/**
 * This class checks, if the current user has the right permissions depending on the user roles
 * to access the selected table. If not, the value null is returned by method act.
 * 
 * The selected table is defined by the table descriptor.
 * 
 * <table>
 * <tr><td colspan="2">Configuration options (setup and per invocation):</td></tr>
 * <tr><td>descriptor       </td><td>xml file containing database/table description</td></tr>
 * </table>
 * 
 * @author jhoechstaedter
 *
 */
public class CheckTableAccessAction extends AbstractComplementaryConfigurableAction{

	/**
	 * Method is called on invocation of action.
	 * 
	 * Returns null if user from HttpRequest has no permissions according to the defined roles in the descriptor.
	 */
	public Map act(Redirector arg0, SourceResolver resolver, Map map, String arg3, Parameters parameters) throws Exception {
		
		try{
		
			HttpRequest request = (HttpRequest)map.get("request");
			String userPrincipal = request.getUserPrincipal().toString();
			String rolesFromUserPrincipal = userPrincipal.substring(userPrincipal.lastIndexOf("roles=") + 7, userPrincipal.length() - 3);
			
			Configuration conf = this.getConfiguration(parameters.getParameter("descriptor", (String) this.settings.get("descriptor")),
					resolver,true);
			Configuration rolesConf = conf.getChild("roles");
			Configuration[] roles = null;
			
			if(rolesConf != null)
			{
				roles = rolesConf.getChildren("role");
				for(int i = 0; i < roles.length; i++)
				{
					if(rolesFromUserPrincipal.indexOf(roles[i].getValue()) > -1)
					{
						return map;
					}
				}
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return null;
	}

}
