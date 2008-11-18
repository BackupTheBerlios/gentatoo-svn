package org.gentatoo.transformation;

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

import java.util.HashMap;
import java.util.Map;

import org.apache.avalon.framework.configuration.Configuration;
import org.apache.avalon.framework.configuration.ConfigurationException;
import org.apache.avalon.framework.configuration.SAXConfigurationHandler;
import org.apache.cocoon.acting.ConfigurationHelper;
import org.apache.cocoon.components.source.SourceUtil;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.cocoon.transformation.AbstractSAXTransformer;
import org.apache.excalibur.source.Source;

/**
 * Example for this class was org.apache.cocoon.acting.AbstractComplementaryConfigurableAction 
 * 
 * It allows to create a transformer, which is configurable by a xml descriptor.
 * 
 * @author jhoechstaedter
 *
 */
public class AbstractComplementaryConfigurableSAXTransformer extends AbstractSAXTransformer{

	public static final boolean DESCRIPTOR_RELOADABLE_DEFAULT = true;
	
	private static Map configurations = new HashMap();
	
    /**
     * Set up the complementary configuration file.  Please note that
     * multiple Transformers can share the same configurations.  By using
     * this approach, we can limit the number of config files.
     * Also note that the configuration file does not have to be a file.
     */
    protected Configuration getConfiguration(String descriptor, SourceResolver resolver, boolean reloadable) throws ConfigurationException {
        
    	ConfigurationHelper conf = null;

        if (descriptor == null) {
        	
            throw new ConfigurationException("The form descriptor is not set!");
            
        }

        synchronized (AbstractComplementaryConfigurableSAXTransformer.configurations) { 
        	
        	Source resource = null;
            
        	try {  
            	resource = resolver.resolveURI(descriptor);
                conf = (ConfigurationHelper) AbstractComplementaryConfigurableSAXTransformer.configurations.get(resource.getURI());
                
                if (conf == null || (reloadable && conf.lastModified != resource.getLastModified())) { 
                	
                	if(getLogger().isDebugEnabled())
                	{
                    	getLogger().debug("(Re)Loading " + descriptor);
                	}
                	
                    if (conf == null) {	
                        conf = new ConfigurationHelper();   
                    }
                    
                    SAXConfigurationHandler builder = new SAXConfigurationHandler();

					 /* TODO: replace the following deprecated method. Maybe by the following code snippet:                  
					  * 
					  * SAXParser parser = (org.apache.excalibur.xml.sax.SAXParser) manager.lookup(org.apache.excalibur.xml.sax.SAXParser.ROLE);
					  * parser.parse(SourceUtil.getInputSource(resource), builder);
					  */
                    
                    SourceUtil.parse(this.manager,resource,builder);
                    conf.lastModified = resource.getLastModified(); 
                    conf.configuration = builder.getConfiguration();
                    
                    AbstractComplementaryConfigurableSAXTransformer.configurations.put(resource.getURI(), conf);
                    
                } else {
                	
                	if(getLogger().isDebugEnabled())
                	{
                		getLogger().debug("Using cached configuration for " + descriptor);
                	}
                }
            } catch (Exception e) {
            	
            	if(getLogger().isErrorEnabled())
            	{
            		getLogger().error("Could not configure Database mapping environment", e);
            	}
                
                throw new ConfigurationException("Error trying to load configurations for resource: "
                    + (resource == null ? "null" : resource.getURI()) + e.getMessage());
                
            } finally {
                resolver.release(resource);
            }  
        }
        return conf.configuration;
    }
}
