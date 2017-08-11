<?xml version="1.0" encoding="UTF-8"?>
<!--
  All layout templates
  -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exslt="http://exslt.org/common" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:geonet="http://www.fao.org/geonetwork" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:date="http://exslt.org/dates-and-times"
  xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon"
  exclude-result-prefixes="exslt xlink gco gmd geonet svrl saxon date xs">

  <xsl:import href="../text-utilities.xsl"/>

  <xsl:include href="../utils-fn.xsl"/>
  <xsl:include href="../utils.xsl"/>
  <xsl:include href="utility.xsl"/>
  <xsl:include href="layout-simple.xsl"/>
  <xsl:include href="layout-xml.xsl"/>
  <xsl:include href="controls.xsl"/>

  <xsl:template mode="schema" match="*">
    <xsl:choose>
      <xsl:when test="string(geonet:info/schema)!=''">
        <xsl:value-of select="geonet:info/schema"/>
      </xsl:when>
      <xsl:otherwise>UNKNOWN</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    hack to extract geonet URI; I know, I could have used a string constant like
    <xsl:variable name="geonetUri" select="'http://www.fao.org/geonetwork'"/>
    but this is more interesting
  -->
  <xsl:variable name="geonetNodeSet">
    <geonet:dummy/>
  </xsl:variable>

  <xsl:variable name="geonetUri">
    <xsl:value-of select="namespace-uri(exslt:node-set($geonetNodeSet)/*)"/>
  </xsl:variable>

  <xsl:variable name="currTab">
    <xsl:choose>
      <xsl:when test="/root/gui/currTab">
        <xsl:value-of select="/root/gui/currTab"/>
      </xsl:when>
      <xsl:otherwise>simple</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- 
  Control mode for current tab. Flat mode does not display non existing elements.
  -->
  <xsl:variable name="flat" select="/root/gui/config/metadata-tab/*[name(.)=$currTab]/@flat"/>
  <xsl:variable name="ancestorException"
    select="/root/gui/config/metadata-tab/*[name(.)=$currTab]/ancestorException/@for"/>
  <xsl:variable name="elementException"
    select="/root/gui/config/metadata-tab/*[name(.)=$currTab]/exception/@for"/>


  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- main schema mode selector -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template mode="elementEP" match="*|@*">
    <xsl:param name="schema">
      <xsl:apply-templates mode="schema" select="."/>
    </xsl:param>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="embedded"/>
    <xsl:variable name="schemaTemplate" select="concat('metadata-',$schema)"/>
    <saxon:call-template name="{$schemaTemplate}">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit" select="$edit"/>
      <xsl:with-param name="embedded" select="$embedded"/>
    </saxon:call-template>

  </xsl:template>

  <!--
	new children
	View mode variables (ie. $flat, $ancestorException and $elementException) are defined in XSL header.
	-->
  <xsl:template mode="elementEP" match="geonet:child">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="embedded"/>
    
    <!-- draw child element place holder if
			- child is an OR element or
			- there is no other element with the name of this placeholder 
		-->
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="@prefix=''">
          <xsl:value-of select="@name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(@prefix,':',@name)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- build a qualified name with COLON as the separator -->
    <xsl:variable name="qname">
      <xsl:choose>
        <xsl:when test="@prefix=''">
          <xsl:value-of select="@name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(@prefix,'COLON',@name)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="parentName" select="../geonet:element/@ref|@parent"/>
    <xsl:variable name="max"
      select="if (../geonet:element/@max) then ../geonet:element/@max else @max"/>
    <xsl:variable name="prevBrother" select="preceding-sibling::*[1]"/>

    <!--
			Exception for:
			 * gmd:graphicOverview because GeoNetwork manage thumbnail using specific interface 
			 for thumbnail and large_thumbnail but user should be able to add	thumbnail using a simple URL.
			 * from config-gui.xml (ancestor or element)
		-->
    <xsl:variable name="exception"
      select="
		  @name='graphicOverview'
			or count(ancestor::*[contains($ancestorException, local-name())]) > 0
			or contains($elementException, @name)
			"/>
    <xsl:variable name="isXLinked" select="count(ancestor-or-self::node()[@xlink:href]) > 0"/>
    <xsl:if test="(not($flat) or $exception) and not($isXLinked)">
      <xsl:if test="(geonet:choose or name($prevBrother)!=$name)">
        
        <xsl:variable name="text">
          <xsl:if test="geonet:choose">

            <xsl:variable name="defaultSelection" select="/root/gui/config/editor-default-substitutions/element[@name=$name]/@default" />

            <xsl:variable name="options">
              <options>
                <xsl:for-each select="geonet:choose">
                  <option name="{@name}">
                    <xsl:if test="@name = $defaultSelection">
                    <xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>

                    <xsl:call-template name="getTitle">
                      <xsl:with-param name="name" select="@name"/>
                      <xsl:with-param name="schema" select="$schema"/>
                    </xsl:call-template>
                  </option>
                </xsl:for-each>
              </options>
            </xsl:variable>
            
            <select class="md" name="_{$parentName}_{$qname}" size="1">
              <xsl:if test="$isXLinked">
                <xsl:attribute name="disabled">disabled</xsl:attribute>
              </xsl:if>
              <xsl:for-each select="exslt:node-set($options)//option">
                <xsl:sort select="."/>
                <option value="{@name}"><xsl:value-of select="concat(., ' (', @name, ')')"/></option>
              </xsl:for-each>
            </select>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="id" select="@uuid"/>
        <xsl:variable name="addLink">
          <xsl:choose>
            <xsl:when test="geonet:choose">
              <xsl:value-of
                select="concat('doNewORElementAction(',$apos,'metadata.elem.add.new',$apos,',',$parentName,',',$apos,$name,$apos,',document.mainForm._',$parentName,'_',$qname,'.value,',$apos,$id,$apos,',',$apos,@action,$apos,',',$max,');')"
              />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of
                select="concat('doNewElementAction(',$apos,'metadata.elem.add.new',$apos,',',$parentName,',',$apos,$name,$apos,',',$apos,$id,$apos,',',$apos,@action,$apos,',',$max,');')"
              />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="addXMLFragment">
          <!-- Add the XML fragment selector for lonely geonet:child elements -->
          <xsl:variable name="function">
            <xsl:apply-templates mode="addXMLFragment" select="."/>
          </xsl:variable>
          <xsl:if test="normalize-space($function)!=''">
            <xsl:value-of
              select="concat('javascript:', $function, '(',$parentName,',',$apos,$name,$apos,');')"
            />
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="addXmlFragmentSubTemplate">
          <xsl:call-template name="addXMLFragment">
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="subtemplate" select="true()"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="helpLink">
          <xsl:call-template name="getHelpLink">
            <xsl:with-param name="name" select="$name"/>
            <xsl:with-param name="schema" select="$schema"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="simpleElementGui">
          <xsl:with-param name="title">
            <xsl:call-template name="getTitle">
              <xsl:with-param name="name" select="$name"/>
              <xsl:with-param name="schema" select="$schema"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="addLink" select="$addLink"/>
          <xsl:with-param name="addXMLFragment" select="$addXMLFragment"/>
          <xsl:with-param name="addXMLFragmentSubTemplate" select="$addXmlFragmentSubTemplate"/>
          <xsl:with-param name="helpLink" select="$helpLink"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="id" select="$id"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- callbacks from schema templates -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template mode="element" match="*|@*">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="flat" select="false()"/>
    <xsl:param name="embedded"/>

    <xsl:choose>
      <!-- has children or attributes, existing or potential -->
      <xsl:when
        test="*[namespace-uri(.)!=$geonetUri]|@*|geonet:child|geonet:element/geonet:attribute">
        <xsl:choose>

          <!-- display as a list -->
          <xsl:when test="$flat=true()">

            <!-- if it does not have children show it as a simple element -->
            <xsl:if
              test="not(*[namespace-uri(.)!=$geonetUri]|geonet:child|geonet:element/geonet:attribute)">
              <xsl:apply-templates mode="simpleElement" select=".">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit" select="$edit"/>
              </xsl:apply-templates>
            </xsl:if>

            <!-- existing and new children -->
            <xsl:apply-templates mode="elementEP"
              select="*[namespace-uri(.)!=$geonetUri]|geonet:child">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit" select="$edit"/>
            </xsl:apply-templates>
          </xsl:when>

          <!-- display boxed -->
          <xsl:otherwise>
            <xsl:apply-templates mode="complexElement" select=".">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit" select="$edit"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- neither children nor attributes, just text -->
      <xsl:otherwise>
        <xsl:apply-templates mode="simpleElement" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <xsl:template mode="simpleElement" match="*">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="editAttributes" select="true()"/>
    <xsl:param name="title">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:param name="text">
      <xsl:call-template name="getElementText">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit" select="$edit"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:param name="helpLink">
      <xsl:call-template name="getHelpLink">
        <xsl:with-param name="name" select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:param>
    
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:call-template name="editSimpleElement">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="editAttributes" select="$editAttributes"/>
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="helpLink" select="$helpLink"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="showSimpleElement">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="helpLink" select="$helpLink"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="simpleElement" match="@*"/>

  <xsl:template name="simpleAttribute" mode="simpleAttribute" match="@*" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="title">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:param name="text">
      <xsl:call-template name="getAttributeText">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit" select="$edit"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:param name="helpLink">
      <xsl:call-template name="getHelpLink">
        <xsl:with-param name="name" select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:variable name="name" select="name(.)"/>
        <xsl:variable name="id" select="concat('_', ../geonet:element/@ref, '_', $name)"/>

        <xsl:call-template name="editAttribute">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="id" select="concat($id, '_block')"/>
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="helpLink" select="$helpLink"/>
          <xsl:with-param name="name" select="$name"/>
          <xsl:with-param name="elemId" select="geonet:element/@uuid"/>
          <xsl:with-param name="removeLink">
            <xsl:if test="count(../geonet:attribute[@name=$name and @del])!=0">
              <xsl:value-of
                select="concat('doRemoveAttributeAction(',$apos,'/metadata.attr.delete',$apos,',',$apos,$id,$apos,',',$apos,../geonet:element/@ref,$apos,',', $apos,$id,$apos,',',$apos,$apos,');')"
              />
            </xsl:if>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="showSimpleElement">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="helpLink" select="$helpLink"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Display non existing geonet:attribute -->
  <xsl:template mode="simpleAttribute" match="geonet:attribute" priority="2">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="title">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="@name"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:param name="text"/>
    <xsl:param name="helpLink">
      <xsl:call-template name="getHelpLink">
        <xsl:with-param name="name" select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:variable name="name" select="@name"/>

    <!-- Display non existing child only -->
    <xsl:if test="$edit=true() and count(../@*[name(.)=$name])=0">
      <xsl:variable name="id" select="concat('_', ../geonet:element/@ref, '_', replace(@name, ':', 'COLON'))"/>
      <xsl:call-template name="editAttribute">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="title" select="$title"/>
        <xsl:with-param name="text" select="$text"/>
        <xsl:with-param name="helpLink" select="$helpLink"/>
        <xsl:with-param name="name" select="@name"/>
        <xsl:with-param name="elemId" select="../geonet:element/@uuid"/>
        <xsl:with-param name="addLink">
          <xsl:if test="@add='true'">
            <xsl:value-of
              select="concat('doNewAttributeAction(',$apos,'metadata.elem.add.new',$apos,',',../geonet:element/@ref,',',$apos,@name,$apos,',',
							$apos,$id,$apos,',',$apos,'add',$apos,');')"
            />
          </xsl:if>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template mode="complexElement" match="*">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="title">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="name" select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:param name="content">
      <xsl:call-template name="getContent">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit" select="$edit"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:param name="helpLink">
      <xsl:call-template name="getHelpLink">
        <xsl:with-param name="name" select="name(.)"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:param>
    
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:call-template name="editComplexElement">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="content" select="$content"/>
          <xsl:with-param name="helpLink" select="$helpLink"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="showComplexElement">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="content" select="$content"/>
          <xsl:with-param name="helpLink" select="$helpLink"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!--
	prevent drawing of geonet:* elements
	-->
  <xsl:template mode="element"
    match="geonet:null|geonet:element|geonet:info|geonet:attribute|geonet:inserted|geonet:class|geonet:deleted|class|geonet:schematronerrors|@geonet:xsderror|@xlink:type|@gco:isoType|@geonet:updatedText|@gco:nilReason"/>
  <xsl:template mode="simpleElement"
    match="geonet:null|geonet:element|geonet:info|geonet:attribute|geonet:inserted|geonet:class|geonet:deleted|class|geonet:schematronerrors|@geonet:xsderror|@xlink:type|@gco:isoType|@geonet:updatedText|@gco:nilReason"/>
  <xsl:template mode="complexElement"
    match="geonet:null|geonet:element|geonet:info|geonet:attribute|geonet:inserted|geonet:class|geonet:deleted|class|geonet:schematronerrors|@geonet:xsderror|@xlink:type|@gco:isoType|@geonet:updatedText|@gco:nilReason"/>
  
    <xsl:template mode="simpleAttribute" match="@geonet:xsderror|@geonet:inserted|@geonet:deleted|@geonet:class|@class|@geonet:updatedText|@gco:nilReason" priority="2"/>

  <!--
	prevent drawing of attributes starting with "_", used in old GeoNetwork versions
	-->
  <xsl:template mode="simpleElement" match="@*[starts-with(name(.),'_')]"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- elements/attributes templates -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


  <!--
	shows a simple element
	-->
  <xsl:template name="showSimpleElement">
    <xsl:param name="schema"/>
    <xsl:param name="title"/>
    <xsl:param name="text"/>
    <xsl:param name="helpLink"/>

    <!-- don't show it if there isn't anything in it! -->
    <xsl:if test="normalize-space($text)!=''">
      <xsl:call-template name="simpleElementGui">
        <xsl:with-param name="title" select="$title"/>
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="text" select="$text"/>
        <xsl:with-param name="helpLink" select="$helpLink"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
	shows a complex element
	-->
  <xsl:template name="showComplexElement">
    <xsl:param name="schema"/>
    <xsl:param name="title"/>
    <xsl:param name="content"/>
    <xsl:param name="helpLink"/>

    <!-- don't show it if there isn't anything in it! -->
    <xsl:if test="normalize-space($content)!=''">
      <xsl:call-template name="complexElementGui">
        <xsl:with-param name="title" select="$title"/>
        <xsl:with-param name="text" select="text()"/>
        <xsl:with-param name="content" select="$content"/>
        <xsl:with-param name="helpLink" select="$helpLink"/>
        <xsl:with-param name="schema" select="$schema"/>
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

  <!--
	shows editable fields for a simple element
	-->
  <xsl:template name="editSimpleElement">
    <xsl:param name="schema"/>
    <xsl:param name="title"/>
    <xsl:param name="editAttributes"/>
    <xsl:param name="text"/>
    <xsl:param name="helpLink"/>

    <!-- if it's the last brother of it's type and there is a new brother make addLink -->

    <xsl:variable name="id" select="geonet:element/@uuid"/>
    <xsl:variable name="addLink">
      <xsl:call-template name="addLink">
        <xsl:with-param name="id" select="$id"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="addXMLFragment">
      <xsl:call-template name="addXMLFragment">
        <xsl:with-param name="id" select="$id"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name= "nodeName" select="name()" />
    <xsl:variable name="siblingsCount" select="count(preceding-sibling::*[name() = $nodeName]) + count(following-sibling::*[name() = $nodeName])" />

    <xsl:variable name="minCardinality">
      <xsl:choose>        
        <xsl:when test="($currTab = 'simple') and (geonet:element/@min = 0) and (geonet:element/@del='true') and ($siblingsCount = 0)">1</xsl:when>
        <xsl:otherwise><xsl:value-of select="geonet:element/@min" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="removeLink">
      <xsl:value-of
        select="concat('doRemoveElementAction(', $apos,'metadata.elem.delete.new',$apos,',',geonet:element/@ref,',',geonet:element/@parent,',',$apos,$id,$apos,',',$minCardinality,');')"/>
       <xsl:if test="not(geonet:element/@del='true') or ($currTab = 'simple' and ($siblingsCount = 0))">
