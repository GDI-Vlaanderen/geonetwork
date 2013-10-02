<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    ISO19110 support
    
    Feature catalogue support:
     * feature catalogue description
     * class/attribute/property/list of values viewing/editing support
    
    Known limitation:
     * iso19110 links between elements (eg. inheritance)
     * partial support of association and feature operation description
     
     @author francois
     @author mathieu
     @author sppigot
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gfc="http://www.isotc211.org/2005/gfc" xmlns:gmx="http://www.isotc211.org/2005/gmx"
  xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:geonet="http://www.fao.org/geonetwork"
  exclude-result-prefixes="gfc gmx gmd gco geonet">

  <xsl:include href="metadata-iso19110-view.xsl"/>
  
  <!-- main template - the way into processing iso19110 -->
  <xsl:template name="metadata-iso19110">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="embedded"/>
    
    <xsl:apply-templates mode="iso19110" select="." >
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="embedded" select="$embedded" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="iso19110CompleteTab">
    <xsl:param name="tabLink"/>
    <xsl:param name="schema"/>
    
    <xsl:if test="/root/gui/config/metadata-tab/advanced">
      <xsl:call-template name="mainTab">
        <xsl:with-param name="title" select="/root/gui/strings/byPackage"/>
        <xsl:with-param name="default">advanced</xsl:with-param>
        <xsl:with-param name="menu">
          <item label="byPackage">advanced</item>
        </xsl:with-param>
      </xsl:call-template>
      </xsl:if>
  </xsl:template>

    <!-- =================================================================== -->
    <!-- default: in simple mode just a flat list -->
    <!-- =================================================================== -->

    <xsl:template mode="iso19110" match="*|@*">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <!-- do not show empty elements in view mode -->
        <xsl:variable name="adjustedSchema">
            <xsl:choose>
                <xsl:when test="namespace-uri(.) != 'http://www.isotc211.org/2005/gfc'">
                    <xsl:text>iso19139</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$schema"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="element" select=".">
                    <xsl:with-param name="schema" select="$adjustedSchema"/>
                    <xsl:with-param name="edit" select="true()"/>
                    <xsl:with-param name="flat" select="$currTab='simple'"/>
                </xsl:apply-templates>
            </xsl:when>

            <xsl:otherwise>
                <xsl:variable name="empty">
                    <xsl:apply-templates mode="iso19110IsEmpty" select="."/>
                </xsl:variable>
                <xsl:if test="$empty!=''">
                    <xsl:apply-templates mode="element" select=".">
                        <xsl:with-param name="schema" select="$adjustedSchema"/>
                        <xsl:with-param name="edit" select="false()"/>
                        <xsl:with-param name="flat" select="$currTab='simple'"/>
                    </xsl:apply-templates>
                </xsl:if>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- ===================================================================== -->
    <!-- these elements should be boxed -->
    <!-- ===================================================================== -->

    <xsl:template mode="iso19110" match="gfc:*[gfc:FC_FeatureType]|
        gfc:*[gfc:FC_AssociationRole]|
        gfc:*[gfc:FC_AssociationOperation]|
        gfc:listedValue|gfc:FC_ListedValue|gfc:constrainedBy|gfc:inheritsFrom|gfc:inheritsTo">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:apply-templates mode="complexElement" select=".">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ===================================================================== -->
    <!-- some gco: elements -->
    <!-- ===================================================================== -->

    <xsl:template mode="iso19110"
        match="gfc:*[gco:CharacterString|gco:Date|gco:DateTime|gco:Integer|gco:Decimal|gco:Boolean|gco:Real|gco:Measure]|
        gmd:*[gco:CharacterString|gco:Date|gco:DateTime|gco:Integer|gco:Decimal|gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gco:Scale|gco:RecordType]|
        gmx:*[gco:CharacterString|gco:Date|gco:DateTime|gco:Integer|gco:Decimal|gco:Boolean|gco:Real|gco:Measure]">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        
        <!-- Generate a textarea when relevant -->
        <xsl:variable name="rows">
            <xsl:choose>
                <xsl:when test="name(.)='gfc:description' or 
                    (name(.)='gfc:definition' and name(parent::*)!='gfc:FC_ListedValue')
                    ">3</xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:call-template name="iso19139String">
            <xsl:with-param name="schema">
                <xsl:choose>
                    <xsl:when test="namespace-uri(.) != 'http://www.isotc211.org/2005/gfc'">
                        <xsl:text>iso19139</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$schema"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="rows" select="$rows">
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template mode="iso19110"
        match="gfc:*[gmx:FileName]" priority="2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:call-template name="file-upload">
        	<xsl:with-param name="schema" select="$schema"/>
        	<xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>
	</xsl:template>

    <!-- ================================================================= -->
    <!-- codelists -->
    <!-- ================================================================= -->

    <xsl:template mode="iso19110" match="gfc:*[*/@codeList]|gmd:*[*/@codeList]">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:call-template name="iso19139Codelist">
            <xsl:with-param name="schema">
                <xsl:choose>
                    <xsl:when test="namespace-uri(.) != 'http://www.isotc211.org/2005/gfc'">
                        <xsl:text>iso19139</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$schema"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>
    </xsl:template>


	<!-- Element set on save by update-fixed-info. -->
    <xsl:template mode="iso19110" match="gmx:versionDate|gfc:versionDate" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:apply-templates mode="simpleElement" select=".">
			<xsl:with-param name="schema"  select="$schema"/>
			<xsl:with-param name="edit"    select="false()"/>
			<xsl:with-param name="text">
				<xsl:choose>
					<xsl:when test="normalize-space(gco:*)=''">
						<span class="info">
							- <xsl:value-of select="/root/gui/strings/setOnSave"/> - 
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="gco:*"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

    <!-- ============================================================================= -->
    <!--
        date (format = %Y-%m-%d)
        editionDate
        dateOfNextUpdate
        mdDateSt is not editable (!we use DateTime instead of only Date!)
    -->
    <!-- ============================================================================= -->

    <xsl:template mode="iso19110"
        match="gmd:editionDate|gmd:dateOfNextUpdate"
        priority="2">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <xsl:choose>
            <xsl:when test="$edit=true()">
                <xsl:apply-templates mode="simpleElement" select=".">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                    <xsl:with-param name="text">
                        <xsl:variable name="ref"
                            select="gco:Date/geonet:element/@ref|gco:DateTime/geonet:element/@ref"/>
						<xsl:variable name="format">
							<xsl:choose>
								<xsl:when test="gco:Date"><xsl:text>%Y-%m-%d</xsl:text></xsl:when>
								<xsl:otherwise><xsl:text>%Y-%m-%dT%H:%M:00</xsl:text></xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						
						<xsl:call-template name="calendar">
							<xsl:with-param name="ref" select="$ref"/>
							<xsl:with-param name="date" select="gco:DateTime/text()|gco:Date/text()"/>
							<xsl:with-param name="format" select="$format"/>
						</xsl:call-template>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="iso19139String">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ==================================================================== -->
    <!-- Do not display those elements:
     * hide nested featureType elements
     * hide definition reference elements
     * inheritance : does not support linking feature catalogue objects (eg. to indicate subtype or supertype) 
    -->
    <xsl:template mode="iso19110" match="gfc:featureType[ancestor::gfc:featureType]|
        gfc:definitionReference|
        gfc:valueMeasurementunit|
        gfc:featureCatalogue|
        gfc:FC_InheritanceRelation/gfc:featureCatalogue|
        @gco:isoType" priority="100"/>
    
    <xsl:template mode="elementEP" match="
        geonet:child[@name='definitionReference']|
        geonet:child[@name='featureCatalogue']|
        geonet:child[@name='valueMeasurementunit']|
        gfc:FC_InheritanceRelation/geonet:child[@name='subtype']|
        gfc:FC_InheritanceRelation/geonet:child[@name='supertype']
        " priority="100"/>
    
    <!-- ==================================================================== -->
    <!-- Metadata -->
    <!-- ==================================================================== -->

    <xsl:template mode="iso19110" match="gfc:FC_FeatureCatalogue|*[@gco:isoType='gfc:FC_FeatureCatalogue']">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:param name="embedded"/>

        <xsl:call-template name="iso19110Simple">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="flat" select="$currTab='simple'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- ============================================================================= -->
    <!--
        simple mode; ISO order is:
    -->
    <!-- ============================================================================= -->

    <xsl:template name="iso19110Simple">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:param name="flat"/>

        <xsl:call-template name="iso19110Metadata">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>

    </xsl:template>

    <!-- ===================================================================== -->
    <!-- === iso19110 brief formatting === -->
    <!-- ===================================================================== -->
  
    <xsl:template mode="superBrief" match="gfc:FC_FeatureCatalogue|gfc:FC_FeatureType">
      <xsl:variable name="uuid" select="geonet:info/uuid"/>
      <id><xsl:value-of select="geonet:info/id"/></id>
      <uuid><xsl:value-of select="$uuid"/></uuid>
        <xsl:if test="gmx:name|gfc:name|gfc:typeName">
        <title>
          <xsl:value-of select="gfc:name/gco:CharacterString|gfc:typeName/gco:LocalName"/>
        </title>
      </xsl:if>
    </xsl:template>
    
    <xsl:template name="iso19110Brief">
        <metadata>
            <xsl:variable name="id" select="geonet:info/id"/>
            <xsl:variable name="uuid" select="geonet:info/uuid"/>

            <xsl:if test="gmx:name or gfc:name">
                <title>
                    <xsl:value-of select="gmx:name/gco:CharacterString|gfc:name/gco:CharacterString|gfc:typeName/gco:LocalName"/>
                </title>
            </xsl:if>

            <xsl:if test="gmx:scope or gfc:scope">
                <abstract>
                    <xsl:value-of select="gmx:scope/gco:CharacterString|gfc:scope/gco:CharacterString"/>
                </abstract>
            </xsl:if>

			<geonet:info>
				<xsl:copy-of select="geonet:info/*"/>
				<category internal="true">featureCatalogue</category>
			</geonet:info>
        </metadata>
    </xsl:template>

    <!-- ============================================================================= -->

    <xsl:template name="iso19110Metadata">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>

        <!-- if the parent is root then display fields not in tabs -->
        <xsl:choose>
            <xsl:when test="name(..)='root'">
                <xsl:call-template name="complexElementGui">
                    <xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name" select="name(.)"/>
							<xsl:with-param name="schema" select="$schema"/>
						</xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="content">
		                <xsl:apply-templates mode="elementEP"
		                    select="@uuid">
		                    <xsl:with-param name="schema" select="$schema"/>
		                    <xsl:with-param name="edit" select="false()"/>
		                </xsl:apply-templates>
		
		                <xsl:apply-templates mode="elementEP"
		                    select="gmx:name|gfc:name|geonet:child[@name='name']">
		                    <xsl:with-param name="schema" select="$schema"/>
		                    <xsl:with-param name="edit" select="$edit"/>
		                </xsl:apply-templates>
		
		                <xsl:apply-templates mode="elementEP" select="gmx:scope|gfc:scope|geonet:child[@name='scope']">
		                    <xsl:with-param name="schema" select="$schema"/>
		                    <xsl:with-param name="edit" select="$edit"/>
		                </xsl:apply-templates>
		
		                <xsl:apply-templates mode="elementEP" select="gmx:fieldOfApplication|gfc:fieldOfApplication|geonet:child[@name='fieldOfApplication']">
		                    <xsl:with-param name="schema" select="$schema"/>
		                    <xsl:with-param name="edit" select="$edit"/>
		                </xsl:apply-templates>
		
		                <xsl:apply-templates mode="elementEP" select="gmx:versionNumber|gfc:versionNumber|geonet:child[@name='versionNumber']">
		                    <xsl:with-param name="schema" select="$schema"/>
		                    <xsl:with-param name="edit" select="$edit"/>
		                </xsl:apply-templates>
		
		                <xsl:apply-templates mode="elementEP" select="gmx:versionDate|gfc:versionDate|geonet:child[@name='versionDate']">
		                    <xsl:with-param name="schema" select="$schema"/>
		                    <xsl:with-param name="edit" select="$edit"/>
		                </xsl:apply-templates>
		
		                <xsl:apply-templates mode="elementEP" select="gfc:producer|geonet:child[@name='producer']">
		                    <xsl:with-param name="schema" select="$schema"/>
		                    <xsl:with-param name="edit" select="$edit"/>
		                </xsl:apply-templates>
		
		                <xsl:apply-templates mode="elementEP" select="gfc:functionalLanguage|geonet:child[@name='functionalLanguage']">
		                    <xsl:with-param name="schema" select="$schema"/>
		                    <xsl:with-param name="edit" select="$edit"/>
		                </xsl:apply-templates>

				        <xsl:apply-templates mode="elementEP" select="gfc:featureType">
				            <xsl:with-param name="schema" select="$schema"/>
				            <xsl:with-param name="edit" select="$edit"/>
				            <xsl:with-param name="flat" select="$flat"/>
				        </xsl:apply-templates>
				
				        <xsl:apply-templates mode="elementEP" select="geonet:child[@name='featureType' and @prefix='gfc']">
				            <xsl:with-param name="schema" select="$schema"/>
				            <xsl:with-param name="edit" select="$edit"/>
				        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <!-- otherwise, display everything because we have embedded gfc:FC_FeatureCatalogue -->

            <xsl:otherwise>
                <xsl:apply-templates mode="elementEP" select="*">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                </xsl:apply-templates>

		        <xsl:apply-templates mode="elementEP" select="gfc:featureType">
		            <xsl:with-param name="schema" select="$schema"/>
		            <xsl:with-param name="edit" select="$edit"/>
		            <xsl:with-param name="flat" select="$flat"/>
		        </xsl:apply-templates>
		
		        <xsl:apply-templates mode="elementEP" select="geonet:child[@name='featureType' and @prefix='gfc']">
		            <xsl:with-param name="schema" select="$schema"/>
		            <xsl:with-param name="edit" select="$edit"/>
		        </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- Display producer as contact in ISO 19139 -->
    <xsl:template mode="iso19110" match="gfc:producer">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        
        <xsl:call-template name="contactTemplate">
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="schema" select="$schema"/>
        </xsl:call-template>
    </xsl:template>



    <xsl:template mode="iso19110" match="gfc:carrierOfCharacteristics/gfc:FC_FeatureAttribute">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        <xsl:variable name="content">
		<xsl:apply-templates mode="elementEP" select="gfc:memberName|geonet:child[string(@name)='memberName']">
		    <xsl:with-param name="schema" select="$schema"/>
		    <xsl:with-param name="edit"   select="$edit"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gfc:definition|geonet:child[string(@name)='definition']">
		    <xsl:with-param name="schema" select="$schema"/>
		    <xsl:with-param name="edit"   select="$edit"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gfc:code|geonet:child[string(@name)='code']">
		    <xsl:with-param name="schema" select="$schema"/>
		    <xsl:with-param name="edit"   select="$edit"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gfc:cardinality|geonet:child[string(@name)='cardinality']">
		    <xsl:with-param name="schema" select="$schema"/>
		    <xsl:with-param name="edit"   select="$edit"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gfc:featureType|geonet:child[string(@name)='featureType']">
		    <xsl:with-param name="schema" select="$schema"/>
		    <xsl:with-param name="edit"   select="$edit"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates mode="elementEP" select="gfc:valueType|geonet:child[string(@name)='valueType']">
		    <xsl:with-param name="schema" select="$schema"/>
		    <xsl:with-param name="edit"   select="$edit"/>
		</xsl:apply-templates>
		
		 <xsl:choose>
		    <xsl:when test="$edit=true() or $currTab!='simple'">
		        <xsl:apply-templates mode="elementEP" select="gfc:listedValue|geonet:child[string(@name)='listedValue']">
		            <xsl:with-param name="schema" select="$schema"/>
		            <xsl:with-param name="edit" select="$edit"/>
		        </xsl:apply-templates>        
		    </xsl:when>
		    <xsl:otherwise>
		        <xsl:if test="gfc:listedValue">
