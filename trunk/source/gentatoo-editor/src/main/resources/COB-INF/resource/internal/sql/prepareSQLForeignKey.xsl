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

<!-- This stylesheet creates the select statement for foreign keys of a specific column. -->

<!-- dependencies -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sql="http://apache.org/cocoon/SQL/2.0">

	<!--
	PARAMETERS
	
	from sitemap 
	-->
	
	<!-- name of column -->   
	<xsl:param name="columnName" />
	
	<!-- path to the descriptor file of table -->
	<xsl:param name="pathToDescriptor" />
	
	<!-- 
	TEMPLATE query
	
	provides basic sql statement
	-->
	<xsl:template match="query">
	
		<page>
		    <content>
		    
		        <sql:execute-query xmlns:sql="http://apache.org/cocoon/SQL/2.0">
		            <sql:query name="lastmod">
		            
		          			<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@access]">
		          				<xsl:if test="$columnName = @name">
		          					<xsl:value-of select="@select" />
		          				</xsl:if>
		          			</xsl:for-each>
		            </sql:query>
		        </sql:execute-query>
		        
		    </content>
		</page>
		
	</xsl:template>

</xsl:stylesheet>