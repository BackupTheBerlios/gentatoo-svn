package org.gentatoo.log4j;

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

import org.apache.log4j.Level;

/**
 * Class for custom log level "DBACTION"
 * 
 * @author jhoechstaedter
 *
 */
public class DBActionLogLevel extends Level{

	  /**  
	   * Value of log level. 
	   */   
	  public static final int DBACTION_INT = FATAL_INT + 10;   
	    
	  /**  
	   * {@link Level} representing the log level  
	   */   
	  public static final Level DBACTION = new DBActionLogLevel(DBACTION_INT,"DBACTION",7);  
	   
	      /** 
	        * Constructor 
	         * 
	        * @param arg0 
	        * @param arg1 
	        * @param arg2 
	         */  
	      protected DBActionLogLevel(int arg0, String arg1, int arg2){ 
	          super(arg0, arg1, arg2);  
	      }  
	   
	      /** 
	       * Checks whether sArg is "DBACTION" level. If yes then returns  
	       * {@link DBActionLogLevel#DBACTION}, else calls  
	       * {@link DBActionLogLevel#toLevel(String, Level)} passing it  
	       * {@link Level#DEBUG} as the defaultLevel. 
	        * 
	        * @see Level#toLevel(java.lang.String) 
	        * @see Level#toLevel(java.lang.String, org.apache.log4j.Level) 
	        * 
	        */  
	      public static Level toLevel(String sArg){ 
	          
	    	  if (sArg != null && sArg.toUpperCase().equals("DBACTION")) {  
	              return DBACTION;   
	          }  
	          return (Level) toLevel(sArg, Level.DEBUG);   
	      }  
	   
	      /** 
	       * Checks whether val is {@link DBActionLogLevel#DBACTION_INT}.  
	       * If yes then returns {@link DBActionLogLevel#DBACTION}, else calls  
	       * {@link DBActionLogLevel#toLevel(int, Level)} passing it {@link Level#DEBUG} 
	       * as the defaultLevel 
	       * 
	        * @see Level#toLevel(int) 
	        * @see Level#toLevel(int, org.apache.log4j.Level) 
	        * 
	        */  
	      public static Level toLevel(int val) { 
	    	  
	          if (val == DBACTION_INT) {  
	              return DBACTION;    
	          }  
	          return (Level) toLevel(val, Level.DEBUG);           
	      }  
	   
	      /** 
	       * Checks whether val is {@link DBActionLogLevel#DBACTION_INT}.  
	       * If yes then returns {@link DBActionLogLevel#DBACTION}, 
	       * else calls {@link Level#toLevel(int, org.apache.log4j.Level)} 
	       * 
	       * @see Level#toLevel(int, org.apache.log4j.Level) 
	       */  
	      public static Level toLevel(int val, Level defaultLevel) { 
	    	  
	          if (val == DBACTION_INT) {   
	              return DBACTION;     
	          } 
	          return Level.toLevel(val, defaultLevel);    
	      }  
	   
	      /** 
	       * Checks whether sArg is "DBACTION" level.  
	       * If yes then returns {@link DBActionLogLevel#DBACTION}, else calls 
	   		* {@link Level#toLevel(java.lang.String, org.apache.log4j.Level)} 
	   		* 
	   		* @see Level#toLevel(java.lang.String, org.apache.log4j.Level) 
	   		*/  
	      public static Level toLevel(String sArg, Level defaultLevel) { 
     
	         if(sArg != null && sArg.toUpperCase().equals("DBACTION")) {  
	             return DBACTION;  
	         }  
	         return Level.toLevel(sArg,defaultLevel);   
	      } 
}