<!--
		            <xsl:call-template name="complexElementGui">
		                <xsl:with-param name="title">
		                    <xsl:value-of select="/root/gui/schemas/iso19110/labels/element[@name='gfc:listedValue']/label"/>
		                    <xsl:text> </xsl:text>
		                    (<xsl:value-of select="/root/gui/schemas/iso19110/labels/element[@name='gfc:label']/label"/>
		                    [<xsl:value-of select="/root/gui/schemas/iso19110/labels/element[@name='gfc:code']/label"/>] :
		                    <xsl:value-of select="/root/gui/schemas/iso19110/labels/element[@name='gfc:definition']/label"/>)
		                </xsl:with-param>
		                <xsl:with-param name="content">
		                
		                <ul class="md">
		                    <xsl:for-each select="gfc:listedValue/gfc:FC_ListedValue">
		                        <li>
		                            <b><xsl:value-of select="gfc:label/gco:CharacterString"/></b> 
		                            [<xsl:value-of select="gfc:code/gco:CharacterString"/>] :
		                            <xsl:value-of select="gfc:definition/gco:CharacterString"/>
		                        </li>
		                    </xsl:for-each>
		                </ul>
		                </xsl:with-param>
		            </xsl:call-template>
-->
		            <xsl:call-template name="complexElementGui">
						<xsl:with-param name="title">
							<xsl:call-template name="getTitle">
								<xsl:with-param name="name" select="'gfc:listedValue'"/>
								<xsl:with-param name="schema" select="$schema"/>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="content">
							<table class="gn">
	                        <tbody>
								<tr>
									<th class="main"><label class="" for="_"><xsl:value-of select="/root/gui/schemas/iso19110/labels/element[@name='gfc:code']/label"/></label></th>
									<th class="main"><label class="" for="_"><xsl:value-of select="/root/gui/schemas/iso19110/labels/element[@name='gfc:label']/label"/></label></th>
									<th class="main"><label class="" for="_"><xsl:value-of select="/root/gui/schemas/iso19110/labels/element[@name='gfc:definition']/label"/></label></th>
								</tr>
			                    <xsl:for-each select="gfc:listedValue/gfc:FC_ListedValue">
			                    	<tr>
				                        <td>
				                            <xsl:value-of select="gfc:code/gco:CharacterString"/>
			                            </td>
				                        <td>
				                            <xsl:value-of select="gfc:label/gco:CharacterString"/> 
			                            </td>
				                        <td>
				                            <xsl:value-of select="gfc:definition/gco:CharacterString"/>
		                            	</td>
			                    	</tr>
			                    </xsl:for-each>
		                    </tbody>
							</table>
						</xsl:with-param>
					</xsl:call-template>
		        </xsl:if>
		    </xsl:otherwise>
		</xsl:choose>
        </xsl:variable>
	    <xsl:variable name="carrierOfCharacteristicsElementName" select="name(..)" />
	    <xsl:variable name="previousCarrierOfCharacteristicsSiblingsCount" select="count(../preceding-sibling::*[name(.) = $carrierOfCharacteristicsElementName])" />
       	<xsl:if test="$previousCarrierOfCharacteristicsSiblingsCount=0 and $edit=true()">
			<xsl:apply-templates mode="addCarrierOfCharacteristicsElement" select="..">
	            <xsl:with-param name="schema" select="$schema"/>
	            <xsl:with-param name="edit"   select="$edit"/>
			</xsl:apply-templates>
       	</xsl:if>
