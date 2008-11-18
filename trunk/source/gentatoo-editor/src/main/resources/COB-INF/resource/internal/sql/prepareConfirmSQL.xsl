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

<!-- This stylesheet creates the select statement for the confirmation table. -->

<!-- dependencies -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sql="http://apache.org/cocoon/SQL/2.0"
                xmlns:h="http://apache.org/cocoon/request/2.0">

	<!--
	PARAMETERS
	
	from sitemap 
	--> 
	
	<!--name of table -->  
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
	<xsl:template match="h:request">
	
		<page>
		    <content>
		        
		        <sql:execute-query xmlns:sql="http://apache.org/cocoon/SQL/2.0">
		            <sql:query name="lastmod">    			        				
		          			
		          			SELECT 
		          				<!-- concat keys -->
		          				<xsl:variable name="keys">
		          					<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/keys/key">
		          						<xsl:value-of select="@name" />, 
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
		          						,<xsl:value-of select="@name" />
		          				</xsl:for-each>
		          			
		          			FROM
		          				<xsl:value-of select="$tableName"/>		
		          			
		          			WHERE
		          				<xsl:apply-templates/>
		          			
		          			<!-- append order by clause if given 
		          			not needed for comfitmarion (only one single record)
		          			
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
		          			
		          			-->	
		            </sql:query>
		        </sql:execute-query>
		        
		    </content> 
		</page>
		
	</xsl:template>
	
	<!--
	TEMPLATE DUMMY for h:requestHeaders
	
	dummy is needed to surpress the output of this tag
	-->
	<xsl:template match="h:requestHeaders" />
	
	<!--
	TEMPLATE DUMMY for h:remoteUser
	
	dummy is needed to surpress the output of this tag
	-->
	<xsl:template match="h:remoteUser" />
	
	<!--
	TEMPLATE DUMMY for h:configurationParameters
	
	dummy is needed to surpress the output of this tag
	-->
	<xsl:template match="h:configurationParameters" />
	
	<!--
	TEMPLATE for h:requestParameters
	
	creates where clause from request parameters
	only primary keys are considered
	-->
	<xsl:template match="h:requestParameters">
					
		<!-- concat where clause with keys -->
		<xsl:variable name="keys">
			
			<xsl:for-each select="*">
				<xsl:variable name="nameCurrentKey"><xsl:value-of select="substring-after(@name, '.')" /></xsl:variable>
				<xsl:variable name="valueCurrentKey"><xsl:value-of select="current()" /></xsl:variable>
						
				<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/keys/key">
				       <xsl:if test="$nameCurrentKey=@name">
				          <xsl:value-of select="$nameCurrentKey" /> = <xsl:value-of select="$valueCurrentKey" />
				          AND
				       </xsl:if>  						
				</xsl:for-each>       				
			</xsl:for-each>
		</xsl:variable>	
		
		<xsl:value-of select="substring(normalize-space($keys), 0, string-length(normalize-space($keys)) - 3)" />
	
	</xsl:template>

</xsl:stylesheet>