<!-- 		<xsl:if test="not(geonet:element/@del='true')"> -->
			<xsl:if test="$schema!='iso19139' or (name(.) != 'gmd:supplementalInformation' and name(.) != 'gmd:useLimitation' and
				name(.) != 'gmd:accessConstraints' and name(.) != 'gmd:useConstraints' and name(.) != 'gmd:transferSize')">
        	<xsl:text>!OPTIONAL</xsl:text>
        </xsl:if>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="upLink">
      <xsl:value-of
        select="concat('doMoveElementAction(',$apos,'metadata.elem.up',$apos,',',geonet:element/@ref,',',$apos,$id,$apos,');')"/>
      <xsl:if test="not(geonet:element/@up='true')">
        <xsl:text>!OPTIONAL</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="downLink">
      <xsl:value-of
        select="concat('doMoveElementAction(',$apos,'metadata.elem.down',$apos,',',geonet:element/@ref,',',$apos,$id,$apos,');')"/>
      <xsl:if test="not(geonet:element/@down='true')">
        <xsl:text>!OPTIONAL</xsl:text>
      </xsl:if>
    </xsl:variable>
    <!-- xsd and schematron validation info -->
    <xsl:variable name="validationLink" select="concat('#_',geonet:element/@parent,'#_', geonet:element/@ref)"/>
<!--
      <xsl:variable name="ref" select="concat('#_',geonet:element/@ref)"/>
      <xsl:call-template name="validationLink">
        <xsl:with-param name="ref" select="$ref"/>
      </xsl:call-template>
    </xsl:variable>
-->
    <xsl:call-template name="simpleElementGui">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="text" select="$text"/>
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="addLink" select="$addLink"/>
      <xsl:with-param name="addXMLFragment" select="$addXMLFragment"/>
      <xsl:with-param name="removeLink" select="$removeLink"/>
      <xsl:with-param name="upLink" select="$upLink"/>
      <xsl:with-param name="downLink" select="$downLink"/>
      <xsl:with-param name="helpLink" select="$helpLink"/>
      <xsl:with-param name="validationLink" select="$validationLink"/>
      <xsl:with-param name="edit" select="true()"/>
      <xsl:with-param name="editAttributes" select="$editAttributes"/>
      <xsl:with-param name="id" select="$id"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="addLink">
    <xsl:param name="id"/>

	<xsl:if test="not(name(.)='gmd:spatialResolution' or name(.)='gmd:otherConstraints')">
	    <xsl:variable name="name" select="name(.)"/>
	    <xsl:variable name="nextBrother" select="following-sibling::*[1]"/>
	    <xsl:variable name="nb">
	      <xsl:if test="name($nextBrother)='geonet:child'">
	        <xsl:choose>
	          <xsl:when test="$nextBrother/@prefix=''">
	            <xsl:if test="$nextBrother/@name=$name">
	              <xsl:copy-of select="$nextBrother"/>
	            </xsl:if>
	          </xsl:when>
	          <xsl:otherwise>
	            <xsl:if test="concat($nextBrother/@prefix,':',$nextBrother/@name)=$name">
	              <xsl:copy-of select="$nextBrother"/>
	            </xsl:if>
	          </xsl:otherwise>
	        </xsl:choose>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:variable name="newBrother" select="exslt:node-set($nb)"/>
	
	    <xsl:choose>
	        <!-- AGIV: special management to allow add new date from default editor
	
	            As it's a choose element (gco:Date/gco:DateTime), default editor doesn't handle + button by default
	        -->
	        <xsl:when test="name(.) = 'gmd:date' and name(..) = 'gmd:CI_Date' and ../../geonet:element/@add='true'">
	            <xsl:variable name="dateId" select="concat('_X', ../../geonet:element/@parent, '_', replace(name(.), ':', 'COLON'))" />
	
	            <xsl:value-of
	                select="concat('GeoNetwork.editor.EditorTools.addDateFormFieldFragment(',$apos,$dateId,$apos,');')"
	                />
	        </xsl:when>
	      <!-- place + because schema insists ie. next element is geonet:child -->
	      <xsl:when test="$newBrother/* and (not($newBrother/*/geonet:choose) or name(.)='gfc:featureType' or name(.)='gfc:carrierOfCharacteristics')">
	        <xsl:value-of
	          select="concat('doNewElementAction(',$apos,'metadata.elem.add.new',$apos,',',geonet:element/@parent,',',$apos,name(.),$apos,',',$apos,$id,$apos,',',$apos,'add',$apos,',',geonet:element/@max,');')"
	        />
	      </xsl:when>
	      <!-- place optional + for use when re-ordering etc -->
	      <xsl:when test="geonet:element/@add='true' and name($nextBrother)=name(.)">
	        <xsl:value-of
	          select="concat('doNewElementAction(',$apos,'metadata.elem.add.new',$apos,',',geonet:element/@parent,',',$apos,name(.),$apos,',',$apos,$id,$apos,',',$apos,'add',$apos,',',geonet:element/@max,');!OPTIONAL')"
	        />
	      </xsl:when>
	      <!-- place + because schema insists but no geonet:child nextBrother 
				     this case occurs in the javascript handling of the + -->
	      <xsl:when test="geonet:element/@add='true' and not($newBrother/*/geonet:choose)">
	        <xsl:value-of
	          select="concat('doNewElementAction(',$apos,'metadata.elem.add.new',$apos,',',geonet:element/@parent,',',$apos,name(.),$apos,',',$apos,$id,$apos,',',$apos,'add',$apos,',',geonet:element/@max,');')"
	        />
	      </xsl:when>
	    </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- 
		Add elements : will popup a remote element selector
		and add the XML fragment in the metadata
	-->
  <xsl:template name="addXMLFragment">
    <xsl:param name="id"/>
    <xsl:param name="subtemplate" select="false()"/>


    <xsl:variable name="name" select="name(.)"/>

    <!-- Some sub-template are relevant in different type of elements 
	  TODO : improve, at least move to schema XSL as this is schema based.
	  -->
    <xsl:variable name="elementName"
      select="if (name(.)='geonet:child') then concat(./@prefix,':',./@name) else $name"/>
    <xsl:variable name="subTemplateName"
      select="/root/gui/config/editor-subtemplate/mapping/subtemplate[parent/@id=$elementName]/@type"/>
    <xsl:variable name="function">
      <xsl:choose>
        <xsl:when test="$subtemplate">
          <!-- FIXME: remove ref to editorPanel -->
          <xsl:if test="count(/root/gui/subtemplates/record[type=$subTemplateName]) &gt; 0">Ext.getCmp('editorPanel').showSubTemplateSelectionPanel</xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="addXMLFragment" select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>



    <xsl:choose>
      <!-- Create link only when a function is available -->
      <xsl:when test="normalize-space($function)!=''">

        <!-- 
			    Example with contact :
			    a) a non existing contact (citedResponsibleParty)
			    <geonet:child name="identifier" prefix="gmd" ...
			    <geonet:child name="citedResponsibleParty" prefix="gmd" ...
			    <gmd:presentationForm>
			     ...
			     
			     b) an existing one
			     <gmd:pointOfContact>...</gmd:pointOfContact>
			     <geonet:child name="pointOfContact" prefix="gmd"
			  -->

        <!-- Retrieve the next geonet:child brother having the same defined in prefix and name attribute -->
        <xsl:variable name="nextBrother" select="following-sibling::*[1]"/>
        <xsl:variable name="nb">
          <xsl:if test="name($nextBrother)='geonet:child'">
            <xsl:choose>
              <xsl:when test="$nextBrother/@prefix=''">
                <xsl:if test="$nextBrother/@name=$name">
                  <xsl:copy-of select="$nextBrother"/>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="concat($nextBrother/@prefix,':',$nextBrother/@name)=$name">
                  <xsl:copy-of select="$nextBrother"/>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:variable>

        <xsl:variable name="newBrother" select="exslt:node-set($nb)"/>

        <xsl:choose>
          <!-- 
            with a new brother similar to current :
            place button because schema insists ie. next element is geonet:child -->
          <xsl:when
            test="$newBrother/* and not($newBrother/*/geonet:choose) and $nextBrother/@prefix=''">
            <xsl:value-of
              select="concat('javascript:', $function, '(',../geonet:element/@ref,',',$apos,$nextBrother/@name,$apos,', this);')"
            />
          </xsl:when>
          <xsl:when test="$newBrother/* and not($newBrother/*/geonet:choose)">
            <xsl:choose>
              <xsl:when test="$subtemplate">
                <xsl:value-of
                  select="concat('javascript:', $function, '(',../geonet:element/@ref,',',$apos,$nextBrother/@prefix,':',$nextBrother/@name,$apos, ',', $apos, $subTemplateName, $apos,', this);')"
                />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of
                  select="concat('javascript:', $function, '(',../geonet:element/@ref,',',$apos,$nextBrother/@prefix,':',$nextBrother/@name,$apos,', this);')"
                />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- place optional +/x for use when re-ordering etc -->
          <xsl:when test="geonet:element/@add='true' and name($nextBrother)=name(.)">
            <xsl:value-of
              select="concat('javascript:', $function, '(',../geonet:element/@ref,',',$apos,$nextBrother/@name,$apos,', this);!OPTIONAL')"
            />
          </xsl:when>
          <!-- place +/x because schema insists but no geonet:child nextBrother 
               this case occurs in the javascript handling of the +/+ -->
          <xsl:when test="geonet:element/@add='true' and not($newBrother/*/geonet:choose)">
            <xsl:value-of
              select="concat('javascript:', $function, '(',geonet:element/@parent,',',$apos,$name,$apos,', this);')"
            />
          </xsl:when>
          <!-- A lonely geonet:child element to replace, propose the add button.
          Always a sub-template.
          TODO : not sure about action=before, required for gmd:report, probably related to geonet:choose element
          -->
          <xsl:when test="$name='geonet:child' and (@action='replace' or @action='before')">
            <xsl:value-of
              select="concat('javascript:', $function, '(', ../geonet:element/@ref, ', ', $apos, $elementName,  $apos, ',', $apos, $subTemplateName, $apos,', this);')"
            />
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>

  </xsl:template>




  <!--
	shows editable fields for an attribute
	-->
  <xsl:template name="editAttribute">
    <xsl:param name="schema"/>
    <xsl:param name="title"/>
    <xsl:param name="id"/>
    <xsl:param name="text"/>
    <xsl:param name="helpLink"/>
    <xsl:param name="elemId"/>
    <xsl:param name="name"/>
    <xsl:param name="addLink"/>
    <xsl:param name="removeLink"/>

    <xsl:variable name="value" select="string(.)"/>

    <xsl:call-template name="simpleElementGui">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="text" select="$text"/>
      <xsl:with-param name="id" select="$id"/>
      <xsl:with-param name="helpLink" select="$helpLink"/>
      <xsl:with-param name="edit" select="true()"/>
      <xsl:with-param name="addLink" select="$addLink"/>
      <xsl:with-param name="removeLink" select="$removeLink"/>
    </xsl:call-template>
  </xsl:template>

  <!--
	shows editable fields for a complex element
	-->
  <xsl:template name="editComplexElement">
    <xsl:param name="schema"/>
    <xsl:param name="title"/>
    <xsl:param name="content"/>
    <xsl:param name="helpLink"/>

    <xsl:variable name="id" select="geonet:element/@uuid"/>
    <xsl:variable name="addLink">
      <xsl:call-template name="addLink">
        <xsl:with-param name="id" select="$id"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="addXMLFragment">
      <xsl:call-template name="addXMLFragment">
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="subtemplate" select="false()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="addXmlFragmentSubTemplate">
      <xsl:call-template name="addXMLFragment">
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="subtemplate" select="true()"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name= "nodeName" select="name()" />
    <xsl:variable name="siblingsCount" select="count(preceding-sibling::*[name() = $nodeName]) + count(following-sibling::*[name() = $nodeName])" />

    <xsl:variable name="minCardinality">
      <xsl:choose>        
        <xsl:when test="($currTab = 'simple') and (geonet:element/@min = 0) and (geonet:element/@del='true') and ($siblingsCount = 0)">1</xsl:when>
        <xsl:otherwise><xsl:value-of select="geonet:element/@min" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="removeLink">
      <xsl:value-of
        select="concat('doRemoveElementAction(',$apos,'metadata.elem.delete.new',$apos,',',geonet:element/@ref,',',geonet:element/@parent,',',$apos,$id,$apos,',',$minCardinality,');')"/>
        <xsl:if test="not(geonet:element/@del='true') or (($currTab = 'simple') and ($siblingsCount = 0))">
