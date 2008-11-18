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

<!-- this stylesheet formats the output of the sql query for the foreign key statement as a combobox -->

<!-- dependencies -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sql="http://apache.org/cocoon/SQL/2.0">
 	
 	<!-- name of column -->
	<xsl:param name="columName" />
 	
 	<!-- value which shall be preselected in combo -->
	<xsl:param name="currentValue" />
	
	<!-- table Name -->
	<xsl:param name="tableName" />
 	
 	<!-- name of foreign key column -->
	<xsl:param name="fkColumn" />
 			
	<!-- 
	TEMPLATE sql:rowset
	
	prints out an select element and applies row values
	 -->
	<xsl:template match="sql:rowset">
			
		<select name="{$tableName}.{$columName}">
			
				<!-- apply child tags -->
	      		<xsl:apply-templates/>

    	</select>
							
	</xsl:template>
	
	
	<!-- 
	TEMPLATE sql:row

	prints out the mapped values of the foreign key values as option elements (for select)
	--> 
	<xsl:template match="sql:row">
		
		<!-- exclude value of key -->
		<xsl:variable name="fkey">
			<xsl:for-each select="*">
		 		<xsl:if test="substring(name(),5) = $fkColumn">
		 				<xsl:value-of select="current()"/>
		 		</xsl:if>
		 	</xsl:for-each>
		</xsl:variable>
		
		<!-- assemble combobox -->
	 	<xsl:for-each select="*">
	 		<xsl:choose>
	 			<xsl:when test="substring(name(),5) = $fkColumn">
	 				<!-- key column, do nothing -->
	 			</xsl:when>
	 			<xsl:otherwise>
	 				<xsl:choose>
			 			<xsl:when test="$currentValue = $fkey">
			 				 <option value="{normalize-space($fkey)}" selected="true"><xsl:value-of select="current()"/></option>
			 			</xsl:when>
			 			<xsl:otherwise>
			 				<option value="{normalize-space($fkey)}"><xsl:value-of select="current()" /></option>
			 			</xsl:otherwise>
	 				</xsl:choose>
	 			</xsl:otherwise>
	 		</xsl:choose>
	 	</xsl:for-each>
		
	</xsl:template>

</xsl:stylesheet>
