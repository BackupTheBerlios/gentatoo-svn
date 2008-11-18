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

<!-- this stylesheet prints out the navibation bar which includes the controls for navigation, page count and the index link in a html table-->

<!-- dependencies -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xi="http://www.w3.org/2001/XInclude">
 	
 	<!-- root url of application -->
	<xsl:param name="rootURL" />
	
	<!-- url pattern which executes an filter request -->
	<xsl:param name="filterPattern" />
	
	<!-- table Name -->
	<xsl:param name="tableName" />
	
	<!-- value says how many rows will be displayed per page as maximum -->
	<xsl:param name="rowsPerPage" />
		
	<!-- name of table which is displayed -->
	<xsl:param name="tableName" />
	
	<!-- name of datasource of table -->
	<xsl:param name="nameOfDatasource" />
 	
 	<!-- chosen order in sql statement "asc" or "desc" -->
	<xsl:param name="order" />
	
	<!-- name of chosen order column -->
	<xsl:param name="orderColumn" />
	
	<!-- variable for chosen filter criteria -->
	<xsl:param name="filterCriteria" />
		
	<!-- variable for chosen filter column -->
	<xsl:param name="filterColumn" />
 		
	<!-- url pattern which executes sql statement -->
	<xsl:param name="runsqlPattern" />
 		
	<!-- actual page number -->           
	<xsl:param name="aktBlockNr" />
	
	<!-- number of rows in rowset -->
	<xsl:param name="nrOfRows" />
	
	<!-- protocol pattern for internal requests -->
	<xsl:param name="cocoonProtocol" />
 			
	<!-- 
	TEMPLATE /page
	
	creates the navigation links
	 -->
	<xsl:template match="/page">
			
		<table>
			<tr>
				<td align="left">
					<!-- show navigation -->
	   				<xi:include href="{$cocoonProtocol}/navigationControl/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$orderColumn}/{$order}/{$filterColumn}/{$filterCriteria}/{$runsqlPattern}/{$nrOfRows}" />
	   			</td> 
	   			
	   			<td align="center">
	   				<!-- show actual page and count of pages -->
					<xi:include href="{$cocoonProtocol}/pageCountControl/{$rowsPerPage}/{$aktBlockNr}/{$nrOfRows}" />
				</td>
				
				<td align="right">
					<!-- link back to index page -->
					<a href="{$rootURL}/index">Index</a>
				</td>
			</tr>
		</table>
							
	</xsl:template>

</xsl:stylesheet>