<!-- 		<xsl:if test="not(geonet:element/@del='true') or name(.)='gmd:distributionInfo'"> -->
			<xsl:if test="$schema!='iso19139' or (name(.) != 'gmd:resourceSpecificUsage' and
			name(.) != 'gmd:applicationSchemaInfo'  and
			name(.) != 'gmd:aggregationInfo'  and
			name(.) != 'gmd:processStep'  and
			name(.) != 'gmd:source' and
			name(.) != 'gmd:processor' and 
			name(.) != 'gmd:distributionOrderProcess' and
			name(.) != 'gmd:temporalElement' and
			name(.) != 'gmd:verticalElement' and
			name(.) != 'gmd:otherConstraints' and
			name(.) != 'gmd:resourceConstraints')">
	        	<xsl:text>!OPTIONAL</xsl:text>
        	</xsl:if>
      	</xsl:if>
    </xsl:variable>
    <xsl:variable name="upLink">
      <xsl:value-of
        select="concat('doMoveElementAction(',$apos,'metadata.elem.up',$apos,',',geonet:element/@ref,',',$apos,$id,$apos,');')"/>
      <xsl:if test="not(geonet:element/@up='true')">
        <xsl:text>!OPTIONAL</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="downLink">
      <xsl:value-of
        select="concat('doMoveElementAction(',$apos,'metadata.elem.down',$apos,',',geonet:element/@ref,',',$apos,$id,$apos,');')"/>
      <xsl:if test="not(geonet:element/@down='true')">
        <xsl:text>!OPTIONAL</xsl:text>
      </xsl:if>
    </xsl:variable>
    <!-- xsd and schematron validation info -->
    <xsl:variable name="validationLink" select="concat('#_',geonet:element/@parent,'#_', geonet:element/@ref)"/>
<!--
      <xsl:variable name="ref" select="concat('#_',geonet:element/@ref)"/>
      <xsl:call-template name="validationLink">
        <xsl:with-param name="ref" select="$ref"/>
      </xsl:call-template>
    </xsl:variable>
-->
    <xsl:call-template name="complexElementGui">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="text" select="text()"/>
      <xsl:with-param name="content" select="$content"/>
      <xsl:with-param name="addLink" select="$addLink"/>
      <xsl:with-param name="addXMLFragment" select="$addXMLFragment"/>
      <xsl:with-param name="addXmlFragmentSubTemplate" select="$addXmlFragmentSubTemplate"/>
      <xsl:with-param name="removeLink" select="$removeLink"/>
      <xsl:with-param name="upLink" select="$upLink"/>
      <xsl:with-param name="downLink" select="$downLink"/>
      <xsl:with-param name="helpLink" select="$helpLink"/>
      <xsl:with-param name="validationLink" select="$validationLink"/>
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit" select="true()"/>
      <xsl:with-param name="id" select="$id"/>
    </xsl:call-template>
  </xsl:template>



  <!-- ============================================================================= 
    Create a complex element with the content param in it.
    
    @param id : If using complexElementGuiWrapper in a same for-each statement, generate-id function will
    be identical for all call to this template (because id is computed on base node).
    In some situation it could be better to define id parameter when calling the template
    to override default values (eg. id are used for collapsible fieldset).
  -->

  <xsl:template name="complexElementGuiWrapper">
    <xsl:param name="title"/>
    <xsl:param name="content"/>
    <xsl:param name="schema"/>
    <xsl:param name="group"/>
    <xsl:param name="edit"/>
    <xsl:param name="realname" select="name(.)"/>
    <xsl:param name="id" select="generate-id(.)"/>

    <!-- do not show empty elements when editing -->

    <xsl:choose>
      <xsl:when test="normalize-space($content)!=''">
        <xsl:call-template name="complexElementGui">
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="content" select="$content"/>
          <xsl:with-param name="helpLink">
            <xsl:call-template name="getHelpLink">
              <xsl:with-param name="name" select="$realname"/>
              <xsl:with-param name="schema" select="$schema"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="id" select="$id"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$edit">
            <xsl:call-template name="complexElementGui">
              <xsl:with-param name="title" select="$title"/>
              <xsl:with-param name="content">
                <span class="missing"> - <xsl:value-of select="/root/gui/strings/missingSeeTab"/>
                    "<xsl:value-of select="$group"/>" - </span>
              </xsl:with-param>
              <xsl:with-param name="helpLink">
                <xsl:call-template name="getHelpLink">
                  <xsl:with-param name="name" select="$realname"/>
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="id" select="$id"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="complexElementGui">
              <xsl:with-param name="title" select="$title"/>
              <xsl:with-param name="helpLink">
                <xsl:call-template name="getHelpLink">
                  <xsl:with-param name="name" select="$realname"/>
                  <xsl:with-param name="schema" select="$schema"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="content">
                <span class="missing"> - <xsl:value-of select="/root/gui/strings/missing"/> -
                </span>
              </xsl:with-param>
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="id" select="$id"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!--
	returns the content of a complex element
	-->
  <xsl:template name="getContent">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    
    <xsl:choose>
      <xsl:when test="$edit=true()">
        <xsl:apply-templates mode="elementEP" select="@*">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="true()"/>
        </xsl:apply-templates>
        <xsl:apply-templates mode="elementEP" select="*[namespace-uri(.)!=$geonetUri]|geonet:child">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="true()"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="elementEP" select="@*">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="false()"/>
        </xsl:apply-templates>
        <xsl:apply-templates mode="elementEP" select="*">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="false()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="helperList">
    <xsl:param name="schema"/>
    <xsl:param name="attribute"/>
    <xsl:param name="helperElement"/>
    <!-- Define the element to look for. -->
    <xsl:variable name="parentName">
      <xsl:choose>
        <!-- In dublin core element contains value.
					In ISO, attribute also but element contains characterString which contains the value -->

        <!-- Added special case for gml:identifier as doesn't contain gco:CharacterString, but requires suggestions -->
        <xsl:when test="$attribute=true() or $schema = 'dublin-core' or name(.) = 'gml:identifier'">
          <xsl:value-of select="name(.)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name(parent::node())"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="context">
      <xsl:value-of select="name(parent::node()/parent::node())"/>
    </xsl:variable>
    
    <xsl:variable name="xpath">
      <xsl:for-each select="parent::node()">
        <xsl:call-template name="getXPath"/>
      </xsl:for-each>
    </xsl:variable>

      <xsl:choose>
        <xsl:when
          test="starts-with($schema,'iso19139')">
              <xsl:choose>
                <!-- Exact schema, name and full context match --> 
                <xsl:when test="/root/gui/schemas/*[name(.)=$schema]/labels/element[@name = $parentName and @context=$xpath]/helper">
                  <xsl:copy-of select="/root/gui/schemas/*[name(.)=$schema]/labels/element[@name = $parentName and (@context=$xpath or @context=$context)]/helper"/>
                </xsl:when>
                <!-- ISO19139, name and full context match --> 
                <xsl:when test="/root/gui/schemas/iso19139/labels/element[@name = $parentName and @context=$xpath]/helper">
                  <xsl:copy-of select="/root/gui/schemas/iso19139/labels/element[@name = $parentName and (@context=$xpath or @context=$context)]/helper"/>
                </xsl:when>
                <!-- Exact schema, name and parent-only match --> 
                <xsl:when test="/root/gui/schemas/*[name(.)=$schema]/labels/element[@name = $parentName and @context=$context]/helper">
                  <xsl:copy-of select="/root/gui/schemas/*[name(.)=$schema]/labels/element[@name = $parentName and (@context=$xpath or @context=$context)]/helper"/>
                </xsl:when>
                <!-- ISO19139, name and parent-only match --> 
                <xsl:when test="/root/gui/schemas/iso19139/labels/element[@name = $parentName and @context=$context]/helper">
                  <xsl:copy-of select="/root/gui/schemas/iso19139/labels/element[@name = $parentName and (@context=$xpath or @context=$context)]/helper"/>
                </xsl:when>
                <!-- Exact schema, name match --> 
                <xsl:when test="/root/gui/schemas/*[name(.)=$schema]/labels/element[@name = $parentName and not(@context)]/helper">
                  <xsl:copy-of select="/root/gui/schemas/*[name(.)=$schema]/labels/element[@name = $parentName and not(@context)]/helper"/>
                </xsl:when>
                <!-- ISO19139 schema, name match --> 
                <xsl:when test="/root/gui/schemas/iso19139/labels/element[@name = $parentName and not(@context)]/helper">
                  <xsl:copy-of
                    select="/root/gui/schemas/iso19139/labels/element[@name = $parentName and not(@context)]/helper"/>
                </xsl:when>
              </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of
            select="/root/gui/schemas/*[name(.)=$schema]/labels/element[@name = $parentName]/helper"
          />
        </xsl:otherwise>
      </xsl:choose>
