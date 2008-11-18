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

<!-- this stylesheet formats the result of the directory generator-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dir="http://apache.org/cocoon/directory/2.0">
	
	<!-- 
	PARAMETERS
	
	from sitemap 
	--> 
	<!-- path to external resources ("/resource/external" for example) -->
	<xsl:param name="pathToExternalResources" />
	
	<!-- root url of application -->
	<xsl:param name="rootURL" />	
	
	<!-- url pattern which executes sql statement -->
	<xsl:param name="runsqlPattern" />
	
	<!-- sub path to css from pathToExternalResources -->
	<xsl:param name="css" />
	
	<!-- home dir of descriptor files -->
	<xsl:param name="descriptorHomeDir"/>
	
	<!-- default rows per page from property file -->
	<xsl:param name="defaultRowsPerPage"/>
	
	<!-- user principal from request -->
	<xsl:param name="userPrincipal"/>
	
	<!--
	TEMPLATE for /
	
	adds enclosing body and div tags
	-->
	<xsl:template match="/">	
		
		<html>
			<head>
				<title>${pom.name} - ${pom.version}</title>
				<link rel="SHORTCUT ICON" href="{$pathToExternalResources}/images/favicon.ico" />
	  	  		<link rel="stylesheet" type="text/css" href="{$pathToExternalResources}/{$css}" />		
			</head>
			<body>
				<div id="wrapper1">
					<h1>${pom.name} Index</h1>
					
					<!-- apply child tags -->
	      			<xsl:apply-templates />
	      			
	      		</div>   	
			</body>
		</html>

	</xsl:template>
    
    <!--
	TEMPLATE for dir:directory
	
	adds enclosing ul tag for files
	-->
    <xsl:template match="dir:directory">
    	
    	<ul>
			<xsl:for-each select="*">
					<div id="directory">
											
						<!-- apply child tags -->
						<xsl:apply-templates />
					
					</div>
			</xsl:for-each>
		</ul>
    	   
    </xsl:template>
    
    <!--
	TEMPLATE for dir:file
	
	adds a link and li element for each xml file
	fetchs row count from the descriptor file if given
	checks for user roles
	-->
    <xsl:template match="dir:file">
    	
    	<!-- table name from file name -->
    	<xsl:variable name="tableName"><xsl:value-of select="substring-before(@name,'.xml')" /></xsl:variable>
    	<!-- user roles from request -->
    	<xsl:variable name="userRolesWithoutBefore" select="substring-after($userPrincipal,'roles=')" />
    	
    	<xsl:variable name="userRoles" select="substring($userRolesWithoutBefore,2,string-length($userRolesWithoutBefore)-4)" />
    	
    	<!-- filename ok? (xml file) -->
    	<xsl:if test="string-length($tableName) > 0">
    		<!-- name of datasource from name of parent directory -->
	    	<xsl:variable name="nameOfDatasource"><xsl:value-of select="../@name" /></xsl:variable>
	    	<!-- full path to table descriptor -->
	    	<xsl:variable name="pathToDescriptor"><xsl:value-of select="concat($descriptorHomeDir, '/', $nameOfDatasource, '/', @name)" /></xsl:variable>
	    	
	    	<!-- check for role matches -->
	    	<xsl:variable name="roleMatches">
		    	<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/roles/role">
	    			<xsl:if test="contains($userRoles,current())">x</xsl:if>
	    		</xsl:for-each>
	    	</xsl:variable>
	    	
	    	<!-- row count from table descriptor -->
	    	<xsl:variable name="rowsPerPage"><xsl:value-of select="document(concat('resource://',$pathToDescriptor))/root/rows-per-page" /></xsl:variable>
    		
    		<!-- display link to table if role is set -->
    		<xsl:if test="string-length($roleMatches) > 0">
	    		<xsl:choose>								   			
					<xsl:when test="$rowsPerPage = ''">	
						<xsl:variable name="tableURL1"><xsl:value-of select="concat($rootURL, '/', $runsqlPattern, '/', $nameOfDatasource, '/', $tableName)" /></xsl:variable>
						<li>
	    					<a href="{$tableURL1}"><xsl:value-of select="concat($nameOfDatasource, '/', $tableName)" /></a>
	    				</li>													   				
					</xsl:when>									   			
					<xsl:otherwise>
	    				<xsl:variable name="tableURL2"><xsl:value-of select="concat($rootURL, '/', $runsqlPattern, '/', $nameOfDatasource, '/', $tableName, '/', $rowsPerPage)" /></xsl:variable>
						<li>
	    					<a href="{$tableURL2}"><xsl:value-of select="concat($nameOfDatasource, '/', $tableName)" /></a>
	    				</li>
					</xsl:otherwise>
				</xsl:choose>
    		</xsl:if>
    	
    	</xsl:if>    	
    	
    </xsl:template>
           
</xsl:stylesheet>
