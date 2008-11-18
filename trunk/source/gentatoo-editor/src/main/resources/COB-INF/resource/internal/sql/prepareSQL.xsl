<?xml version="1.0" encoding="UTF-8"?>

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

<!-- This stylesheet creates the select statement for the specified table. -->

<!-- dependencies -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sql="http://apache.org/cocoon/SQL/2.0">

	<!--
	PARAMETERS
	
	from sitemap 
	-->   
	<xsl:param name="tableName" />
	
	<!-- path to the descriptor file of table -->
	<xsl:param name="pathToDescriptor" />
	
	<!-- name of chosen order column -->
	<xsl:param name="orderColumn" />
	
	<!-- chosen order clause. Format: "columnName order" -->
	<xsl:param name="orderClause" />
	
	<!-- name of chosen order column -->
	<xsl:param name="filterColumn" />
	
	<!-- name of chosen order column -->
	<xsl:param name="filterCriteria" />
	
	<!-- 
	TEMPLATE query
	
	provides basic sql statement
	-->
	<xsl:template match="query">
	
		<page>
		    <content>
		    
		        <sql:execute-query xmlns:sql="http://apache.org/cocoon/SQL/2.0">
		            <sql:query name="lastmod">  			 
		          			        				
		          			SELECT 
		          				<!-- concat keys -->
		          				<xsl:variable name="keys">
		          					<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/keys/key">
		          						<xsl:value-of select="concat($tableName, '.', @name)" />, 
		          					</xsl:for-each>
		          				</xsl:variable>
		          				
		          				<!-- remove white spaces from variable with keys -->
		          				<xsl:variable name="keysCorrected" select="normalize-space($keys)" />
		          				
		          				<xsl:variable name="keysLength">
		          					<xsl:value-of select="string-length(normalize-space($keysCorrected)) - 1" />
		          				</xsl:variable>
		          				
		          				<!-- print out keys except last char which is a comma -->
		          				<xsl:value-of select="substring($keysCorrected, 1,  $keysLength)" />
		          				
		          				<!-- print out values -->
		          				<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value">
		          						,<xsl:value-of select="concat($tableName, '.', @name)" />
		          				</xsl:for-each>
		          				
		          				<!-- fetch foreign key columns-->
		          				<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@select]">
		          						<xsl:if test="normalize-space(@select) != ''">
		          							<xsl:variable name="fkTableName" select="normalize-space(substring-before(substring-after(@select, 'FROM '),' '))" />
		          							,<xsl:value-of select="concat($fkTableName, '.', normalize-space(substring-after(substring-before(@select, ' AS gtt_fkey'),' ')))" />
		          							AS
		          							ogtt_fkey<xsl:value-of select="normalize-space(substring-before(substring-after(@select, ' AS gtt_fkey'),','))" />
		          							,<xsl:value-of select="concat($fkTableName, '.', normalize-space(substring-after(substring-before(@select, ' AS gtt_alias'),', ')))" />
		          							AS
		          							ogtt_alias<xsl:value-of select="normalize-space(substring-before(substring-after(@select, ' AS gtt_alias'),' '))" />
		          						</xsl:if>
		          						  						
		          				</xsl:for-each> 
		          				
		          			FROM
		          				<xsl:value-of select="$tableName"/>
							
							<!-- join foreign key tables -->
		          			<xsl:variable name="selectCountPattern">
		          				<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@select]">
		          					X
		          				</xsl:for-each>
		          			</xsl:variable>
		          			
		          			<xsl:variable name="selectCount" select="string-length(normalize-space($selectCountPattern))" />
		          			
		          			<xsl:if test="$selectCount > 0">
		          				<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@select]">
		          					<xsl:if test="normalize-space(@select) != ''">
		          							
		          						LEFT OUTER JOIN
		          							<xsl:variable name="fkTableName"><xsl:value-of select="normalize-space(substring-before(substring-after(@select, 'FROM '),' '))" /></xsl:variable>
		          							<xsl:value-of select="$fkTableName" />
		          							
		          						ON
		          							<xsl:value-of select="concat($fkTableName, '.', normalize-space(substring-after(substring-before(@select, ' AS gtt_fkey'),' ')))" />
		          							= <xsl:value-of select="concat($tableName, '.', @name)" />
		          					</xsl:if>			  						
		          				</xsl:for-each> 
		          			</xsl:if>
		          			
		          			<!-- define where clause (filter) -->
		          			<xsl:choose>
		          				<xsl:when test="$filterColumn != '-'">
		          				
		          					WHERE
									<xsl:value-of select="$filterColumn"/>
		          				
		          					LIKE
		          					'%<xsl:value-of select="$filterCriteria"/>%'
		          				
		          				</xsl:when>
		          			
		          				<xsl:otherwise/>
		          			
		          			</xsl:choose>
		          			
		          			<!-- append order by clause if given -->		          			
		          			<xsl:choose>
		   						<xsl:when test="$orderColumn = '-'">
		          					<xsl:variable name="orderby"><xsl:value-of select="document(concat('resource://',$pathToDescriptor))/root/table/orderby"/></xsl:variable>
		          					
		          					<xsl:if test="normalize-space($orderby) != ''">
		          						
		          						ORDER BY
		          							<xsl:value-of select="$orderby"/>
		          			
		          					</xsl:if>
		          					
		          				</xsl:when>
		          				<xsl:otherwise>
		          				
		          					ORDER BY
										<xsl:value-of select="$orderClause"/>
		          				
		          				</xsl:otherwise>
		          			</xsl:choose>	
		            </sql:query>
		        </sql:execute-query>
		        
		    </content> 
		</page>
		
	</xsl:template>

</xsl:stylesheet>
