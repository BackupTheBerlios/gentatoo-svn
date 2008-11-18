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

<!-- this stylesheet formats the output for the login screen -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xi="http://www.w3.org/2001/XInclude">

	<!-- 
	PARAMETERS
	
	from sitemap 
	--> 
	<!-- path to external resources ("/resource/external" for example) -->
	<xsl:param name="pathToExternalResources" />
		
	<!-- root url of application -->
	<xsl:param name="rootURL" />
	
	<!-- sub path to css from pathToExternalResources -->
	<xsl:param name="css" />
		
	<!--
	TEMPLATE for page
	
	creates title, header and body
	-->
	<xsl:template match="page">
	
		<html>
			<head>
				<title>${pom.name} - ${pom.version}</title>
				<link rel="SHORTCUT ICON" href="{$pathToExternalResources}/images/favicon.ico" />
				<link rel="stylesheet" type="text/css" href="{$pathToExternalResources}/{$css}" /> 		
			</head>
			<body>
				<div id="wrapper1">
					<h1>${pom.name} Login</h1>
				
					<!-- apply child tags -->
	      			<xsl:apply-templates/>
	      			
	      		</div>   	
			</body>
		</html>
	
	</xsl:template>
	
	
	<!--
	TEMPLATE for content
	
	adds login form
	-->
	<xsl:template match="content">	

			<form method="POST" action="{$rootURL}/j_security_check">
				<table border="0" width="100%">		
					<tr>
						<td> Username: </td> 
						<td> 
							<input type="text" name="j_username" class="text"/>
						</td>
					</tr>
					<tr>	
						<td> Password: </td> 
						<td> 
							<input type="password" name="j_password" class="text"/>
						</td>
					</tr>
					<tr>
						<td>
							<input type="submit" value="Login" class="button"/>
						</td>
						<td>
							<input type="reset" value="Reset" class="button"/>
						</td>
					</tr>
				</table>
			</form>

	</xsl:template>
                             
</xsl:stylesheet>
