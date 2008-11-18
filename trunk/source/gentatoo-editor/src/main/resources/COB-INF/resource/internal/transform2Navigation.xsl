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

<!-- this stylesheet prints out the navihation links (previous and next) -->

<!-- dependencies -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 	
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
 			
	<!-- 
	TEMPLATE /page
	
	creates the navigation links
	 -->
	<xsl:template match="/page">
			
		<xsl:variable name="leftPages" select="$nrOfRows - ($aktBlockNr * $rowsPerPage)"/>
	   	<!-- append link for "previous" -->
	   	<xsl:choose>
		   	<xsl:when test="($aktBlockNr &gt; 1)">
		   		<xsl:variable name="nrOfPreviousBlock" select="$aktBlockNr - 1"/>
		   		<a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$nrOfPreviousBlock}/{$orderColumn}/{$order}/{$filterColumn}/{$filterCriteria}">Previous</a> |
		   	</xsl:when>
		   			
		   	<xsl:otherwise>
		   		<!-- append dummy for "previous" only if link for "next" is active -->
		   		<xsl:if test="($leftPages &gt; 0)">
		   			Previous |
		   		</xsl:if>
		   	</xsl:otherwise>
	   	</xsl:choose>
				
	   	<!-- append link for "next" -->
	   	<xsl:choose>
	   		<xsl:when test="$leftPages &gt; 0">
	   			<xsl:variable name="nrOfNextBlock" select="$aktBlockNr + 1"/>
	    		<a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$nrOfNextBlock}/{$orderColumn}/{$order}/{$filterColumn}/{$filterCriteria}">Next</a>
	   		</xsl:when>
	   				
	   		<xsl:otherwise>
		   		<!-- append dummy for "next" only if link for "previous" is active -->
		   		<xsl:if test="($aktBlockNr &gt; 1)">		   				
		   			Next
		   		</xsl:if>
		   	</xsl:otherwise>
	   	</xsl:choose> 
							
	</xsl:template>

</xsl:stylesheet>