<!--
	    <xsl:variable name="featureAttributeElementName" select="name(..)" />
	    <xsl:variable name="previousFeatureAttributeSiblingsCount" select="count(preceding-sibling::*[name(.) = $featureAttributeElementName])" />
       	<xsl:if test="$previousFeatureAttributeSiblingsCount=0 and $edit=true()">
			<xsl:apply-templates mode="addFeatureAttributeElement" select="..">
	            <xsl:with-param name="schema" select="$schema"/>
	            <xsl:with-param name="edit"   select="$edit"/>
			</xsl:apply-templates>
       	</xsl:if>
-->
        <xsl:apply-templates mode="complexElement" select="..">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit" select="$edit"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:apply-templates>

    </xsl:template>
    
    <!-- handle cardinality edition 
        Update fixed info take care of setting UnlimitedInteger attribute.
    -->
    <xsl:template mode="iso19110" match="gfc:cardinality">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        
        <!-- Variables -->
        <xsl:variable name="minValue" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:lower/gco:Integer"/>
        <xsl:variable name="maxValue" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:upper/gco:UnlimitedInteger"/>
        <xsl:variable name="isInfinite" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:upper/gco:UnlimitedInteger/@isInfinite"/>
        <xsl:variable name="minText">
	        <xsl:choose>
	            <xsl:when test="$edit=true()">
         			<select name="_{$minValue/geonet:element/@ref}" class="md" size="1">
	                    <option value=""/>
	                    <option value="0">
	                        <xsl:if test="$minValue = '0'">
	                            <xsl:attribute name="selected"/>
	                        </xsl:if>
	                        <xsl:text>0</xsl:text>
	                    </option>
	                    <option value="1">
	                        <xsl:if test="$minValue = '1'">
	                            <xsl:attribute name="selected"/>
	                        </xsl:if>
	                        <xsl:text>1</xsl:text>
	                    </option>
	                </select>
	            </xsl:when>
	            <xsl:otherwise>
					<xsl:value-of select="$minValue"/>
	            </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="maxText">
	        <xsl:choose>
	            <xsl:when test="$edit=true()">
					<select name="minCard" class="md" size="1" onchange="updateUpperCardinality('_{$maxValue/geonet:element/@ref}', this.value)">
					    <option value=""/>
					    <option value="0">
					        <xsl:if test="$maxValue = '0'">
					            <xsl:attribute name="selected"/>
					        </xsl:if>
					        <xsl:text>0</xsl:text>
					    </option>
					    <option value="1">
					        <xsl:if test="$maxValue = '1'">
					            <xsl:attribute name="selected"/>
					        </xsl:if>
					        <xsl:text>1</xsl:text>
					    </option>
					    <option value="n">
					        <xsl:if test="$isInfinite = 'true'">
					            <xsl:attribute name="selected"/>
					        </xsl:if>
					        <xsl:text>n</xsl:text>
					    </option>
					</select>
					
					<!-- Hidden value to post -->
					<input type="hidden" name="_{$maxValue/geonet:element/@ref}" id="_{$maxValue/geonet:element/@ref}" value="{$maxValue}" />
					<input type="hidden" name="_{$maxValue/geonet:element/@ref}_isInfinite" id="_{$maxValue/geonet:element/@ref}_isInfinite" value="{$isInfinite}"/>
	            </xsl:when>
	            <xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$isInfinite = 'true'">
						<xsl:text>n</xsl:text>
					 </xsl:when>
					 <xsl:when test="$maxValue != ''">
						<xsl:value-of select="$maxValue"/>
						</xsl:when>
					</xsl:choose>
	            </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
		<xsl:apply-templates mode="simpleElement" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:lower">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="title">
				<xsl:call-template name="getTitle">
					<xsl:with-param name="name" select="'gco:lower'"/>
					<xsl:with-param name="schema" select="$schema"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="text" select="$minText"/>
		</xsl:apply-templates>
		<xsl:apply-templates mode="simpleElement" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:upper">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="title">
				<xsl:call-template name="getTitle">
					<xsl:with-param name="name" select="'gco:upper'"/>
					<xsl:with-param name="schema" select="$schema"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="text" select="$maxText"/>
		</xsl:apply-templates>
    </xsl:template>
    
</xsl:stylesheet>
