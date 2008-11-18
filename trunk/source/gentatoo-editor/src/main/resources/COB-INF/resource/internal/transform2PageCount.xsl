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

<!-- this stylesheet prints out the actual page number and the total count of pages -->

<!-- dependencies -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 	
 	<!-- number of rows in rowset -->
	<xsl:param name="nrOfRows" />
	
	<!-- value says how many rows will be displayed per page as maximum -->
	<xsl:param name="rowsPerPage" />
 		
	<!-- actual page number -->           
	<xsl:param name="aktBlockNr" />
 			
	<!-- 
	TEMPLATE /page
	
	calculates total page count
	prints out actual and total page count
	 -->
	<xsl:template match="/page">
			
		<p>	
			
			Page		
			<xsl:value-of select="$aktBlockNr" />		
			of		
			<xsl:variable name="pages" select="floor($nrOfRows div $rowsPerPage)" />
			
			<xsl:choose>
				<xsl:when test="($nrOfRows div $rowsPerPage) = $pages">
					<xsl:value-of select="$pages" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$pages + 1" />
				</xsl:otherwise>
			</xsl:choose>
			
		</p> 
							
	</xsl:template>

</xsl:stylesheet>
