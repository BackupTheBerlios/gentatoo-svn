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

<!-- this stylesheet prints out a form to enter a column and a criterion for filtering -->

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
	
	<!-- path to the descriptor file of table -->
	<xsl:param name="pathToDescriptor" />
	
	<!-- variable for chosen filter criteria -->
	<xsl:param name="filterCriteria" />
		
	<!-- variable for chosen filter column -->
	<xsl:param name="filterColumn" />
 	
 	<!-- 
	VARIABLES
	
	constant values
	--> 
	<xsl:variable name="READ_ONLY" select="'r'"/>
		
	<xsl:variable name="BLOB_TYPE_IMAGE" select="'image'"/>
	
	<xsl:variable name="BLOB_TYPE_BINARY" select="'binary'"/>
 			
	<!-- 
	TEMPLATE sql:rowset
	
	creates the filter form
	 -->
	<xsl:template match="/page">
			
		<div id="filter">									
			<table>											
				<tr>											
					<form method="get" action="{$rootURL}/{$filterPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/1/{$orderColumn}/{$order}/-/-">												
						<td>													
							<select name="column" class="list">							
								
								<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/keys/key[@access=$READ_ONLY]">						   		
									<xsl:variable name="keyName"><xsl:value-of select="@name" /></xsl:variable>						
									<xsl:variable name="keyAlias"><xsl:value-of select="@alias" /></xsl:variable>					   			
									<xsl:choose>				   			
										<xsl:when test="$keyName = $filterColumn">				   			
											<option value="{$keyName}" selected="selected"><xsl:value-of select="$keyAlias"/></option>				   				
										</xsl:when>					   			
										<xsl:otherwise>				   				
											<option value="{$keyName}"><xsl:value-of select="$keyAlias"/></option>				   				
										</xsl:otherwise>					   			
									</xsl:choose>						
								</xsl:for-each>
														
								<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@access]">					   		
									<xsl:variable name="columnName"><xsl:value-of select="@name" /></xsl:variable>						
									<xsl:variable name="columnAlias"><xsl:value-of select="@alias" /></xsl:variable>					   			
									
									<xsl:variable name="dirtyColumnNameFk">
							  			<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@select]">
							  				<xsl:if test="@name = $columnName">
							  					<xsl:variable name="fkTableName"><xsl:value-of select="normalize-space(substring-before(substring-after(@select, 'FROM '),' '))" /></xsl:variable>
							  					<xsl:value-of select="concat($fkTableName, '.', normalize-space(substring-after(substring-before(@select, ' AS gtt_alias'),', ')))" />
							  				</xsl:if>
							  			</xsl:for-each>
						  			</xsl:variable>
		  			
						  			<xsl:variable name="dirtyColumnName">
						  				<xsl:choose>
						  					<xsl:when test="string-length(normalize-space($dirtyColumnNameFk)) > 0">
						  						<xsl:value-of select="normalize-space($dirtyColumnNameFk)" />
						  					</xsl:when>
						  					<xsl:otherwise>
						  						<xsl:value-of select="concat($tableName, '.', $columnName)" />
						  					</xsl:otherwise>
						  				</xsl:choose>
						  			</xsl:variable>
		  			
		  							<xsl:variable name="nameOfColumn" select="normalize-space($dirtyColumnName)" />
									
									<xsl:choose>
										<xsl:when test="@type = $BLOB_TYPE_IMAGE"><!-- do nothing, blobs are not searchable --></xsl:when>	
										<xsl:when test="@type = $BLOB_TYPE_BINARY"><!-- do nothing, blobs are not searchable --></xsl:when>	
										<xsl:otherwise>
											<xsl:choose>				   			
												<xsl:when test="$nameOfColumn = $filterColumn">				   			
													<option value="{$nameOfColumn}" selected="selected"><xsl:value-of select="$columnAlias"/></option>				   				
												</xsl:when>					   			
												<xsl:otherwise>				   				
													<option value="{$nameOfColumn}"><xsl:value-of select="$columnAlias"/></option>				   				
												</xsl:otherwise>					   			
											</xsl:choose>	
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
			
							</select>							
						</td>							
						<td>						
							<input type="text" name="criteria" value="{$filterCriteria}" class="text"/>						
						</td>							
						<td>						
							<input type="submit" name="submit" value="Search" class="button"/>						
						</td>								
					</form>						
				</tr>							
			</table>						
		</div>
							
	</xsl:template>

</xsl:stylesheet>
