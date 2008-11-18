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

<!-- this stylesheet formats the output of the sql query -->

<!-- dependencies -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:sql="http://apache.org/cocoon/SQL/2.0"
                xmlns:xi="http://www.w3.org/2001/XInclude">
 				
	<!-- 
	PARAMETERS
	
	from sitemap 
	--> 
	
	<!-- root url of application -->
	<xsl:param name="rootURL" />
	
	<!-- url pattern which executes sql statement -->
	<xsl:param name="runsqlPattern" />
	
	<!-- url pattern which executes an database action -->
	<xsl:param name="dbActionPattern" /> 
	
	<!-- url pattern which executes an filter request -->
	<xsl:param name="filterPattern" />
	
	<!-- protocol pattern for internal requests -->
	<xsl:param name="cocoonProtocol" />
	
	<!-- actual page number -->           
	<xsl:param name="aktBlockNr" />
	
	<!-- value says how many rows will be displayed per page as maximum -->
	<xsl:param name="rowsPerPage" />
	
	<!-- path to the descriptor file of table -->
	<xsl:param name="pathToDescriptor" />
	
	<!-- path to external resources ("/resource/external" for example) -->
	<xsl:param name="pathToExternalResources" />
	
	<!-- name of table which is displayed -->
	<xsl:param name="tableName" />
	
	<!-- name of datasource of table -->
	<xsl:param name="nameOfDatasource" />
	
	<!-- sub path to css from pathToExternalResources -->
	<xsl:param name="css" />
	
	<!-- any message which shall be displayed above the table view -->
	<xsl:param name="statusMsg" />
	
	<!-- chosen order in sql statement "asc" or "desc" -->
	<xsl:param name="order" />
	
	<!-- name of chosen order column -->
	<xsl:param name="orderColumn" />
	
	<!-- says if filter should be shown -->
	<xsl:param name="showFilter" />
	
	<!-- variable for chosen filter criteria -->
	<xsl:param name="filterCriteria" />
	
	<!-- variable for chosen filter column -->
	<xsl:param name="filterColumn" />
	
	<!-- path to large object cache -->
	<xsl:param name="pathToLargeObjectCache" />
	
	<!-- 
	VARIABLES
	
	constant values
	--> 
	<xsl:variable name="READ_WRITE" select="'rw'"/>
	
	<xsl:variable name="READ_ONLY" select="'r'"/>
	
	<xsl:variable name="HIDDEN" select="'h'"/>
	
	<xsl:variable name="BLOB_TYPE_IMAGE" select="'image'"/>
	
	<xsl:variable name="BLOB_TYPE_BINARY" select="'binary'"/>
	
	<xsl:variable name="NO_VALUE" select="'No Value'"/>
	
	<!-- 
	VARIABLES
	
	values from descriptor
	and other composed values
	--> 
	<!-- says if the user is allowed to add data (true/false) -->
	<xsl:variable name="valuesAddable" select="document(concat('resource://',$pathToDescriptor))/root/table/values/parameter[@name='add']" />
	
	<!-- true/false: says if the user is allowed delete data (true/false) -->
	<xsl:variable name="valuesDeleteable" select="document(concat('resource://',$pathToDescriptor))/root/table/values/parameter[@name='delete']" />
	
	<!-- order by clause of manually chosen values -->
	<xsl:variable name="orderClauseFromDescriptor" select="normalize-space(document(concat('resource://',$pathToDescriptor))/root/table/orderby)" />
	
	<!-- order by clause of manually chosen values -->
	<xsl:variable name="orderClause" select="concat($orderColumn, ' ', $order)" />
	
	
	<!-- 
	TEMPLATE /page
	
	style for page tag (whole page)
	Adds title and description from descriptor.xml
	--> 
	<xsl:template match="/page">
		<xsl:variable name="sqlError"><xsl:value-of select="content/sql:rowset/sql:error" /></xsl:variable>
		<xsl:choose>
			<xsl:when test="$sqlError != ''">
				<xi:include href="{$cocoonProtocol}/exception?msg={$sqlError}" />
			</xsl:when>
			
			<xsl:otherwise>
				<html>
			  		<head>
			  	  		<title>${pom.name} - ${pom.version}</title>
			  	  		<link rel="SHORTCUT ICON" href="{$pathToExternalResources}/images/favicon.ico" />
			  	  		<link rel="stylesheet" type="text/css" href="{$pathToExternalResources}/{$css}" /> 
			  	  	</head>	
			  		<body>
			  			<div id="wrapper2">
								<!-- complete style if no exception was thrown-->
					  			<h1>
					  				<!-- display title -->
					  				<xsl:value-of select="document(concat('resource://',$pathToDescriptor))/root/table/title" />
								</h1>
								<p class="description">
									<!-- display description -->
									<xsl:value-of select="document(concat('resource://',$pathToDescriptor))/root/table/description" />
								</p>
								<p class="datasource">
									Datasource: <xsl:value-of select="$nameOfDatasource" />
								</p>
								
								<!-- display filter form -->
								<xsl:if test="$showFilter = 'true'">
									<xi:include href="{$cocoonProtocol}/filterControl/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$orderColumn}/{$order}/{$filterColumn}/{$filterCriteria}" />
								</xsl:if>
								
								<p class="message">
									<xsl:value-of select="$statusMsg" />
								</p>
					   		
					      		<!-- apply child tags -->
					      		<xsl:apply-templates/>   			
			    		</div>
			  		</body>
				</html>
			</xsl:otherwise>
		</xsl:choose>
			
	</xsl:template>
	
	
	<!-- 
	TEMPLATE sql:rowset
	
	prints out page counter
	apply table headers from descriptor.xml
	adds form for new rows
	adds footer navigation
	 -->
	<xsl:template match="sql:rowset">
						
		<table>
			<tr>
			<!-- empty header element for delete button -->
			<xsl:if test="$valuesDeleteable = 'true'">
	 			<th></th>
	 		</xsl:if>
	 		
	 		<!-- empty header element for reset and update button -->
	 		<th></th>
	 		<th></th>
			
			<!-- column headers with alias -->	
			<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/keys/key[@access=$READ_ONLY]">
	  			 	<xsl:variable name="keyAliasR"><xsl:value-of select="@alias" /></xsl:variable>		
	  				<xsl:variable name="nameOfColumn" select="concat($tableName, '.', @name)" />
	  				
	  				<th>
	      				<!-- add column headers for keys -->	
	      				<xsl:choose>
							<!-- check first for default order -->
							<xsl:when test="$orderClause = concat('-', ' asc')">
								<xsl:choose>
									<xsl:when test="$orderClauseFromDescriptor = concat($nameOfColumn, ' asc')">
										<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$keyAliasR" /></a>
									</xsl:when>
									
									<xsl:when test="$orderClauseFromDescriptor = $nameOfColumn">
										<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$keyAliasR" /></a>
									</xsl:when>
									
									<xsl:when test="$orderClauseFromDescriptor = concat($nameOfColumn, ' desc')">
										<img src="{$pathToExternalResources}/images/up.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$keyAliasR" /></a>
									</xsl:when>
									
									<xsl:otherwise>
	      								<a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$keyAliasR" /></a>
	      							</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							
							<!-- check now for custom order -->
							<xsl:when test="$orderClause = concat($nameOfColumn, ' asc')">
	      						<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$keyAliasR" /></a>
	      					</xsl:when>
	      						
	      					<xsl:when test="$orderClause = concat($nameOfColumn, ' desc')">
	      						<img src="{$pathToExternalResources}/images/up.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$keyAliasR" /></a>
	      					</xsl:when>
	      						
	      					<xsl:otherwise>
	      						<a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$keyAliasR" /></a>
	      					</xsl:otherwise>
						</xsl:choose>
	      			</th>
	        </xsl:for-each>
			
			<!-- loop columns independent of access mode
				order of column depends on order in descriptor
			-->
			<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@access]">
	  			 	<xsl:variable name="valueAliasRRW"><xsl:value-of select="@alias" /></xsl:variable>
	  			 	<xsl:variable name="nameValueRRW"><xsl:value-of select="@name" /></xsl:variable>
		  			
		  			<xsl:variable name="dirtyColumnNameFk">
			  			<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@select]">
			  				<xsl:if test="@name = $nameValueRRW">
			  					<xsl:variable name="fkTableName"><xsl:value-of select="normalize-space(substring-before(substring-after(@select, 'FROM '),' '))" /></xsl:variable>
			  					<xsl:value-of select="concat($fkTableName, '.', normalize-space(substring-after(substring-before(@select, ' AS gtt_alias'),', ')))" />
			  					<!--<xsl:value-of select="concat('gtt_fkey', substring-before(substring-after(@select, 'gtt_fkey'), ','))" />-->
			  				</xsl:if>
			  			</xsl:for-each>
		  			</xsl:variable>
		  			
		  			<xsl:variable name="dirtyColumnName">
		  				<xsl:choose>
		  					<xsl:when test="string-length(normalize-space($dirtyColumnNameFk)) > 0">
		  						<xsl:value-of select="normalize-space($dirtyColumnNameFk)" />
		  					</xsl:when>
		  					<xsl:otherwise>
		  						<xsl:value-of select="concat($tableName, '.', @name)" />
		  					</xsl:otherwise>
		  				</xsl:choose>
		  			</xsl:variable>
		  			
		  			<xsl:variable name="nameOfColumn" select="normalize-space($dirtyColumnName)" />
		  			
		  			<xsl:choose>							
	  					<xsl:when test="normalize-space(@type) = $BLOB_TYPE_IMAGE"><!-- blos are shown separately --></xsl:when>			
	  					
	  					<xsl:when test="normalize-space(@type) = $BLOB_TYPE_BINARY"><!-- blos are shown separately --></xsl:when>
	  					
	  					<xsl:otherwise>
	  						<th>
								<!-- add column headers for values-->	
			      				<xsl:choose>
									<!-- check first for default order -->
									<xsl:when test="$orderClause = concat('-', ' asc')">
										<xsl:choose>
											<xsl:when test="$orderClauseFromDescriptor = concat($nameOfColumn, ' asc')">
												<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
											</xsl:when>
											
											<xsl:when test="$orderClauseFromDescriptor = $nameOfColumn">
												<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
											</xsl:when>
											
											<xsl:when test="$orderClauseFromDescriptor = concat($nameOfColumn, ' desc')">
												<img src="{$pathToExternalResources}/images/up.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
											</xsl:when>
											
											<xsl:otherwise>
			      								<a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      							</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									
									<!-- check now for custom order -->
									<xsl:when test="$orderClause = concat($nameOfColumn, ' asc')">
			      						<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      					</xsl:when>
			      						
			      					<xsl:when test="$orderClause = concat($nameOfColumn, ' desc')">
			      						<img src="{$pathToExternalResources}/images/up.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      					</xsl:when>
			      						
			      					<xsl:otherwise>
			      						<a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      					</xsl:otherwise>
								</xsl:choose>		
	      					</th>
	  					</xsl:otherwise>
		  			</xsl:choose>						
	        </xsl:for-each>
	        
	        <!-- add headers for blobs -->
	        <xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@access]">
	  			 	<xsl:variable name="valueAliasRRW"><xsl:value-of select="@alias" /></xsl:variable>
		  			<xsl:variable name="nameOfColumn" select="concat($tableName, '.', @name)" />
		  			<xsl:choose>							
	  					<xsl:when test="normalize-space(@type) = $BLOB_TYPE_IMAGE">		 
	  						<th>
								<!-- add column headers for values-->	
			      				<xsl:choose>
									<!-- check first for default order -->
									<xsl:when test="$orderClause = concat('-', ' asc')">
										<xsl:choose>
											<xsl:when test="$orderClauseFromDescriptor = concat($nameOfColumn, ' asc')">
												<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
											</xsl:when>
											
											<xsl:when test="$orderClauseFromDescriptor = $nameOfColumn">
												<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
											</xsl:when>
											
											<xsl:when test="$orderClauseFromDescriptor = concat($nameOfColumn, ' desc')">
												<img src="{$pathToExternalResources}/images/up.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
											</xsl:when>
											
											<xsl:otherwise>
			      								<a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      							</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									
									<!-- check now for custom order -->
									<xsl:when test="$orderClause = concat($nameOfColumn, ' asc')">
			      						<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      					</xsl:when>
			      						
			      					<xsl:when test="$orderClause = concat($nameOfColumn, ' desc')">
			      						<img src="{$pathToExternalResources}/images/up.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      					</xsl:when>
			      						
			      					<xsl:otherwise>
			      						<a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      					</xsl:otherwise>
								</xsl:choose>		
	      					</th>		 
	  					</xsl:when>
	  								
	  					<xsl:when test="normalize-space(@type) = $BLOB_TYPE_BINARY">
	  							<th>
								<!-- add column headers for values-->	
			      				<xsl:choose>
									<!-- check first for default order -->
									<xsl:when test="$orderClause = concat('-', ' asc')">
										<xsl:choose>
											<xsl:when test="$orderClauseFromDescriptor = concat($nameOfColumn, ' asc')">
												<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
											</xsl:when>
											
											<xsl:when test="$orderClauseFromDescriptor = $nameOfColumn">
												<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
											</xsl:when>
											
											<xsl:when test="$orderClauseFromDescriptor = concat($nameOfColumn, ' desc')">
												<img src="{$pathToExternalResources}/images/up.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
											</xsl:when>
											
											<xsl:otherwise>
			      								<a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      							</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									
									<!-- check now for custom order -->
									<xsl:when test="$orderClause = concat($nameOfColumn, ' asc')">
			      						<img src="{$pathToExternalResources}/images/down.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/desc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      					</xsl:when>
			      						
			      					<xsl:when test="$orderClause = concat($nameOfColumn, ' desc')">
			      						<img src="{$pathToExternalResources}/images/up.gif" /><a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      					</xsl:when>
			      						
			      					<xsl:otherwise>
			      						<a href="{$rootURL}/{$runsqlPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$nameOfColumn}/asc/{$filterColumn}/{$filterCriteria}"><xsl:value-of select="$valueAliasRRW" /></a>
			      					</xsl:otherwise>
								</xsl:choose>		
	      					</th>	
	  					</xsl:when>
	  					
	  					<xsl:otherwise><!-- all other values are already handled --></xsl:otherwise>
		  			</xsl:choose>					
	        </xsl:for-each>
	        
	        </tr>
			
			<!-- apply child tags -->
			<xsl:apply-templates/>
	
			<!-- add formular for new values -->
			<xsl:if test="$valuesAddable = 'true'">
				<!--
					space between content and formular for new values
					commented because it destroys the well formed table
					
				<tr><td>+</td></tr>
				-->
				<tr>
	
				<form method="get" action="{$rootURL}/{$dbActionPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$orderColumn}/{$order}/{$filterColumn}/{$filterCriteria}">
				<!-- submit and reset button-->
					<td>
	 					<input type="submit" name="submit" value="Add" class="button"/>
	 				</td>
	 				<td>
	 					<input type="reset" name="Reset" value="Reset" class="button"/>
	 				</td>
	 			
	 				<!-- empty data element to keep space for delete button -->
					<xsl:if test="$valuesDeleteable = 'true'">
	 					<td></td>
	 				</xsl:if>
	
	 				<!-- input fields for keys -->
			    	<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/keys/key[@access=$READ_ONLY]">
	  					<td>
	  				<!-- 
	  					Inserting custom keys is not allowed/implemented. 
	  					Keys are generated by the selected autoincrement-modules.
	  					Hence, only empty data elements are inserted here if necessary.
	  				-->
	  					</td>	
	            	</xsl:for-each>
				
					<!-- input fields value columns -->
					<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@access]">
	  			 		<xsl:variable name="valueName"><xsl:value-of select="@name" /></xsl:variable>
						<td>
							<xsl:choose>	
	  							<xsl:when test="string-length(@select) > 0">
	  								<!-- include combobox with values from select statment ("xOxOxOx" is for "no current value") -->
	  								<xsl:variable name="fkName" select="concat('gtt_fkey', substring-before(substring-after(@select, 'gtt_fkey'), ','))" />
	  								<xi:include href="{$cocoonProtocol}/fkAliasControl/{$nameOfDatasource}/{$tableName}/{$valueName}/Combobox/xOxOxOx/{$fkName}" />
	  							</xsl:when>
	  							
	  							<xsl:when test="normalize-space(@type) = $BLOB_TYPE_IMAGE">
									<xsl:value-of select="$NO_VALUE" />
								</xsl:when>
	  								
							  	<xsl:when test="normalize-space(@type) = $BLOB_TYPE_BINARY">						
							  		<xsl:value-of select="$NO_VALUE" />						
							  	</xsl:when>
	  							
	  							<xsl:otherwise>
				  					<xsl:choose>
				  						<xsl:when test="normalize-space(@textarea_height) = ''">
				  							<input type="text" name="{$tableName}.{$valueName}" class="text" />
				  						</xsl:when>
				  									  							
				  						<xsl:otherwise>
				  							<textarea name="{$tableName}.{$valueName}" class="text" rows="{@textarea_height}"/>
				  						</xsl:otherwise>
				  						
				  					</xsl:choose>
								</xsl:otherwise>	
							</xsl:choose>
						</td>
	           		</xsl:for-each>
			
				</form>
				</tr>
			</xsl:if>
			
		</table>	
		
		<div id="footer">		
			<xi:include href="{$cocoonProtocol}/navigationBarControl/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$orderColumn}/{$order}/{$filterColumn}/{$filterCriteria}/{$runsqlPattern}/{@nrofrows}" />
		</div>
			
	</xsl:template>
	
	
	<!-- 
	TEMPLATE sql:row
	
	converts each row into a formular
	which field is formatted as textfield or as lable depends on the descriptor.xml
	--> 
	<xsl:template match="sql:row">
	
		<tr>
			<form method="get" action="{$rootURL}/{$dbActionPattern}/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$orderColumn}/{$order}/{$filterColumn}/{$filterCriteria}">
			<!-- action buttons -->
	 			<td>
	 				<input type="submit" name="submit" value="Update" class="button"/>
	 			</td>
	 			<td>
	 				<input type="reset" name="reset" value="Reset" class="button"/>
	 			</td>
	 			
	 			<xsl:if test="$valuesDeleteable = 'true'">
	 				<td>
	 					<input type="submit" name="submit" value="Delete" class="button"/>
	 				</td>
	 			</xsl:if>
	
				<!-- style column values -->
	 			<xsl:for-each select="*">
	 			
	 				<!-- adding the prefix "sql:" that not too many changes in code are necessary. TODO: remove the prefix "sql:" --> 
					<xsl:variable name="nameOfCurrentNode"><xsl:value-of select="name()" /></xsl:variable>
					<xsl:variable name="valueOfCurrentNode"><xsl:value-of select="current()" /></xsl:variable>
					<xsl:variable name="isFkTableFlag"><xsl:value-of select="substring-before(name(), 'gtt_')" /></xsl:variable>

	 				<xsl:choose>
	 					<xsl:when test="$isFkTableFlag != 'o'">
	 					
							<!-- print out keys as hidden field or plain text-->
							<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/keys/key[@access=$READ_ONLY]">
			  			 		<xsl:variable name="keyNameR"><xsl:value-of select="@name" /></xsl:variable>
			                	<xsl:if test="concat('sql:', normalize-space($keyNameR))=$nameOfCurrentNode">
			  						<td>				
				  						<xsl:value-of select="$valueOfCurrentNode" />		
				      					<input type="hidden" value="{$valueOfCurrentNode}" name="{$tableName}.{substring($nameOfCurrentNode,5)}"/>
			      					</td>
			      				</xsl:if>
			           		</xsl:for-each>
			           
			           		<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/keys/key[@access=$HIDDEN]">
			  			 		<xsl:variable name="keyNameH"><xsl:value-of select="@name" /></xsl:variable>
			                	<xsl:if test="concat('sql:', normalize-space($keyNameH))=$nameOfCurrentNode">
			      						<input type="hidden" value="{$valueOfCurrentNode}" name="{$tableName}.{substring($nameOfCurrentNode,5)}"/>
			      				</xsl:if>
			           		</xsl:for-each>
			
							<!-- print out value columns as plain text or text field -->
							<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@access=$READ_WRITE]">
			  			 		<xsl:variable name="valueNameRW"><xsl:value-of select="@name" /></xsl:variable>
			                	<xsl:if test="concat('sql:', normalize-space($valueNameRW))=$nameOfCurrentNode">				     
			  							<xsl:choose>
			  								<xsl:when test="string-length(@select) > 0">
			  									<td> 
			  										<xsl:variable name="fkName" select="concat('gtt_fkey', substring-before(substring-after(@select, 'gtt_fkey'), ','))" />
			  										<xi:include href="{$cocoonProtocol}/fkAliasControl/{$nameOfDatasource}/{$tableName}/{$valueNameRW}/Combobox/{$valueOfCurrentNode}/{$fkName}" />
			  									</td>
			  								</xsl:when>
			  									  								
			  								<xsl:when test="normalize-space(@type) = $BLOB_TYPE_IMAGE"><!-- blos are shown separately --></xsl:when>
			  								
			  								<xsl:when test="normalize-space(@type) = $BLOB_TYPE_BINARY"><!-- blos are shown separately --></xsl:when>
			  								
			  								<xsl:otherwise>
			  									<td>
							  						<xsl:choose>
							  							<xsl:when test="normalize-space(@textarea_height) = ''">
							  								<input type="text" name="{$tableName}.{substring($nameOfCurrentNode,5)}" value="{$valueOfCurrentNode}" class="text" /> 
							  							</xsl:when>
							  							<xsl:otherwise>
							  								<textarea name="{$tableName}.{substring($nameOfCurrentNode,5)}" class="text" rows="{@textarea_height}">
							      								<xsl:value-of select="$valueOfCurrentNode" />
							      							</textarea>
							  							</xsl:otherwise>
							  						</xsl:choose>
												</td>
											</xsl:otherwise>
										</xsl:choose>
			      				</xsl:if>
			           		</xsl:for-each>
			           
			           		<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value[@access=$READ_ONLY]">
			  			 		<xsl:variable name="valueNameR"><xsl:value-of select="@name" /></xsl:variable>
			                	<xsl:if test="concat('sql:', normalize-space($valueNameR))=$nameOfCurrentNode">
			  							<xsl:choose>
			  								<xsl:when test="string-length(@select) > 0">
			  									<td>
			  										<xsl:variable name="fkName" select="concat('gtt_fkey', substring-before(substring-after(@select, 'gtt_fkey'), ','))" />
			  										<xi:include href="{$cocoonProtocol}/fkAliasControl/{$nameOfDatasource}/{$tableName}/{$valueNameR}/Text/{$valueOfCurrentNode}/{$fkName}" />
			  										<input type="hidden" value="{$valueOfCurrentNode}" name="{$tableName}.{substring($nameOfCurrentNode,5)}"/>
			  									</td>
			  								</xsl:when>
			  								
			  								<xsl:when test="normalize-space(@type) = $BLOB_TYPE_IMAGE"><!-- blos are shown separately --></xsl:when>
			  								
			  								<xsl:when test="normalize-space(@type) = $BLOB_TYPE_BINARY"><!-- blos are shown separately --></xsl:when>
			  								
			  								<xsl:otherwise>
			  									<td>
			  										<xsl:value-of select="$valueOfCurrentNode" />
			  										<input type="hidden" value="{$valueOfCurrentNode}" name="{$tableName}.{substring($nameOfCurrentNode,5)}"/>
			  									</td>	
			  								</xsl:otherwise>
			  							</xsl:choose>
			      				</xsl:if>
			           		</xsl:for-each >
	
						</xsl:when>
	 					
	 					<!-- column does not match current table (foreign key table)-->
	 					<xsl:otherwise />
	 					
	 				</xsl:choose>
	    		</xsl:for-each >
	
		
			</form>
			
			<!-- show blobs -->
			<form action="{$rootURL}/process/{$nameOfDatasource}/{$tableName}/{$rowsPerPage}/{$aktBlockNr}/{$orderColumn}/{$order}/{$filterColumn}/{$filterCriteria}" method="post" enctype="multipart/form-data">
				
				<xsl:for-each select="*">	
					
					<!-- adding the prefix "sql:" that not too many changes in code are necessary TODO: remove the prefix "sql:"--> 
					<xsl:variable name="nameOfCurrentNode"><xsl:value-of select="name()" /></xsl:variable>
					<xsl:variable name="valueOfCurrentNode"><xsl:value-of select="current()" /></xsl:variable>
					<xsl:variable name="isFkTableFlag"><xsl:value-of select="substring-before(name(), 'gtt_')" /></xsl:variable>

					<!-- print out keys as hidden fields-->
					<xsl:choose>
	 					<xsl:when test="$isFkTableFlag != 'o'">
					
							<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/keys/key">
			  			 		<xsl:variable name="keyNameR"><xsl:value-of select="@name" /></xsl:variable>
			                	<xsl:if test="concat('sql:', normalize-space($keyNameR))=$nameOfCurrentNode">			
				      				<input type="hidden" value="{$valueOfCurrentNode}" name="{$tableName}.{substring($nameOfCurrentNode,5)}"/>
			      				</xsl:if>	
			           		</xsl:for-each>
			           
							<!-- print out value columns as plain text or text field -->
							<xsl:for-each select="document(concat('resource://',$pathToDescriptor))/root/table/values/value">
			  			 		<xsl:variable name="valueName"><xsl:value-of select="@name" /></xsl:variable>
			                	<xsl:if test="concat('sql:', normalize-space($valueName))=$nameOfCurrentNode">
			  						
			  						<xsl:choose>
				  						<xsl:when test="normalize-space(@type) = $BLOB_TYPE_IMAGE">	
				  							<td>	
						  						<xsl:choose>			
						  							<xsl:when test="$valueOfCurrentNode = $NO_VALUE">
						  								<xsl:value-of select="$NO_VALUE" />				
						  							</xsl:when>				
						  							<xsl:otherwise>			
						  								<img src="{$pathToLargeObjectCache}/{$valueOfCurrentNode}" />			
						  							</xsl:otherwise>			
						  						</xsl:choose>				
						  						<br />					  										
					  							<xsl:if test="@access = $READ_WRITE">				
													<input name="{$tableName}.{$valueName}" type="file"/>
				    								<input type="hidden" name="blobColumn" value = "{$tableName}.{$valueName}"/>
				    								<input type="submit" name="submit" value="Upload" class="button"/>
						      					</xsl:if>
											</td>
										</xsl:when>
				  								
										<xsl:when test="normalize-space(@type) = $BLOB_TYPE_BINARY">
											<td>
						  						<xsl:choose>			
						  							<xsl:when test="$valueOfCurrentNode = $NO_VALUE">
						  								<xsl:value-of select="$NO_VALUE" />				
						  							</xsl:when>			
						  							<xsl:otherwise>			
						  								<a href="{$pathToLargeObjectCache}/{$valueOfCurrentNode}" >Object</a>			
						  							</xsl:otherwise>			
						  						</xsl:choose>
					  										
					  							<xsl:if test="@access = $READ_WRITE">
						      						<input name="{$tableName}.{$valueName}" type="file"/>				
						      						<input type="hidden" name="blobColumn" value = "{$tableName}.{$valueName}"/>
				    								<input type="submit" name="submit" value="Upload" class="button"/>
						      					</xsl:if>
											</td>
										</xsl:when>			
				  					</xsl:choose>
			      				
			      				</xsl:if>
			           		</xsl:for-each>
	           			
	           			</xsl:when>
	           			
	           			<!--foreign key column is not displayed -->
	           			<xsl:otherwise />
	           		</xsl:choose>
	           		
	    		</xsl:for-each >
			
			</form>

		</tr>
	
	</xsl:template>

</xsl:stylesheet>