</xsl:template>

  <!-- Create an helper list for the current input element.
		Current input could be an element or an attribute (eg. uom). 
	
	In editing mode, for gco:CharacterString elements (with no codelist 
	or enumeration defined in the schema) an helper list could be defined 
	in loc files using the helper tag. Then a list of values
	is displayed next to the input field.
	
	One related element (sibbling) could be link to current element using the @rel attribute.
	This related element is updated with the title value of the selected option.
	-->
  <xsl:template name="helper">
    <xsl:param name="schema"/>
    <xsl:param name="attribute"/>

    <!-- Look for the helper -->
    <xsl:variable name="helper">
	    <xsl:call-template name="helperList">
	        <xsl:with-param name="schema" select="$schema"/>
	        <xsl:with-param name="attribute" select="$attribute"/>
	    </xsl:call-template>
    </xsl:variable>

    <!-- Display the helper list -->
    <xsl:if test="normalize-space($helper)!=''">
      <xsl:variable name="list" select="exslt:node-set($helper)"/>
      <xsl:variable name="refId"
        select="if ($attribute=true()) then concat(../geonet:element/@ref, '_', name(.)) else geonet:element/@ref"/>
      <xsl:variable name="relatedElementName" select="$list/*/@rel"/>
      <xsl:variable name="relatedAttributeName" select="$list/*/@relAtt"/>
      
      <xsl:variable name="relatedElementAction">
        <xsl:if test="$relatedElementName!=''">
          <xsl:variable name="relatedElement"
            select="../following-sibling::node()[name()=$relatedElementName]/gco:CharacterString"/>
          <xsl:variable name="relatedElementRef"
            select="../following-sibling::node()[name()=$relatedElementName]/gco:CharacterString/geonet:element/@ref"/>
          <xsl:variable name="relatedElementIsEmpty" select="normalize-space($relatedElement)=''"/>
          <!--<xsl:value-of select="concat('if (Ext.getDom(&quot;_', $relatedElementRef, '&quot;).value===&quot;&quot;) Ext.getDom(&quot;_', $relatedElementRef, '&quot;).value=this.options[this.selectedIndex].title;')"/>-->
          <xsl:value-of
            select="concat('if (Ext.getDom(&quot;_', $relatedElementRef, '&quot;)) Ext.getDom(&quot;_', $relatedElementRef, '&quot;).value=this.options[this.selectedIndex].title;')"
          />
        </xsl:if>
      </xsl:variable>
      
      <xsl:variable name="relatedAttributeAction">
        <xsl:if test="$relatedAttributeName!=''">
          <xsl:variable name="relatedAttributeRef"
            select="concat($refId, '_', $relatedAttributeName)"/>
          <xsl:value-of
            select="concat('if (Ext.getDom(&quot;_', $relatedAttributeRef, '&quot;)) Ext.getDom(&quot;_', $relatedAttributeRef, '&quot;).value=this.options[this.selectedIndex].title;')"
          />
        </xsl:if>
      </xsl:variable>
      
      <xsl:text> </xsl:text> (<xsl:value-of select="/root/gui/strings/helperList"/>
      <select
        onchange="Ext.getDom('_{$refId}').value=this.options[this.selectedIndex].value; if (Ext.getDom('_{$refId}').onkeyup) Ext.getDom('_{$refId}').onkeyup(); {$relatedElementAction} {$relatedAttributeAction}"
        class="md">
        <option/>
        <!-- This assume that helper list is already sort in alphabetical order in loc file. -->
        <xsl:copy-of select="$list/*"/>
      </select>) </xsl:if>
  </xsl:template>


  <!--
	prevent drawing of geonet:* elements
	-->
  <xsl:template mode="showXMLElement" match="geonet:*"/>
  <xsl:template mode="editXMLElement" match="geonet:*"/>










  <!-- ======================================= -->
  <!-- Layout -->

  <!--
    Template to create validation link popup on XSD errors
    or schematron errors.
  -->
  <xsl:template name="validationLink">
    <xsl:param name="ref"/>

    <xsl:if
      test="@geonet:xsderror
      or */@geonet:xsderror
      or //svrl:failed-assert[@ref=$ref]">
      <xsl:message select="'ERROR'"/>
      <ul>
        <xsl:choose>
          <!-- xsd validation -->
          <xsl:when test="@geonet:xsderror">
            <li>
              <xsl:value-of select="concat(/root/gui/strings/xsdError,': ',@geonet:xsderror)"/>
            </li>
          </xsl:when>
          <!-- some simple elements hide lower elements to remove some
            complexity from the display (eg. gco: in iso19139) 
            so check if they have a schematron/xsderror and move it up 
            if they do -->
          <xsl:when test="*/@geonet:xsderror">
            <li>
              <xsl:value-of select="concat(/root/gui/strings/xsdError,': ',*/@geonet:xsderror)"/>
            </li>
          </xsl:when>
          <!-- schematrons -->
          <xsl:when test="//svrl:failed-assert[@ref=$ref]">
            <xsl:for-each select="//svrl:failed-assert[@ref=$ref]">
              <li><xsl:value-of select="preceding-sibling::svrl:active-pattern[1]/@name"/> :
                  <xsl:copy-of select="svrl:text/*"/></li>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
      </ul>
    </xsl:if>
  </xsl:template>



  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- gui templates -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


  <!-- Create a column layout 
  -->
  <xsl:template name="columnElementGui">
    <xsl:param name="cols"/>
    <tr>
      <xsl:for-each select="$cols/col">
        <td class="col">
          <table class="gn">
            <tbody>
              <xsl:copy-of select="*"/>
            </tbody>
          </table>
        </td>
      </xsl:for-each>
    </tr>
  </xsl:template>


  <!--
    GUI to show a simple element in a table row with all
    attributes in a fieldset. Could be use in edit or view mode.
  -->
  <xsl:template name="simpleElementGui">
    <xsl:param name="title"/>
    <xsl:param name="text"/>
    <xsl:param name="helpLink"/>
    <xsl:param name="addLink"/>
    <xsl:param name="addXMLFragment"/>
    <xsl:param name="addXMLFragmentSubTemplate"/>
    <xsl:param name="removeLink"/>
    <xsl:param name="upLink"/>
    <xsl:param name="downLink"/>
    <xsl:param name="validationLink"/>
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="editAttributes" select="true()"/>
    <xsl:param name="id" select="generate-id(.)"/>
    <xsl:param name="visible" select="true()"/>

    <xsl:variable name="forcedHelpLink">
    	<xsl:choose>
			<xsl:when test="$helpLink!=''">
				<xsl:value-of select="$helpLink"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="getHelpLink">
					<xsl:with-param name="name" select="name(.)"/>
					<xsl:with-param name="schema" select="$schema"/>
				</xsl:call-template>
			</xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>
    <xsl:variable name="isXLinked" select="count(ancestor-or-self::node()[@xlink:href]) > 0"/>
    <xsl:variable name="geonet" select="starts-with(name(.),'geonet:')"/>
	<xsl:variable name="className" select="./@class"/>
	<xsl:variable name="pairClassName" select="./@geonet:class"/>
	<xsl:variable name="prefixedClassName" select="concat('diff-',$pairClassName)"/>
    <tr id="{$id}" type="metadata">
      <xsl:attribute name="class">
        <!-- Add codelist value in CSS class -->
        <xsl:value-of select="$pairClassName"/><!-- <xsl:if test="*/@codeListValue"><xsl:value-of select="*/@codeListValue"/></xsl:if>-->
        <xsl:text> </xsl:text>
       	<xsl:call-template name="getMandatoryType">
       		<xsl:with-param name="name"><xsl:value-of select="name(.)"/></xsl:with-param>
       		<xsl:with-param name="schema"><xsl:value-of select="$schema"/></xsl:with-param>
       	</xsl:call-template>
       </xsl:attribute>
      
      <xsl:if test="$pairClassName != ''">

              <xsl:attribute name="onclick">
                  // to know whether we're on source or target doc
                  var containerId = GeoNetwork.Util.findContainerId(this);
                  var selected = Ext.query('.<xsl:value-of select="$pairClassName"/><!-- <xsl:if test="*/@codeListValue"><xsl:value-of select="*/@codeListValue"/></xsl:if>-->');
                  var id = this.id;
                  var correspondingElement;
                  var thisTop;
                  var correspondingElementTop;
                  //Look for elements and calculate top height to display them
                  for(var i = 0; i &lt; selected.length; i++) {
	                  // the element being hovered
	                  if(selected[i].id == id)  {
	                  	if (!thisTop) {
	                  	    thisTop = GeoNetwork.Util.getTopLeft(selected[i]).Top;  
	                    }
	                  }
	                  // the corresponding element in the other doc
	                  else {
	                  	if (!correspondingElementTop) {
                             GeoNetwork.Util.openSections(selected[i]);
	                  	     correspondingElementTop = GeoNetwork.Util.getTopLeft(selected[i]).Top;
	                    }
	                  }
                  }
                  //If pair does not exists, look for closest sibling pair
                  var current = Ext.get(id);
                  if(!correspondingElementTop) {
	                  current = GeoNetwork.Util.findClosestSiblingPair(current);	                  
	                  if(current) {
                        GeoNetwork.Util.openSections(current);
	                    correspondingElementTop = GeoNetwork.Util.getTopLeft(current).Top;
	                  }
                  }
                  if(containerId == 'source-container') {
	                    if (correspondingElementTop) {
	                        $('target-container').scrollTop = correspondingElementTop-200;
	                    }
	                  	if (thisTop) {
	                  	     $('source-container').scrollTop = thisTop-200;
	                  	}
                  }
                  else if(containerId == 'target-container' || containerId == 'hiddenFormElements') {
	                  	if (correspondingElementTop) {
	                  	     $('source-container').scrollTop = correspondingElementTop-200;
	                  	}
	                    if (thisTop) {
	                        $('target-container').scrollTop = thisTop-200;
	                    }
                  }
              </xsl:attribute>
          </xsl:if>

        <xsl:if test=".//@geonet:updatedText or .//@geonet:updatedAttribute or .//@geonet:updatedElement">
            <xsl:attribute name="style">
                background:#668fff;
            </xsl:attribute>

            <xsl:attribute name="onmouseout">
                var selected = Ext.query('.<xsl:value-of select="$prefixedClassName"/>');
                for(var i = 0; i &lt; selected.length; i++) {
                // TODO in Chrome (19, Windows7) the border is not (completely) removed !
                // I think that's bug http://code.google.com/p/chromium/issues/detail?id=101150.
                selected[i].style.border = '0px white';
                selected[i].style.border.style = 'none';
                }
            </xsl:attribute>
        </xsl:if>
        <xsl:if test=".//@geonet:deletedText or .//@geonet:deleted">
            <xsl:attribute name="style">
                background:#fe5555;
            </xsl:attribute>
        </xsl:if>
        <xsl:if test=".//@geonet:insertedText or .//@geonet:inserted">
            <xsl:attribute name="style">
                background:lightgreen;
            </xsl:attribute>
        </xsl:if>

      <xsl:if test="not($visible)">
        <xsl:attribute name="style"> display:none; </xsl:attribute>
      </xsl:if>
      
      <th>
        <xsl:attribute name="class">
          <xsl:text>main </xsl:text>
          <xsl:value-of select="geonet:clear-string-for-css(name(.))"/>
          <xsl:text> </xsl:text>
          <xsl:if test="$isXLinked">xlinked</xsl:if>
