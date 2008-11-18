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

<!-- this stylesheet prints out the mapped value of the foreign key as plain text, according to the given sql statement -->

<!-- dependencies -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sql="http://apache.org/cocoon/SQL/2.0">
 	
 	<!-- name of column -->
	<xsl:param name="columName" />
 	
 	<!-- current value of column-->
	<xsl:param name="currentValue" />
	
	<!-- table Name -->
	<xsl:param name="tableName" />
	
	<!-- name of foreign key column -->
	<xsl:param name="fkColumn" />

	<!-- 
	TEMPLATE sql:rowset
	
	calls all sub elements (sql:row)
	 -->
	<xsl:template match="sql:rowset">
			
		<!-- apply child tags -->
	      <xsl:apply-templates/>
							
	</xsl:template>
	
	
	<!-- 
	TEMPLATE sql:row

	prints out the mapped value of the foreign key value
	--> 
	<xsl:template match="sql:row">
		
		<!-- select value of foreign key -->
		<xsl:variable name="fkey">
			<xsl:for-each select="*">
		 		<xsl:if test="substring(name(),5) = $fkColumn">
		 				<xsl:value-of select="current()"/>
		 		</xsl:if>
		 	</xsl:for-each>
		</xsl:variable>
		
		<!-- print out mapped value for foreign key -->
	 	<xsl:for-each select="*">
	 		<xsl:choose>
	 			<xsl:when test="substring(name(),5) = $fkColumn">
	 				<!-- key column, do nothing -->
	 			</xsl:when>
	 			<xsl:otherwise>
	 				<xsl:choose>
			 			<xsl:when test="$currentValue = $fkey">
			 				 <xsl:value-of select="current()"/>
			 			</xsl:when>
			 			<xsl:otherwise>
			 				<!-- value of current key is not current value, do nothing -->
			 			</xsl:otherwise>
	 				</xsl:choose>
	 			</xsl:otherwise>
	 		</xsl:choose>
	 	</xsl:for-each>
		
	</xsl:template>

</xsl:stylesheet>
