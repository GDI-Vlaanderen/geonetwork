<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:exslt="http://exslt.org/common" xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:date="http://exslt.org/dates-and-times" xmlns:saxon="http://saxon.sf.net/"
  extension-element-prefixes="saxon"
  exclude-result-prefixes="exslt xlink gco gmd geonet svrl saxon date">

  <!-- ================================================================================ -->
  <!-- 
    returns the help url 
    -->
  <xsl:template name="getHelpLink">
    <xsl:param name="name"/>
    <xsl:param name="schema"/>

    <xsl:choose>
      <xsl:when test="contains($name,'_ELEMENT')">
        <xsl:value-of select="''"/>
      </xsl:when>
      <xsl:otherwise>

        <xsl:variable name="fullContext">
          <xsl:call-template name="getXPath"/>
        </xsl:variable>

        <xsl:value-of
          select="concat($schema,'|', $name ,'|', name(parent::node()) ,'|', $fullContext ,'|', ../@gco:isoType)"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!--
    Returns the title of the parent of an element. 
    * with fullcontext
    * with no context
    and if not found return the getTitle of the element.
    If not found return the getTitle template of the element.
  -->
  <xsl:template name="getParentTitle">
    <xsl:param name="name"/>
    <xsl:param name="schema"/>
	<xsl:variable name="fullContext">
		<xsl:call-template name="getParentXPath"/>
	</xsl:variable>
	<xsl:variable name="parentName" select="name(..)"/>
	<xsl:variable name="parentLabelFullContext" select="string(/root/gui/schemas/iso19139/labels/element[@name=$parentName and @context=$fullContext]/label)"/>
	<xsl:variable name="parentLabel" select="string(/root/gui/schemas/iso19139/labels/element[@name=$parentName and not(@context)]/label)"/>
	<xsl:choose>
		<xsl:when test="normalize-space($parentLabelFullContext)!=''">
			<xsl:value-of select="$parentLabelFullContext"/>
		</xsl:when>
		<xsl:when test="normalize-space($parentLabel)!=''">
			<xsl:value-of select="$parentLabel"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="schema" select="$schema"/>
	      	</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>

  <xsl:template name="getParentXPath">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:if test="not(position() = 1) and not(position() = last())">
        <xsl:value-of select="name()"/>
      </xsl:if>
      <xsl:if test="not(position() = 1) and position() &lt; last()-1">
        <xsl:text>/</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!--
    Returns the title of an element. If the schema is an ISO profil then search:
    * the ISO profil help first
    * with context (ie. context is the class where the element is defined)
    * with no context
    and if not found search the iso19139 main help.
    
    If not iso based, search in corresponding schema.
    
    If not found return the element name.
  -->
  <xsl:template name="getTitle">
    <xsl:param name="name"/>
    <xsl:param name="schema"/>
    <xsl:param name="node" select="."/>
    
    <xsl:variable name="fullContext">
        <xsl:call-template name="getXPath">
			<xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="context" select="name($node/parent::node())"/>
    <xsl:variable name="contextIsoType" select="$node/parent::node()/@gco:isoType"/>
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="starts-with($schema,'iso19139')">

          <!-- Name with context in current schema (full) -->
          <xsl:variable name="schematitleWithContextFull"
            select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and (@context=$fullContext)]/label)"/>

          <!-- Name with context in current schema (parent) -->
          <xsl:variable name="schematitleWithContextParent"
            select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and (@context=$context)]/label)"/>

          <!-- Name with context in current schema (isoType) -->
          <xsl:variable name="schematitleWithContextIsoType"
            select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and (@context=$contextIsoType)]/label)"/>

          <!-- Name with context in current schema -->
          <!--<xsl:variable name="schematitleWithContext"
            select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/label)"/>-->

         <!-- Name with context in base schema (full) -->
          <xsl:variable name="schematitleWithContextFullBase"
            select="string(/root/gui/schemas/iso19139/labels/element[@name=$name and (@context=$fullContext)]/label)"/>

          <!-- Name with context in base schema (parent) -->
          <xsl:variable name="schematitleWithContextParentBase"
            select="string(/root/gui/schemas/iso19139/labels/element[@name=$name and (@context=$context)]/label)"/>

          <!-- Name with context in base schema (isoType) -->
          <xsl:variable name="schematitleWithContextIsoTypeBase"
            select="string(/root/gui/schemas/iso19139/labels/element[@name=$name and (@context=$contextIsoType)]/label)"/>


          <!-- Name with context in base schema -->
          <!--<xsl:variable name="schematitleWithContextIso"
            select="string(/root/gui/schemas/iso19139/labels/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/label)"/>-->

          <!-- Name in current schema -->
          <xsl:variable name="schematitle"
            select="/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and not(@context)]/label/text()"/>
          
          <xsl:choose>
            <xsl:when
              test="normalize-space($schematitleWithContextFull)!=''"><xsl:value-of select="$schematitleWithContextFull"/>
            </xsl:when>
               <xsl:when
              test="normalize-space($schematitleWithContextParent)!=''"><xsl:value-of select="$schematitleWithContextParent"/>
            </xsl:when>
               <xsl:when
              test="normalize-space($schematitleWithContextIsoType)!=''"><xsl:value-of select="$schematitleWithContextIsoType"/>
            </xsl:when>

            <!--<xsl:when
              test="normalize-space($schematitleWithContext)!=''"><xsl:value-of select="$schematitleWithContext"/>
            </xsl:when>-->

            <xsl:when
              test="normalize-space($schematitleWithContextFullBase)!=''"><xsl:value-of select="$schematitleWithContextFullBase"/>
            </xsl:when>
               <xsl:when
              test="normalize-space($schematitleWithContextParentBase)!=''"><xsl:value-of select="$schematitleWithContextParentBase"/>
            </xsl:when>
               <xsl:when
              test="normalize-space($schematitleWithContextIsoTypeBase)!=''"><xsl:value-of select="$schematitleWithContextIsoTypeBase"/>
            </xsl:when>


            <!--<xsl:when
              test="normalize-space($schematitleWithContextIso)!=''"><xsl:value-of select="$schematitleWithContextIso"/>
            </xsl:when>-->

            <xsl:when
              test="normalize-space($schematitle)!=''"><xsl:value-of select="$schematitle"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of
                select="/root/gui/schemas/iso19139/labels/element[@name=$name and not(@context)]/label/string()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <!-- otherwise just get the title out of the approriate schema help file -->

        <xsl:otherwise>
          <xsl:value-of
            select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and not(@context)]/label)"
          />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="normalize-space($title)!=''">
        <xsl:value-of select="$title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- build attribute name (in place of standard attribute name) as a 
    work-around to deal with qualified attribute names like gml:id
    which if not modified will cause JDOM errors on update because of the
    way in which changes to ref'd elements are parsed as XML -->
  <xsl:template name="getAttributeName">
    <xsl:param name="name"/>
    <xsl:choose>
      <xsl:when test="contains($name,':')">
        <xsl:value-of
          select="concat(substring-before($name,':'),'COLON',substring-after($name,':'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>