<!-- 
          <xsl:text> </xsl:text>
          <xsl:if test="geonet:element/@min='1' and not(@gco:nilReason) and $edit">mandatory</xsl:if>
 -->
           <xsl:text> </xsl:text>
	   	  <xsl:call-template name="getMandatoryType">
	        <xsl:with-param name="name"><xsl:value-of select="name(.)"/></xsl:with-param>
	       	<xsl:with-param name="schema"><xsl:value-of select="$schema"/></xsl:with-param>
	      </xsl:call-template>
        </xsl:attribute>
        <label id="stip.{$forcedHelpLink}"
          for="_{if (gco:CharacterString) then gco:CharacterString/geonet:element/@ref else if (gmd:file) then '' else ''}">
          <xsl:attribute name="class">
          	<xsl:call-template name="getMandatoryType">
          		<xsl:with-param name="name"><xsl:value-of select="name(.)"/></xsl:with-param>
          		<xsl:with-param name="schema"><xsl:value-of select="$schema"/></xsl:with-param>
          	</xsl:call-template>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="$forcedHelpLink!=''">
              <xsl:value-of select="$title"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="showTitleWithTag">
                <xsl:with-param name="title" select="$title"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </label>
        <xsl:text>&#160;</xsl:text>
        <!-- srv:operatesOn is an element which contains xlink:href attribute 
          (due to INSPIRE usage added in r7710) and must be editable in any cases (#705). 
          The xLink for this element is used for linking to a full
          XML metadata records and is part of the Jeeves XLink resolver exception (jeeves.xlink.Processor#doXLink).
        -->
        <xsl:if test="$edit and (not($isXLinked) or name(.)='srv:operatesOn')">
          <xsl:call-template name="getButtons">
            <xsl:with-param name="addLink" select="$addLink"/>
            <xsl:with-param name="addXMLFragment" select="$addXMLFragment"/>
            <xsl:with-param name="addXmlFragmentSubTemplate" select="$addXMLFragmentSubTemplate"/>
            <xsl:with-param name="removeLink" select="$removeLink"/>
            <xsl:with-param name="upLink" select="$upLink"/>
            <xsl:with-param name="downLink" select="$downLink"/>
            <xsl:with-param name="validationLink" select="$validationLink"/>
            <xsl:with-param name="id" select="$id"/>
          </xsl:call-template>
        </xsl:if>
      </th>
      <td>

        <xsl:variable name="textnode" select="exslt:node-set($text)"/>
        <xsl:choose>
          <xsl:when test="$edit">
            <xsl:copy-of select="$text"/>
          	<xsl:call-template name="getMandatoryTooltip">
          		<xsl:with-param name="name"><xsl:value-of select="name(.)"/></xsl:with-param>
          		<xsl:with-param name="schema"><xsl:value-of select="$schema"/></xsl:with-param>
          	</xsl:call-template>
          </xsl:when>
          <xsl:when test="count($textnode/*) &gt; 0">
            <!-- In some templates, text already contains HTML (eg. codelist, link for download).
              In that case copy text content and does not resolve
              hyperlinks. -->
            <xsl:copy-of select="$text"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="addLineBreaksAndHyperlinks">
              <xsl:with-param name="txt" select="$text"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Display attributes for :
          * non codelist element
          * empty field with nilReason attributes
        -->
<!--        <xsl:message select="concat('Executing simpleElementGui for element ', name(.))"/>-->
        <xsl:choose>
          <xsl:when
            test="$edit and $editAttributes
            and count(geonet:attribute)&gt;0 
            and count(*/geonet:attribute[@name='codeList'])=0 
            ">
            <!-- Display attributes if used and not only contains a gco:nilReason = missing. -->
            <xsl:variable name="countGeonetAttributes" select="count(@geonet:xsderror|@geonet:inserted|@geonet:deleted|@geonet:class|@class|@geonet:updatedText)"/>
            <xsl:variable name="visibleAttributes" select="count(@*[name(.)!='nilReason' and name(.)!='frame' and  normalize-space()!='missing']) - $countGeonetAttributes > 0 and name(.)!='gmx:Anchor'"/>
<!--
            <xsl:variable name="visibleAttributes" select="count(@*[name(.)!='nilReason' and  normalize-space()!='missing']) > 0"/>
-->
             <div class="attr">
              <div title="{/root/gui/strings/editAttributes}" onclick="toggleFieldset(this, Ext.getDom('toggled{$id}'));" style="display: none;">
                <xsl:attribute name="class">
                  <xsl:choose>
                    <xsl:when test="$visibleAttributes">toggle-attr tgDown button</xsl:when>
                    <xsl:otherwise>toggle-attr tgRight button</xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
              </div>
              <table id="toggled{$id}">
                <xsl:attribute name="style">
                  <xsl:if test="not($visibleAttributes)">display:none;</xsl:if>
                </xsl:attribute>
                <tbody>
                  <xsl:apply-templates mode="simpleAttribute" select="@*|geonet:attribute">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit" select="$edit"/>
                  </xsl:apply-templates>
                </tbody>
              </table>
            </div>
          </xsl:when>
          <xsl:when test="not($edit) and @* except @geonet:*">
            <xsl:apply-templates mode="simpleAttribute" select="@*">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit" select="$edit"/>
            </xsl:apply-templates>
          </xsl:when>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>

  <!-- GUI to create simple element in a table row with title and content only.
    Usually not used in edit mode.
  -->
  <xsl:template name="simpleElementSimpleGUI">
    <xsl:param name="title"/>
    <xsl:param name="helpLink"/>
    <xsl:param name="content"/>
    <tr>
      <th class="main" id="stip.{$helpLink}|{generate-id()}">
        <xsl:value-of select="$title"/>
      </th>
      <td>
        <xsl:copy-of select="$content"/>
      </td>
    </tr>
  </xsl:template>


  <!-- Display coordinates with 2 fields:
    * one to store the value but hidden (always in WGS84 as defined in ISO). 
    This element is post via the form.
    * one to display the coordinate in user defined projection.
  -->
  <xsl:template mode="coordinateElementGUI" match="*">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="name"/>
    <xsl:param name="eltRef"/>
    <xsl:param name="tabIndex"/>

    <xsl:variable name="title">
      <xsl:call-template name="getTitle">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="helpLink">
      <xsl:call-template name="getHelpLink">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
    </xsl:variable>
    <b>
      <xsl:choose>
        <xsl:when test="$helpLink!=''">
          <span id="tip.{$helpLink}" style="cursor:help;">
            <xsl:value-of select="$title"/>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="showTitleWithTag">
            <xsl:with-param name="title" select="$title"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </b>
    <br/>
    <xsl:variable name="size" select="'8'"/>

    <xsl:choose>
      <!-- Hidden text field is use to store WGS84 values which are stored in metadata records. -->
      <xsl:when test="$edit=true()">
      	<xsl:variable name="mandatory" select="false()"/>
        <xsl:variable name="agivmandatory">
         	<xsl:call-template name="getMandatoryType">
	    		<xsl:with-param name="name"><xsl:value-of select="$name"/></xsl:with-param>
	    		<xsl:with-param name="schema"><xsl:value-of select="$schema"/></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
        <xsl:call-template name="getElementText">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="input_type" select="'number'"/>
          <xsl:with-param name="input_step" select="'0.00001'"/>
          <xsl:with-param name="validator" select="concat('validateNumber(this,', not($mandatory or not($agivmandatory = '')),',true);')"/>
          <xsl:with-param name="no_name" select="true()"/>
          <xsl:with-param name="tabindex" select="$tabIndex"/>
        </xsl:call-template>
      	<xsl:call-template name="getMandatoryTooltip">
      		<xsl:with-param name="name"><xsl:value-of select="$name"/></xsl:with-param>
      		<xsl:with-param name="schema"><xsl:value-of select="$schema"/></xsl:with-param>
      	</xsl:call-template>
        <xsl:call-template name="getElementText">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="true()"/>
          <xsl:with-param name="input_type" select="'hidden'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <input class="md" type="text" id="{$eltRef}" value="{text()}" readonly="readonly"
          size="{$size}"/>
        <input class="md" type="hidden" id="_{$eltRef}" name="_{$eltRef}" value="{text()}"
          readonly="readonly"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


  <!-- Display the extent widget composed of
    * 4 input text fields with bounds coordinates
    * a coordinate system switcher. Coordinates are stored in WGS84 but could be displayed 
    or editied in antother projection. 
  -->
  <xsl:template name="geoBoxGUI">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="nEl"/>
    <xsl:param name="nId"/>
    <xsl:param name="nValue"/>
    <xsl:param name="sEl"/>
    <xsl:param name="sId"/>
    <xsl:param name="sValue"/>
    <xsl:param name="wEl"/>
    <xsl:param name="wId"/>
    <xsl:param name="wValue"/>
    <xsl:param name="eEl"/>
    <xsl:param name="eId"/>
    <xsl:param name="eValue"/>
    <xsl:param name="descId"/>
    <xsl:param name="id"/>


    <xsl:variable name="eltRef">
      <xsl:choose>
        <xsl:when test="$edit=true()">
          <xsl:value-of select="$id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="generate-id(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <table class="map">
      <tbody>
        <tr>
          <td colspan="3">
            <!-- Loop on all projections defined in config-gui.xml -->
            <xsl:for-each select="/root/gui/config/map/proj/crs">
              <!-- Set label from loc file -->
              <label for="{@code}_{$eltRef}">
                <xsl:variable name="code" select="@code"/>
                <xsl:choose>
                  <xsl:when test="/root/gui/strings/*[@code=$code]">
                    <xsl:value-of select="/root/gui/strings/*[@code=$code]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@code"/>
                  </xsl:otherwise>
                </xsl:choose>
                <input id="{@code}_{$eltRef}" class="proj" type="radio" name="proj_{$eltRef}"
                  value="{@code}">
                  <xsl:if test="@default='1'">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                  </xsl:if>
                </input>
              </label>
            </xsl:for-each>

          </td>
        </tr>
        <xsl:if test="$nEl">
          <tr>
            <td colspan="3">
              <xsl:apply-templates mode="coordinateElementGUI" select="$nEl/gco:Decimal">
                <!-- FIXME make it schema generic -->
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit" select="$edit"/>
                <xsl:with-param name="name" select="'gmd:northBoundLatitude'"/>
                <xsl:with-param name="eltRef" select="concat('n', $eltRef)"/>
                <xsl:with-param name="tabIndex" select="100"/>
              </xsl:apply-templates>
            </td>
          </tr>
        </xsl:if>
        <tr>
          <xsl:if test="$wEl">
            <td>
              <xsl:apply-templates mode="coordinateElementGUI" select="$wEl/gco:Decimal">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit" select="$edit"/>
                <xsl:with-param name="name" select="'gmd:westBoundLongitude'"/>
                <xsl:with-param name="eltRef" select="concat('w', $eltRef)"/>
                <xsl:with-param name="tabIndex" select="101"/>
              </xsl:apply-templates>
            </td>
          </xsl:if>
          <td>
            <xsl:variable name="wID">
              <xsl:choose>
                <xsl:when test="$edit=true()">
                  <xsl:value-of select="$wId"/>
                </xsl:when>
                <xsl:otherwise>w<xsl:value-of select="$eltRef"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="eID">
              <xsl:choose>
                <xsl:when test="$edit=true()">
                  <xsl:value-of select="$eId"/>
                </xsl:when>
                <xsl:otherwise>e<xsl:value-of select="$eltRef"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="nID">
              <xsl:choose>
                <xsl:when test="$edit=true()">
                  <xsl:value-of select="$nId"/>
                </xsl:when>
                <xsl:otherwise>n<xsl:value-of select="$eltRef"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="sID">
              <xsl:choose>
                <xsl:when test="$edit=true()">
                  <xsl:value-of select="$sId"/>
                </xsl:when>
                <xsl:otherwise>s<xsl:value-of select="$eltRef"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>


            <xsl:variable name="geom">
              <xsl:value-of
                select="concat('Polygon((', $wValue, ' ', $sValue,',',$eValue,' ',$sValue,',',$eValue,' ',$nValue,',',$wValue,' ',$nValue,',',$wValue,' ',$sValue, '))')"
              />
            </xsl:variable>
            <xsl:call-template name="showMap">
              <xsl:with-param name="edit" select="$edit"/>
              <xsl:with-param name="mode" select="'bbox'"/>
              <xsl:with-param name="coords" select="$geom"/>
              <xsl:with-param name="watchedBbox"
                select="concat($wID, ',', $sID, ',', $eID, ',', $nID)"/>
              <xsl:with-param name="eltRef" select="$eltRef"/>
              <xsl:with-param name="descRef" select="$descId"/>
            </xsl:call-template>
          </td>
          <xsl:if test="$eEl">
            <td>
              <xsl:apply-templates mode="coordinateElementGUI" select="$eEl/gco:Decimal">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit" select="$edit"/>
                <xsl:with-param name="name" select="'gmd:eastBoundLongitude'"/>
                <xsl:with-param name="eltRef" select="concat('e', $eltRef)"/>
                <xsl:with-param name="tabIndex" select="103"/>
              </xsl:apply-templates>
            </td>
          </xsl:if>
        </tr>
        <xsl:if test="$sEl">
          <tr>
            <td colspan="3">
              <xsl:apply-templates mode="coordinateElementGUI" select="$sEl/gco:Decimal">
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="edit" select="$edit"/>
                <xsl:with-param name="name" select="'gmd:southBoundLatitude'"/>
                <xsl:with-param name="eltRef" select="concat('s', $eltRef)"/>
                <xsl:with-param name="tabIndex" select="102"/>
              </xsl:apply-templates>
            </td>
          </tr>
        </xsl:if>
      </tbody>
    </table>
  </xsl:template>



  <!--
    gui to show a title and do special mapping for container elements
  -->
  <xsl:template name="showTitleWithTag">
    <xsl:param name="title"/>
    <xsl:param name="class"/>
    <xsl:variable name="shortTitle" select="normalize-space($title)"/>
    <xsl:variable name="conthelp"
      select="concat('This is a container element name - you can give it a title and help by entering some help for ',$shortTitle,' in the help file')"/>
    <xsl:variable name="nohelp"
      select="concat('This is an element/attribute name - you can give it a title and help by entering some help for ',$shortTitle,' in the help file')"/>

    <xsl:choose>
      <xsl:when test="contains($title,'CHOICE_ELEMENT')">
        <span class="{$class}" title="{$conthelp}">
          <xsl:value-of select="/root/gui/strings/choice"/>
        </span>
      </xsl:when>
      <xsl:when test="contains($title,'GROUP_ELEMENT')">
        <span class="{$class}" title="{$conthelp}">
          <xsl:value-of select="/root/gui/strings/group"/>
        </span>
      </xsl:when>
      <xsl:when test="contains($title,'SEQUENCE_ELEMENT')">
        <span class="{$class}" title="{$conthelp}">
          <xsl:value-of select="/root/gui/strings/sequence"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="{$class}" title="{$nohelp}">
          <xsl:value-of select="$title"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
    gui to show a complex element
  -->
  <xsl:template name="complexElementGui">
    <xsl:param name="title"/>
    <xsl:param name="text"/>
    <xsl:param name="content"/>
    <xsl:param name="helpLink"/>
    <xsl:param name="addLink"/>
    <xsl:param name="addXMLFragment"/>
    <xsl:param name="addXmlFragmentSubTemplate"/>
    <xsl:param name="removeLink"/>
    <xsl:param name="upLink"/>
    <xsl:param name="downLink"/>
    <xsl:param name="validationLink"/>
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="id" select="generate-id(.)"/>

    <xsl:variable name="isXLinked" select="count(ancestor::node()[@xlink:href]) > 0"/>
    <tr id="{$id}">
      <xsl:if test="@geonet:xxxupdatedText or @geonet:xxxupdatedAttribute">
            <xsl:attribute name="style">
                border:solid #0741e0 1px;
                background:#668fff;
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@geonet:deleted">
            <xsl:attribute name="style">
                border:solid red 1px;
                background:#fe5555;
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@geonet:inserted">
            <xsl:attribute name="style">
                border:solid green 1px;
                background:lightgreen;
            </xsl:attribute>
        </xsl:if>

      <td colspan="2" class="complex">
        <fieldset>
          <legend id="stip.{$helpLink}|{$id}">
            <span>
              <xsl:if test="/root/gui/config/metadata-view-toggleTab">
                <div class="toggle button tgDown" onclick="toggleFieldset(this, Ext.getDom('toggled{$id}'));"
                  >&#160;</div>
              </xsl:if>

              <xsl:choose>
                <xsl:when test="$title!=''">
                  <xsl:value-of select="$title"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="showTitleWithTag">
                    <xsl:with-param name="title" select="$title"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:if test="$edit and not($isXLinked)">
                <xsl:call-template name="getButtons">
                  <xsl:with-param name="addLink" select="$addLink"/>
                  <xsl:with-param name="addXMLFragment" select="$addXMLFragment"/>
                  <xsl:with-param name="addXmlFragmentSubTemplate"
                    select="$addXmlFragmentSubTemplate"/>
                  <xsl:with-param name="removeLink" select="$removeLink"/>
                  <xsl:with-param name="upLink" select="$upLink"/>
                  <xsl:with-param name="downLink" select="$downLink"/>
                  <xsl:with-param name="validationLink" select="$validationLink"/>
                  <xsl:with-param name="id" select="$id"/>
                </xsl:call-template>
              </xsl:if>
            </span>
          </legend>
          <!-- Check if divs could be used instead ? -->
          <table class="gn" id="toggled{$id}">
            <tbody>
              <xsl:copy-of select="$content"/>
            </tbody>
          </table>
        </fieldset>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="complexElementSimpleGui">
    <xsl:param name="title"/>
    <xsl:param name="content"/>
    <fieldset>
      <legend>
        <xsl:value-of select="$title"/>
      </legend>

      <table class="gn">
        <xsl:copy-of select="$content"/>
      </table>
    </fieldset>
  </xsl:template>

  <!--
    returns the text of an element
  -->
  <xsl:template name="getElementText">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <!-- Define the class to apply to textarea element, use 
    to create a textarea -->
    <xsl:param name="class"/>
    <xsl:param name="langId"/>
    <xsl:param name="visible" select="true()"/>
    <!-- Add javascript validator function. By default, if element 
      is mandatory a non empty validator is defined. -->
    <xsl:param name="validator"/>
    <!-- Use input_type parameter to create an hidden field. 
      Default is a text input. -->
    <xsl:param name="input_type">text</xsl:param>
    <!-- 
      See http://www.w3.org/TR/html-markup/input.number.html
    -->
    <xsl:param name="input_step"></xsl:param>
    <!-- Set to true no_name parameter in order to create an element 
      which will not be submitted to the form. -->
    <xsl:param name="no_name" select="false()"/>
    <xsl:param name="tabindex"/>
        
    <xsl:variable name="edit" select="xs:boolean($edit)"/>
    <xsl:variable name="name" select="name(.)"/>
    <xsl:variable name="value" select="string(.)"/>
    <xsl:variable name="isXLinked" select="count(ancestor-or-self::node()[@xlink:href]) > 0"/>
	<xsl:variable name="agivmandatory">
		<xsl:call-template name="getMandatoryType">
			<xsl:with-param name="name"><xsl:value-of select="name(..)"/></xsl:with-param>
			<xsl:with-param name="schema"><xsl:value-of select="$schema"/></xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

 	<xsl:choose>
      	<!-- list of values -->
      	<xsl:when test="geonet:element/geonet:text">
<!-- 
        	<xsl:variable name="mandatory"
          		select="geonet:element/@min='1' and
          		geonet:element/@max='1' and not(../@gco:nilReason)"/>
-->
        	<xsl:variable name="mandatory" select="false()"/>

	        <!-- This code is mainly run under FGDC 
	          but also for enumeration like topic category and 
	          service parameter direction in ISO. 
	          
	          Create a temporary list and retrive label in 
	          current gui language which is sorted after. -->
	        <xsl:variable name="list">
				<items>
		            <xsl:for-each select="geonet:element/geonet:text">
		              <xsl:variable name="choiceValue" select="string(@value)"/>
		              <xsl:variable name="label"
		                select="/root/gui/schemas/*[name(.)=$schema]/codelists/codelist[@name = $name]/entry[code = $choiceValue]/label"/>
		              <item>
		                <value>
		                  <xsl:value-of select="@value"/>
		                </value>
		                <label>
		                  <xsl:choose>
		                    <xsl:when test="$label">
		                      <xsl:value-of select="$label"/>
		                    </xsl:when>
		                    <xsl:otherwise>
		                      <xsl:value-of select="$choiceValue"/>
		                    </xsl:otherwise>
		                  </xsl:choose>
		                </label>
		              </item>
		            </xsl:for-each>
        		</items>
        	</xsl:variable>
	        <select class="md" name="_{geonet:element/@ref}" size="1">
	          <xsl:if test="$visible = false()">
	            <xsl:attribute name="style">display:none;</xsl:attribute>
	          </xsl:if>
	          <xsl:if test="$isXLinked">
	            <xsl:attribute name="disabled">disabled</xsl:attribute>
	          </xsl:if>
	          <xsl:if test="($mandatory or not($agivmandatory = '')) and $edit">
	            <xsl:attribute name="onchange">validateNonEmpty(this); </xsl:attribute>
	          </xsl:if>
	          <option name=""/>
	          <xsl:for-each select="exslt:node-set($list)//item">
	            <xsl:sort select="label"/>
	            <option>
	              <xsl:if test="value=$value">
	                <xsl:attribute name="selected"/>
	              </xsl:if>
	              <xsl:attribute name="value">
	                <xsl:value-of select="value"/>
	              </xsl:attribute>
	              <xsl:value-of select="label"/>
	            </option>
	          </xsl:for-each>
	        </select>
      </xsl:when>
      <xsl:when test="$edit=true() and $class='' and name(.)!='gmx:Anchor'">
        <xsl:choose>
          <!-- heikki doeleman: for gco:Boolean, use checkbox.
            Default value set to false. -->
          <xsl:when test="name(.)='gco:Boolean'">
            <input type="hidden" name="_{geonet:element/@ref}" id="_{geonet:element/@ref}"
              value="{.}">
              <xsl:if test="$isXLinked">
                <xsl:attribute name="disabled">disabled</xsl:attribute>
              </xsl:if>
              <xsl:choose>
                <xsl:when test=". = ''">
                  <xsl:attribute name="value">false</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="value">
                    <xsl:value-of select="."/>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </input>

            <xsl:choose>
              <xsl:when test="text()='true' or text()='1'">
                <input class="md" type="checkbox" id="_{geonet:element/@ref}_checkbox"
                  onclick="handleCheckboxAsBoolean(this, '_{geonet:element/@ref}');"
                  checked="checked">
                  <xsl:if test="$isXLinked">
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                  </xsl:if>
                </input>
              </xsl:when>
              <xsl:otherwise>
                <input class="md" type="checkbox" id="_{geonet:element/@ref}_checkbox"
                  onclick="handleCheckboxAsBoolean(this, '_{geonet:element/@ref}');">
                  <xsl:if test="$isXLinked">
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                  </xsl:if>
                </input>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:otherwise>
<!--			<xsl:variable name="mandatory" select="(name(.)='gmd:LocalisedCharacterString' and ../../geonet:element/@min='1' and not(../../@gco:nilReason='missing')) or (../geonet:element/@min='1' and not(../@gco:nilReason='missing'))"/>-->
			<xsl:variable name="mandatory" select="false()"/>
			<xsl:variable name="agivmandatory">
				<xsl:call-template name="getMandatoryType">
					<xsl:with-param name="name"><xsl:value-of select="name(.)"/></xsl:with-param>
					<xsl:with-param name="schema"><xsl:value-of select="$schema"/></xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="onkeyup">
				<xsl:choose>
	                <!-- Custom validator -->
	                <xsl:when test="$validator"><xsl:value-of select="$validator"/></xsl:when>
	                <xsl:when test="name(.)='gco:Integer' or name(.)='gco:Decimal' or name(.)='gco:Real'">
						<xsl:choose>
							<xsl:when test="name(.)='gco:Integer'">validateNumber(this, <xsl:value-of select="not($mandatory or not($agivmandatory=''))"/>, false);</xsl:when>
							<xsl:otherwise>validateNumber(this, <xsl:value-of select="not($mandatory or not($agivmandatory = ''))"/>, true);</xsl:otherwise>
						</xsl:choose>
	                </xsl:when>
	                <!-- Mandatory field (with extra validator) -->
	                <xsl:when test="$mandatory or not($agivmandatory = '')">validateNonEmpty(this);</xsl:when>
				</xsl:choose>
          	</xsl:variable>
<!--
			<xsl:variable name="helperList">
				<xsl:call-template name="helperList">
			        <xsl:with-param name="schema" select="$schema"/>
			        <xsl:with-param name="attribute" select="false()"/>
			    </xsl:call-template>
			</xsl:variable>
			<xsl:if test="normalize-space($helperList)!='' and $visible">
				<xsl:variable name="list" select="exslt:node-set($helperList)"/>
				<xsl:variable name="ref" select="geonet:element/@ref"/>
				<xsl:variable name="onchange">
					<xsl:if test="$mandatory or not($agivmandatory = '')">\'validateNonEmpty(this)\'</xsl:if>
				</xsl:variable>
			    <xsl:variable name="optionValues" select="replace(replace(string-join($list*[@value]/@value, '#,#'), '''', '\\'''), '#', '''')"/>
			    <xsl:variable name="optionLabels" select="replace(replace(string-join($list/*[@value], '#,#'), '''', '\\'''), '#', '''')"/>
				<xsl:call-template name="combobox">
				    <xsl:with-param name="ref" select="$ref"/>
				    <xsl:with-param name="disabled" select="concat('''',$isXLinked,'''')"/>
				    <xsl:with-param name="onchange" select="$onchange"/>
				    <xsl:with-param name="onkeyup" select="concat('''',$onkeyup,'''')"/>
				    <xsl:with-param name="value" select="text()"/>
				    <xsl:with-param name="optionValues" select="$optionValues"/>
				    <xsl:with-param name="optionLabels" select="$optionLabels"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="not(normalize-space($helperList)!='' and $visible)">
-->
	       		<div style="width:90%">
		            <xsl:call-template name="helper">
		              <xsl:with-param name="schema" select="$schema"/>
		              <xsl:with-param name="attribute" select="false()"/>
		            </xsl:call-template>
	            </div>
	            <input class="md {$class}" type="{$input_type}" value="{text()}">
	    		      <xsl:if test="$mandatory or not($agivmandatory = '')">
				            <xsl:attribute name="onkeyup">validateNonEmpty(this);</xsl:attribute>
			          </xsl:if>
		              <xsl:if test="$isXLinked">
		                <xsl:attribute name="disabled">disabled</xsl:attribute>
		              </xsl:if>
		              <xsl:if test="$input_step">
		                <xsl:attribute name="step"><xsl:value-of select="$input_step"/></xsl:attribute>
		              </xsl:if>
		              <xsl:if test="$tabindex">
		                <xsl:attribute name="tabindex" select="$tabindex"/>
		              </xsl:if>
		              <xsl:choose>
		                <xsl:when test="$no_name=false()">
		                  <xsl:attribute name="name">_<xsl:value-of select="geonet:element/@ref"
		                    /></xsl:attribute>
		                  <xsl:attribute name="id">_<xsl:value-of select="geonet:element/@ref"
		                    /></xsl:attribute>
		                </xsl:when>
		                <xsl:otherwise>
		                  <xsl:attribute name="id">
		                    <xsl:value-of select="geonet:element/@ref"/>
		                  </xsl:attribute>
		                </xsl:otherwise>
		              </xsl:choose>
		
		              <xsl:if test="$visible = false()">
						<xsl:attribute name="style">display:none;</xsl:attribute>
		              </xsl:if>
		              <xsl:if test="normalize-space($onkeyup)!=''">
	                      <xsl:attribute name="onkeyup"><xsl:value-of select="$onkeyup"/></xsl:attribute>
	                  </xsl:if>
	            </input>
<!--            </xsl:if>-->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$edit=true()">
       		<div style="width:90%">
			        <xsl:call-template name="helper">
			          <xsl:with-param name="schema" select="$schema"/>
			          <xsl:with-param name="attribute" select="false()"/>
			        </xsl:call-template>
			</div>
<!-- 		<xsl:variable name="mandatory" select="(name(.)='gmd:LocalisedCharacterString' and ../../geonet:element/@min='1' and not(../../@gco:nilReason='missing')) or (../geonet:element/@min='1' and not(../@gco:nilReason='missing'))"/>-->
			<xsl:variable name="mandatory" select="false()"/>
			<textarea name="_{geonet:element/@ref}" id="_{geonet:element/@ref}">
				<xsl:attribute name="class">md <xsl:value-of select="$class"/><xsl:if test="name(.)='gmx:Anchor'">small</xsl:if></xsl:attribute>
                <xsl:if test="$isXLinked and name(.)!='gmx:Anchor'"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
				<xsl:if test="$visible = false()"><xsl:attribute name="style">display:none;</xsl:attribute></xsl:if>
				<xsl:if test="($mandatory or not($agivmandatory = '')) and $edit"><xsl:attribute name="onkeyup">validateNonEmpty(this);</xsl:attribute></xsl:if>
				<xsl:if test="text()"><xsl:value-of select="string(text())"/></xsl:if>
			</textarea>
      </xsl:when>
      <xsl:when test="$edit=false() and $class!=''">
        <!-- CHECKME -->
        <xsl:choose>
          <xsl:when test="starts-with($schema,'iso19139')">
            <xsl:apply-templates mode="localised" select="..">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- not editable text/codelists -->
        <xsl:variable name="label"
          select="/root/gui/schemas/*[name(.)=$schema]/codelists/codelist[@name = $name]/entry[code=$value]/label"/>
          
        <xsl:variable name="name_parent" select="name(..)"/>
          
        <xsl:choose>
          <xsl:when test="$label">
            <xsl:value-of select="$label"/>
          </xsl:when>
<!-- Normaal is dit correct maar niet meer geactiveerd daar toch enkel DUT in gebruik is en de blok na deze commentaar toch nooit voorvalt  
          <xsl:when test="starts-with($schema,'iso19139') and (name(.)='gco:CharacterString' or name(.)='gmd:PT_FreeText')">
            <xsl:apply-templates mode="localised" select="..">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:apply-templates>
          </xsl:when>
 -->
          <xsl:when test="starts-with($schema,'iso19139') and (gco:CharacterString or gmd:PT_FreeText)">
            <xsl:apply-templates mode="localised" select="..">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:apply-templates>
          </xsl:when>
          <!-- AGIV changing one boolean to other string -->
          <xsl:when test="$name_parent='gmd:pass' or $name_parent='gmd:includedWithDataset'">
            <xsl:variable name="value_" select="/root/gui/schemas/*[name(.)=$schema]/codelists/codelist[@name = $name_parent]/entry[code=$value]/label"/>
            
            <xsl:choose>
                <xsl:when test="$value_">
                    <xsl:value-of select="$value_"/> 
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$value"/>
                </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
	returns the text of an attribute
	-->
  <xsl:template name="getAttributeText">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="class" select="''"/>

    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="@name">
          <xsl:value-of select="@name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="value" select="string(.)"/>
    <xsl:variable name="parent" select="name(..)"/>
    <!-- the following variable is used in place of name as a work-around to
         deal with qualified attribute names like gml:id
		     which if not modified will cause JDOM errors on update because of the
				 way in which changes to ref'd elements are parsed as XML -->
    <xsl:variable name="updatename">
      <xsl:call-template name="getAttributeName">
        <xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="isXLinked" select="count(ancestor-or-self::node()[@xlink:href]) > 0"/>

    <xsl:choose>
      <!-- list of values for existing attribute or non existing ones -->
      <xsl:when test="../geonet:attribute[string(@name)=$name]/geonet:text|geonet:text">
        <select class="md" name="_{../geonet:element/@ref}_{$updatename}" size="1">
          <xsl:if test="$isXLinked">
            <xsl:attribute name="disabled">disabled</xsl:attribute>
          </xsl:if>
          <option name=""/>
          <xsl:for-each select="../geonet:attribute/geonet:text">
            <option>
              <xsl:if test="@value=$value">
                <xsl:attribute name="selected"/>
              </xsl:if>
              <xsl:variable name="choiceValue" select="string(@value)"/>
              <xsl:attribute name="value">
                <xsl:value-of select="$choiceValue"/>
              </xsl:attribute>

              <!-- codelist in edit mode -->
              <xsl:variable name="label"
                select="/root/gui/schemas/*[name(.)=$schema]/codelists/codelist[@name = $parent]/entry[code=$choiceValue]/label"/>
              <xsl:choose>
                <xsl:when test="$label">
                  <xsl:value-of select="$label"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$choiceValue"/>
                </xsl:otherwise>
              </xsl:choose>
            </option>
          </xsl:for-each>
        </select>
      </xsl:when>
      <xsl:when test="$edit=true() and $class=''">
       		<div style="width:90%">
		        <xsl:call-template name="helper">
		          <xsl:with-param name="schema" select="$schema"/>
		          <xsl:with-param name="attribute" select="true()"/>
		        </xsl:call-template>
	        </div>
	        <input class="md {$class}" type="text" id="_{../geonet:element/@ref}_{$updatename}"
	          name="_{../geonet:element/@ref}_{$updatename}" value="{string()}"/>
      </xsl:when>
      <xsl:when test="$edit=true()">
        <textarea class="md {$class}" name="_{../geonet:element/@ref}_{$updatename}"
          id="_{../geonet:element/@ref}_{$updatename}">
          <xsl:value-of select="string()"/>
        </textarea>
      </xsl:when>
      <xsl:otherwise>
        <!-- codelist in view mode -->
        <xsl:variable name="label"
          select="/root/gui/schemas/*[name(.)=$schema]//codelists/codelist[@name = $parent]/entry[code = $value]/label"/>
        <xsl:choose>
          <xsl:when test="$label">
            <xsl:value-of select="$label"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <!-- Create a div with class name set to extentViewer in 
    order to generate a new map. -->
  <xsl:template name="showMap">
    <xsl:param name="edit"/>
    <xsl:param name="coords"/>
    <!-- Indicate which drawing mode is used (ie. bbox or polygon) -->
    <xsl:param name="mode"/>
    <xsl:param name="targetPolygon"/>
    <xsl:param name="watchedBbox"/>
    <xsl:param name="eltRef"/>
    <xsl:param name="descRef"/>
    <div class="extentViewer"
      style="width:{/root/gui/config/map/metadata/width}; height:{/root/gui/config/map/metadata/height};"
      edit="{$edit}" target_polygon="{$targetPolygon}" watched_bbox="{$watchedBbox}"
      elt_ref="{$eltRef}" desc_ref="{$descRef}" mode="{$mode}">
      <div style="display:none;" id="coords_{$eltRef}">
        <xsl:value-of select="$coords"/>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template mode="addCarrierOfCharacteristicsElement" match="*">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="true"/>
    <xsl:param name="embedded"/>
		    <xsl:variable name="name">gfc:carrierOfCharacteristics</xsl:variable>
		    <xsl:variable name="qname">gfcCOLONcarrierOfCharacteristics</xsl:variable>
		    <xsl:variable name="parentName" select="../geonet:element/@ref|@parent"/>
		    <xsl:variable name="max"
		      select="if (../geonet:element/@max) then ../geonet:element/@max else @max"/>
		    <xsl:variable name="prevBrother" select="preceding-sibling::*[1]"/>
		    <xsl:variable name="isXLinked" select="false()"/>
			<xsl:variable name="text">
		        <xsl:variable name="options">
		          <options>
		              <option name="gfc:carrierOfCharacteristics">
		                <xsl:attribute name="selected">selected</xsl:attribute>
		                <xsl:call-template name="getTitle">
		                  <xsl:with-param name="name">gfc:carrierOfCharacteristics</xsl:with-param>
		                  <xsl:with-param name="schema" select="$schema"/>
		                </xsl:call-template>
		              </option>
		          </options>
		        </xsl:variable>
		        <select class="md" name="_{$parentName}_{$qname}_subtemplate" size="1">
		          <xsl:for-each select="exslt:node-set($options)//option">
		            <xsl:sort select="."/>
		            <option value="{@name}"><xsl:value-of select="."/></option>
		          </xsl:for-each>
		        </select>
		    </xsl:variable>
		    <xsl:variable name="addLink">
		    	<xsl:variable name="function">Ext.getCmp('editorPanel').retrieveSubTemplate</xsl:variable>
		       <xsl:value-of select="concat('javascript:', $function, '(',$parentName,',',$apos,$name,$apos,',document.mainForm._',$parentName,'_',$qname,'_subtemplate.value,true);')"/>
		    </xsl:variable>
		    <xsl:variable name="helpLink">
		      <xsl:call-template name="getHelpLink">
		        <xsl:with-param name="name" select="$name"/>
		        <xsl:with-param name="schema" select="$schema"/>
		      </xsl:call-template>
		    </xsl:variable>
		    <xsl:call-template name="simpleElementGui">
		      <xsl:with-param name="title">
		        <xsl:call-template name="getTitle">
		          <xsl:with-param name="name" select="$name"/>
		          <xsl:with-param name="schema" select="$schema"/>
		        </xsl:call-template>
		      </xsl:with-param>
		      <xsl:with-param name="text" select="$text"/>
		      <xsl:with-param name="addLink" select="$addLink"/>
		      <xsl:with-param name="helpLink" select="$helpLink"/>
		      <xsl:with-param name="edit" select="$edit"/>
			</xsl:call-template>
  </xsl:template>

  <xsl:template mode="addElement" match="*">
		<xsl:param name="schema"/>
		<xsl:param name="edit" select="true"/>
		<xsl:param name="visible" select="false()"/>
		<xsl:param name="embedded"/>
		<xsl:param name="ommitNameTag" select="true()"/>
		<xsl:param name="title" />
		<xsl:param name="content" />
		<xsl:variable name="name" select="concat(@prefix,':',@name)"/>
		<xsl:variable name="qname"><xsl:value-of select="concat(@prefix,'COLON',@name)"/></xsl:variable>
	    <xsl:variable name="parentName" select="../geonet:element/@ref|@parent"/>
<!--
	    <xsl:variable name="max" select="if (../geonet:element/@max) then ../geonet:element/@max else @max"/>
		<xsl:variable name="elemId" select="@uuid"/>
-->
		<xsl:variable name="isXLinked" select="false()"/>
		<xsl:variable name="text">
			<xsl:variable name="options">
				<options>
				    <xsl:choose>
						<xsl:when test="$name='gmd:resourceConstraints'">
							<option name="gmd:MD_Constraints" selected="selected" title="Gebruiksrecht - Beperkingen">Invulblok Beperkingen</option>
<!--
							<option name="gmd:MD_Constraints">
								<xsl:attribute name="selected">selected</xsl:attribute>
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name">gmd:MD_Constraints</xsl:with-param>
									<xsl:with-param name="schema" select="$schema"/>
								</xsl:call-template>
							</option>
							<option name="gmd:MD_LegalConstraints">
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name">gmd:MD_LegalConstraints</xsl:with-param>
									<xsl:with-param name="schema" select="$schema"/>
								</xsl:call-template>
							</option>
							<option name="gmd:MD_SecurityConstraints">
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name">gmd:MD_SecurityConstraints</xsl:with-param>
									<xsl:with-param name="schema" select="$schema"/>
								</xsl:call-template>
							</option>
-->
							<xsl:for-each select="/root/gui/schemas/iso19139/labels/element[@name='gmd:resourceConstraints']/subtemplate/option">
								<option name="{concat('gmd:resourceConstraints;',@value)}" title="{@title}"><xsl:value-of select="normalize-space(.)"/></option>
							</xsl:for-each>
							<option name="gmd:MD_SecurityConstraints" title="Gebruiksrecht - Veiligheidsbeperkingen">Invulblok Veiligheidsbeperkingen</option>
						</xsl:when>
						<xsl:when test="$name='gmd:otherConstraints'">
							<xsl:for-each select="/root/gui/schemas/iso19139/labels/element[@name='gmd:otherConstraints']/subtemplate/option">
								<option name="{concat('gmd:otherConstraints;',@value)}" title="{@title}"><xsl:value-of select="normalize-space(.)"/></option>
							</xsl:for-each>
						</xsl:when>
<!--
						<xsl:when test="$name='gmd:otherConstraints'">
							<option name="gmd:otherConstraints|gco:CharacterString" selected="selected" title="Beschrijving (gco:CharacterString)">Beschrijving</option>
							<option name="gmd:otherConstraints|gmx:Anchor" selected="selected" title="Beschrijving en URL (gmx:Anchor)">Beschrijving en URL</option>
						</xsl:when>
-->
						<xsl:when test="$name='gmd:report'">
				        	<xsl:variable name="service" select="../../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='service'"/>
					          	<xsl:if test="$service=false()">
					              <option name="gmd:DQ_CompletenessOmission">
					                <xsl:attribute name="selected">selected</xsl:attribute>
					                <xsl:call-template name="getTitle">
					                  <xsl:with-param name="name">gmd:DQ_CompletenessOmission</xsl:with-param>
					                  <xsl:with-param name="schema" select="$schema"/>
					                </xsl:call-template>
					              </option>
					              <option name="gmd:DQ_AbsoluteExternalPositionalAccuracy">
					                <xsl:call-template name="getTitle">
					                  <xsl:with-param name="name">gmd:DQ_AbsoluteExternalPositionalAccuracy</xsl:with-param>
					                  <xsl:with-param name="schema" select="$schema"/>
					                </xsl:call-template>
					              </option>
					              <option name="gmd:DQ_ThematicClassificationCorrectness">
					                <xsl:call-template name="getTitle">
					                  <xsl:with-param name="name">gmd:DQ_ThematicClassificationCorrectness</xsl:with-param>
					                  <xsl:with-param name="schema" select="$schema"/>
					                </xsl:call-template>
					              </option>
					          	</xsl:if>
					              <option name="gmd:DQ_DomainConsistency">
						          	<xsl:if test="$service=true()">
						                <xsl:attribute name="selected">selected</xsl:attribute>
					                </xsl:if>
					                INSPIRE Domeinconsistentie
					              </option>
						</xsl:when>
						<xsl:otherwise>
						    <option name="{$name}">
								<xsl:attribute name="selected">selected</xsl:attribute>
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name" select="$name" />
									<xsl:with-param name="schema" select="$schema"/>
								</xsl:call-template>
							</option>
						</xsl:otherwise>
					</xsl:choose>
				</options>
			</xsl:variable>
			<select class="md" name="_{$parentName}_{$qname}_subtemplate" size="1">
				<xsl:if test="count(exslt:node-set($options)//option)=1">
					<xsl:attribute name="style">visibility:hidden</xsl:attribute>
				</xsl:if>
				<xsl:for-each select="exslt:node-set($options)//option">
					<xsl:sort select="."/>
					<option value="{@name}" title="{@title}"><xsl:value-of select="."/></option>
				</xsl:for-each>
			</select>
		</xsl:variable>
		<xsl:variable name="addLink">
			<xsl:choose>
				<xsl:when test="$name='gmd:supplementalInformation' or $name='gmd:useLimitation' or $name='gmd:accessConstraints' or $name='gmd:useConstraints' or $name='gmd:classification'"><xsl:value-of select="concat('doNewElementAction(',$apos,'metadata.elem.add.new',$apos,',',$parentName,',',$apos,$name,$apos,',',$apos,'_',$parentName,'_',$name,'_subtemplate_row',$apos,',',$apos,'add',$apos,',',@max,');')"/></xsl:when>
				<xsl:otherwise>
					<xsl:variable name="function">Ext.getCmp('editorPanel').retrieveSubTemplate</xsl:variable>
					<xsl:value-of select="concat('javascript:', $function, '(',$parentName,',',$apos,$name,$apos,',document.mainForm._',$parentName,'_',$qname,'_subtemplate.value,',$ommitNameTag,');')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="helpLink">
			<xsl:call-template name="getHelpLink">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="schema" select="$schema"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="id" select="generate-id(.)"/>
		<xsl:variable name="selectionRow">
		    <xsl:call-template name="simpleElementGui">
				<xsl:with-param name="id" select="concat('_',$parentName,'_',$name,'_subtemplate_row')"/>
				<xsl:with-param name="title">
					<xsl:call-template name="getTitle">
						<xsl:with-param name="name" select="$name"/>
						<xsl:with-param name="schema" select="$schema"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="text" select="$text"/>
				<xsl:with-param name="addLink" select="$addLink"/>
				<xsl:with-param name="helpLink" select="$helpLink"/>
				<xsl:with-param name="edit" select="$edit"/>
				<xsl:with-param name="visible" select="$visible"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="not($content)">
			<xsl:copy-of select="$selectionRow"/>
		</xsl:if>
		<xsl:if test="$content">
		    <tr id="{$id}">
		      <td colspan="2" class="complex">
		        <fieldset>
		          <legend>
		            <span>
		              <xsl:if test="/root/gui/config/metadata-view-toggleTab">
		                <div class="toggle button tgDown" onclick="toggleFieldset(this, Ext.getDom('toggled{$id}'));"
		                  >&#160;</div>
		              </xsl:if>
		              <xsl:choose>
		                <xsl:when test="$title!=''">
		                  <xsl:value-of select="$title"/>
		                </xsl:when>
		                <xsl:otherwise>
		                  <xsl:call-template name="showTitleWithTag">
		                    <xsl:with-param name="title" select="$title"/>
		                  </xsl:call-template>
		                </xsl:otherwise>
		              </xsl:choose>
		            </span>
		          </legend>
		          <!-- Check if divs could be used instead ? -->
		          <table class="gn" id="toggled{$id}">
		            <tbody>
		              <xsl:copy-of select="$selectionRow"/>
		              <xsl:copy-of select="$content"/>
		            </tbody>
		          </table>
		        </fieldset>
		      </td>
		    </tr>
		</xsl:if>
  </xsl:template>

  <xsl:template mode="addSpatialResolutionElement" match="gmd:spatialResolution">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="true"/>
    <xsl:param name="embedded"/>
		    <xsl:variable name="name">gmd:spatialResolution</xsl:variable>
		    <xsl:variable name="qname">gmdCOLONspatialResolution</xsl:variable>
		    <xsl:variable name="parentName" select="../geonet:element/@ref|@parent"/>
		    <xsl:variable name="max"
		      select="if (../geonet:element/@max) then ../geonet:element/@max else @max"/>
		    <xsl:variable name="prevBrother" select="preceding-sibling::*[1]"/>
		    <xsl:variable name="isXLinked" select="false()"/>
<!--         	<xsl:variable name="service" select="../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='service'"/> -->
			<xsl:variable name="text">
		        <xsl:variable name="options">
		          <options>
		              <option name="gmd:MD_Resolution|gmd:equivalentScale">
<!--		          	<xsl:if test="$service=false()">-->
			                <xsl:attribute name="selected">selected</xsl:attribute>
<!--		                </xsl:if>-->
		                <xsl:call-template name="getTitle">
		                  <xsl:with-param name="name">gmd:equivalentScale</xsl:with-param>
		                  <xsl:with-param name="schema" select="$schema"/>
		                </xsl:call-template>
		              </option>
		              <option name="gmd:MD_Resolution|gmd:distance">
<!--
			          	<xsl:if test="$service=true()">
			                <xsl:attribute name="selected">selected</xsl:attribute>
		                </xsl:if>
-->
		                <xsl:call-template name="getTitle">
		                  <xsl:with-param name="name">gmd:distance</xsl:with-param>
		                  <xsl:with-param name="schema" select="$schema"/>
		                </xsl:call-template>
		              </option>
		          </options>
		        </xsl:variable>
		        <select class="md" name="_{$parentName}_{$qname}_subtemplate" size="1">
		          <xsl:for-each select="exslt:node-set($options)//option">
		            <xsl:sort select="."/>
		            <option value="{@name}">
		            	<xsl:if test="@selected='selected'">
                    		<xsl:attribute name="selected">selected</xsl:attribute>
                    	</xsl:if>
		            	<xsl:value-of select="."/>
	            	</option>
		          </xsl:for-each>
		        </select>
		    </xsl:variable>
		    <xsl:variable name="addLink">
		    	<xsl:variable name="function">Ext.getCmp('editorPanel').retrieveSubTemplate</xsl:variable>
		       <xsl:value-of select="concat('javascript:', $function, '(',$parentName,',',$apos,$name,$apos,',document.mainForm._',$parentName,'_',$qname,'_subtemplate.value);')"/>
		    </xsl:variable>
		    <xsl:variable name="helpLink">
		      <xsl:call-template name="getHelpLink">
		        <xsl:with-param name="name" select="$name"/>
		        <xsl:with-param name="schema" select="$schema"/>
		      </xsl:call-template>
		    </xsl:variable>
		    <xsl:call-template name="simpleElementGui">
		      <xsl:with-param name="title">
		        <xsl:call-template name="getTitle">
		          <xsl:with-param name="name" select="$name"/>
		          <xsl:with-param name="schema" select="$schema"/>
		        </xsl:call-template>
		      </xsl:with-param>
		      <xsl:with-param name="text" select="$text"/>
		      <xsl:with-param name="addLink" select="$addLink"/>
		      <xsl:with-param name="helpLink" select="$helpLink"/>
		      <xsl:with-param name="edit" select="$edit"/>
			</xsl:call-template>
  </xsl:template>
</xsl:stylesheet>