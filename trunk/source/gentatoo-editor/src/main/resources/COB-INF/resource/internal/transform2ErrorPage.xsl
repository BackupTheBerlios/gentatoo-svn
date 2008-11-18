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

<!-- this stylesheet formats the output for the error message -->
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
	
	<!-- message which is displayed -->
	<xsl:param name="errorMsg" />
		
	<!--
	TEMPLATE for page
	
	creates title, header and body
	-->
	<xsl:template match="page">
	
		<html>
			<head>
				<title>${pom.name} - ${pom.version}</title>
				<!--
					acces to icon not possible because of error situation??
					<link rel="SHORTCUT ICON" href="{$rootURL}/resources/external/images/favicon.ico" />
				-->
				<style>
					<!-- include css bx xinclude, otherwise css gets lost in some situations -->
					<xi:include parse="text" href="{$pathToExternalResources}/{$css}"/>
				</style>		
			</head>
			<body>	
				<div id="wrapper2">
					<h1>Exception</h1>
					
					<!-- apply child tags -->
	      			<xsl:apply-templates/>
	      			
	      			<div id="footer">
	      				<table>
	      					<tr>
	      						<td align="left"></td>
	      						<td align="center"></td>
	      						<td align="right">
	      							<!-- link back to index page -->
	   								<a href="{$rootURL}/index">Index</a>
	      						</td>
	      					</tr>
	      				</table>
	   				</div>
	   			</div> 
			</body>
		</html>
	
	</xsl:template>
	
	
	<!--
	TEMPLATE for content
	
	adds error message from parameter errorMsg
	-->
	<xsl:template match="content">	
		
			<p class="message"><xsl:value-of select="$errorMsg" /></p>

	</xsl:template>
                             
</xsl:stylesheet>

