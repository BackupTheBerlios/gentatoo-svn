<?xml version="1.0"?>

<!--
  Copyright 2008 memoComp, www.memocomp.de
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
  http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
 -->

<!-- this stylesheet formats the output for the confirmation screen -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sql="http://apache.org/cocoon/SQL/2.0"
                xmlns:xi="http://www.w3.org/2001/XInclude">

	<!-- 
	PARAMETERS
	
	from sitemap 
	--> 
	
	<!-- path to the descriptor file of table -->
	<xsl:param name="pathToDescriptor" />
	
	<!-- path to external resources ("/resource/external" for example) --> 
	<xsl:param name="pathToExternalResources" />
	
	<!-- root url of application -->
	<xsl:param name="rootURL" />
	
	<!-- protocol pattern for internal requests -->
	<xsl:param name="cocoonProtocol" />
	
	<!-- name of table which is displayed -->
	<xsl:param name="tableName" />
		
	<!-- name of datasource of table -->
	<xsl:param name="nameOfDatasource" />
	
	<!-- query string from request -->
	<xsl:param name="queryString" />
	
	<!-- root url of application -->
	<xsl:param name="urlPattern" />
	
	<!-- sub path to css from pathToExternalResources -->
	<xsl:param name="css" />
	
	<!-- root url of application -->
	<xsl:param name="actionName" />
	
	<!-- cache folder -->
	<xsl:param name="pathToLargeObjectCache" />
	
	<!-- 
	VARIABLES
	
	constant values
	--> 
	<xsl:variable name="READ_WRITE" select="'rw'"/>
	
	<xsl:variable name="READ_ONLY" select="'r'"/>
	
	<xsl:variable name="HIDDEN" select="'h'"/>
	
	<xsl:variable name="BLOB_TYPE_IMAGE" select="'image'"/>
	
	<xsl:variable name="BLOB_TYPE_BINARY" select="'binary'"/>
			
	<xsl:variable name="NO_VALUE" select="'No Value'"/>
		
	<!--
	TEMPLATE for page
	
	creates title, header and body
	-->
	<xsl:template match="/page">
	
		<xsl:variable name="sqlError"><xsl:value-of select="content/sql:rowset/sql:error" /></xsl:variable>
	
		<xsl:choose>
			<xsl:when test="$sqlError != ''">
				<xi:include href="{$cocoonProtocol}/exception?msg={$sqlError}" />
			</xsl:when>
			<xsl:otherwise>
				<html>
					<head>
						<title>${pom.name} - ${pom.version}</title>
						<link rel="SHORTCUT ICON" href="{$pathToExternalResources}/images/favicon.ico" />
			  	  		<link rel="stylesheet" type="text/css" href="{$pathToExternalResources}/{$css}" />		
					</head>
					<body>
						<div id="wrapper2">
							<h1>Confirmation</h1>     			
				      		<p>Really <xsl:value-of select="$actionName" />?</p>
				      			
							<!-- apply child tags -->
				      		<xsl:apply-templates/>
			
							<p><a href="{$rootURL}/process/{$urlPattern}?{$queryString}">Yes</a></p>
							<p><a href="{$rootURL}/display/{$urlPattern}">No</a></p>	
			   			</div>	
					</body>
				</html>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
    
   <!-- 
	TEMPLATE sql:rowset
	
	creates table for data which should be deleted
	 -->
	<xsl:template match="sql:rowset">
						
		<table>
			<tr>
			
			<!-- column headers with alias -->	
			<xsl:for-each select="document($pathToDescriptor)/root/table/keys/key[@access=$READ_ONLY]">
	  			 	<xsl:variable name="keyAliasR"><xsl:value-of select="@alias" /></xsl:variable>	
	  				<th>
	      				<xsl:value-of select="$keyAliasR" />
	      			</th>
	        </xsl:for-each>
			
			<!-- loop all columns, because order of column depends on order in descriptor
			and is independend of the access mode-->
			<xsl:for-each select="document($pathToDescriptor)/root/table/values/value[@access]">
	  			 	<xsl:variable name="valueAliasRRW"><xsl:value-of select="@alias" /></xsl:variable>					
	  				<th>
						<xsl:value-of select="$valueAliasRRW" />    			
	      			</th>
	        </xsl:for-each>
	        
	        </tr>
			
			<!-- apply child tags -->
			<xsl:apply-templates/>
				
		</table>
			
	</xsl:template>
	
	
	<!-- 
	TEMPLATE sql:row
	
	prints out the values for each row
	--> 
	<xsl:template match="sql:row">
	
		<tr>
				<!-- style column values -->
	 			<xsl:for-each select="*">	
					<xsl:variable name="nameOfCurrentNode"><xsl:value-of select="name()" /></xsl:variable>
					<xsl:variable name="valueOfCurrentNode"><xsl:value-of select="current()" /></xsl:variable>
	
					<!-- print out keys as plain text whichdon't have the attribute access = HIDDEN -->
					<xsl:for-each select="document($pathToDescriptor)/root/table/keys/key[@access=$READ_ONLY]">
	  			 		<xsl:variable name="keyNameR"><xsl:value-of select="@name" /></xsl:variable>
	                	<xsl:if test="concat('sql:', normalize-space($keyNameR))=$nameOfCurrentNode">
	  						<td>
	      						<xsl:value-of select="$valueOfCurrentNode" />
	      					</td>
	      				</xsl:if>
	           		</xsl:for-each>
	
					<!-- print out value columns as plain text -->
					<xsl:for-each select="document($pathToDescriptor)/root/table/values/value[@access]">
	  			 		<xsl:variable name="valueNameRW"><xsl:value-of select="@name" /></xsl:variable>
	                	<xsl:if test="concat('sql:', normalize-space($valueNameRW))=$nameOfCurrentNode">
	  						<td>
	  							<xsl:choose>
									<xsl:when test="string-length(@select) > 0">
										<xsl:variable name="fkName" select="concat('gtt_fkey', substring-before(substring-after(@select, 'gtt_fkey'), ','))" />
	  									<xi:include href="{$cocoonProtocol}/fkAliasControl/{$nameOfDatasource}/{$tableName}/{$valueNameRW}/Text/{$valueOfCurrentNode}/{$fkName}" />
	  								</xsl:when>
	  								
	  								<xsl:when test="normalize-space(@type) = $BLOB_TYPE_IMAGE">
	  									<xsl:choose>
	  										<xsl:when test="$valueOfCurrentNode = $NO_VALUE">
	  											<xsl:value-of select="$NO_VALUE" />
	  										</xsl:when>	
	  										<xsl:otherwise>
	  											<img src="{$pathToLargeObjectCache}/{$valueOfCurrentNode}" />
	  										</xsl:otherwise>
	  									</xsl:choose>
									</xsl:when>
	  								
							  		<xsl:when test="normalize-space(@type) = $BLOB_TYPE_BINARY">
	  									<xsl:choose>
	  										<xsl:when test="$valueOfCurrentNode = $NO_VALUE">
	  											<xsl:value-of select="$NO_VALUE" />
	  										</xsl:when>	
	  										<xsl:otherwise>
	  											<a href="{$pathToLargeObjectCache}/{$valueOfCurrentNode}" >Object</a>
	  										</xsl:otherwise>
	  									</xsl:choose>							  														
							  		</xsl:when>
	  							
	  								<xsl:otherwise>
	  									<xsl:value-of select="$valueOfCurrentNode" />
	  								</xsl:otherwise>
	  							</xsl:choose>
	      					</td>
	      				</xsl:if>
	           		</xsl:for-each>
	           
	    		</xsl:for-each >
		</tr>
	
	</xsl:template>
                    
</xsl:stylesheet>
