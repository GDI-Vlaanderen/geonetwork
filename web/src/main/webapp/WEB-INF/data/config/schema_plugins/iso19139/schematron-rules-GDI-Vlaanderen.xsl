<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>
   <xsl:include xmlns:svrl="http://purl.oclc.org/dsdl/svrl" href="../../../xsl/utils-fn.xsl"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="lang"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="thesaurusDir"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="rule"/>
   <xsl:variable xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="loc"
                 select="document(concat('loc/', $lang, '/', substring-before($rule, '.xsl'), '.xml'))"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="Technisch GDI Vlaanderen voorschrift voor metadata 3.0"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml" prefix="gml"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/srv" prefix="srv"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gco" prefix="gco"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.fao.org/geonetwork" prefix="geonet"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2004/02/skos/core#" prefix="skos"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">GDI-Vlaanderen SC-1: gmd:MD_Metadata/gmd:fileIdentifier (Iso element nr. 2) is verplicht aanwezig en niet leeg.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">GDI-Vlaanderen SC-2: MD_Metadata.referenceSystemInfo/*/RS_identifier/code (ISO element nr 207) is aanwezig en niet leeg. </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">GDI-Vlaanderen SC-3: organisationName (ISO-element 376) is aanwezig binnen elk voorkomen van CI_ResponsibleParty en is niet leeg.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">GDI-Vlaanderen SC-4: Objectencatalogus is onderdeel van de dataset (= aangevinkt) (ISO-element 236). Objectencatalogus identifier mag daarom niet leeg zijn.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Er moet minstens één Nederlandstalig trefwoord aanwezig zijn uit de thesaurus ‘GEMET - INSPIRE thema’s, versie 1.0’ met als datum 2008-06-01 indien de MD_Metadata.language gelijk is aan NL (ISO-element 55)</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Technisch GDI Vlaanderen voorschrift voor metadata 3.0</svrl:text>

   <!--PATTERN GDI-Vlaanderen SC-1: gmd:MD_Metadata/gmd:fileIdentifier (Iso element nr. 2) is verplicht aanwezig en niet leeg.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">GDI-Vlaanderen SC-1: gmd:MD_Metadata/gmd:fileIdentifier (Iso element nr. 2) is verplicht aanwezig en niet leeg.</svrl:text>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata" priority="1000" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Metadata"/>
      <xsl:variable name="fileIdentifier"
                    select="gmd:fileIdentifier and not(normalize-space(gmd:fileIdentifier) = '')"/>
      <xsl:variable name="fileIdentifierValue" select="gmd:fileIdentifier/*/text()"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$fileIdentifier"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                parent="#_{geonet:element/@parent}"
                                test="$fileIdentifier">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>gmd:fileIdentifier ontbreekt of is leeg</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$fileIdentifier">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 parent="#_{geonet:element/@parent}"
                                 test="$fileIdentifier">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>gmd:fileIdentifier is aanwezig: <xsl:text/>
               <xsl:copy-of select="$fileIdentifierValue"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

   <!--PATTERN GDI-Vlaanderen SC-2: MD_Metadata.referenceSystemInfo/*/RS_identifier/code (ISO element nr 207) is aanwezig en niet leeg. -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">GDI-Vlaanderen SC-2: MD_Metadata.referenceSystemInfo/*/RS_identifier/code (ISO element nr 207) is aanwezig en niet leeg. </svrl:text>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata[              gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'series'              or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'dataset'              or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = '']"
                 priority="1001"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata[              gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'series'              or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'dataset'              or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = '']"/>
      <xsl:variable name="referenceSystemInfo" select="gmd:referenceSystemInfo"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$referenceSystemInfo"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                parent="#_{geonet:element/@parent}"
                                test="$referenceSystemInfo">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                   Referentie systeem ontbreekt Er dient een horizontaal of verticaal referentiesysteem gedocumenteerd te worden.
                  </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata[            gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'series'            or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'dataset'            or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = '']/gmd:referenceSystemInfo"
                 priority="1000"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata[            gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'series'            or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'dataset'            or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = '']/gmd:referenceSystemInfo"/>
      <xsl:variable name="ReferenceSystemInfo"
                    select="not(normalize-space(gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code)= '')"/>
      <xsl:variable name="ReferenceSystemInfoCodeValue"
                    select="gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code/*/text()"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$ReferenceSystemInfo"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                parent="#_{geonet:element/@parent}"
                                test="$ReferenceSystemInfo">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
              		Referentie systeem code ontbreekt of is leeg.  Er dient een horizontaal of verticaal referentiesysteem gedocumenteerd te worden.
              </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$ReferenceSystemInfo">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 parent="#_{geonet:element/@parent}"
                                 test="$ReferenceSystemInfo">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Code van een horizontaal of verticaal referentiesysteem is aanwezig:  <xsl:text/>
               <xsl:copy-of select="$ReferenceSystemInfoCodeValue"/>
               <xsl:text/>
        			</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

   <!--PATTERN GDI-Vlaanderen SC-3: organisationName (ISO-element 376) is aanwezig binnen elk voorkomen van CI_ResponsibleParty en is niet leeg.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">GDI-Vlaanderen SC-3: organisationName (ISO-element 376) is aanwezig binnen elk voorkomen van CI_ResponsibleParty en is niet leeg.</svrl:text>

	  <!--RULE -->
<xsl:template match="//*/gmd:CI_ResponsibleParty/gmd:organisationName" priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//*/gmd:CI_ResponsibleParty/gmd:organisationName"/>
      <xsl:variable name="organisationName" select=". and not(normalize-space(.)= '')"/>
      <xsl:variable name="organisationNameValue" select="./*/text()"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$organisationName"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                parent="#_{geonet:element/@parent}"
                                test="$organisationName">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Naam van de verantwoordelijke organisatie ontbreekt of is leeg.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$organisationName">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 parent="#_{geonet:element/@parent}"
                                 test="$organisationName">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Naam van de verantwoordelijke organisatie is aanwezig : <xsl:text/>
               <xsl:copy-of select="$organisationNameValue"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>

   <!--PATTERN GDI-Vlaanderen SC-4: Objectencatalogus is onderdeel van de dataset (= aangevinkt) (ISO-element 236). Objectencatalogus identifier mag daarom niet leeg zijn.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">GDI-Vlaanderen SC-4: Objectencatalogus is onderdeel van de dataset (= aangevinkt) (ISO-element 236). Objectencatalogus identifier mag daarom niet leeg zijn.</svrl:text>

	  <!--RULE -->
<xsl:template match="//gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:includedWithDataset"
                 priority="1000"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:includedWithDataset"/>
      <xsl:variable name="uuidrefValueArray" select="../gmd:featureCatalogueCitation/@uuidref"/>
      <xsl:variable name="uuidrefValue" select="normalize-space($uuidrefValueArray[1])"/>
      <xsl:variable name="uuidrefIsValid"
                    select="not(normalize-space(gco:Boolean)='true') or $uuidrefValue!=''"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$uuidrefIsValid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                parent="#_{geonet:element/@parent}"
                                test="$uuidrefIsValid">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Het element 'Objectencatalogus identificator' ontbreekt of is leeg.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$uuidrefIsValid">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 parent="#_{geonet:element/@parent}"
                                 test="$uuidrefIsValid">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Het element 'Objectencatalogus identificator' is aanwezig : <xsl:text/>
               <xsl:copy-of select="$uuidrefValue"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

   <!--PATTERN Er moet minstens één Nederlandstalig trefwoord aanwezig zijn uit de thesaurus ‘GEMET - INSPIRE thema’s, versie 1.0’ met als datum 2008-06-01 indien de MD_Metadata.language gelijk is aan NL (ISO-element 55)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Er moet minstens één Nederlandstalig trefwoord aanwezig zijn uit de thesaurus ‘GEMET - INSPIRE thema’s, versie 1.0’ met als datum 2008-06-01 indien de MD_Metadata.language gelijk is aan NL (ISO-element 55)</svrl:text>

	  <!--RULE -->
<xsl:template match="//gmd:MD_DataIdentification[/gmd:MD_Metadata/gmd:language/*/text()='dut']"
                 priority="1000"
                 mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification[/gmd:MD_Metadata/gmd:language/*/text()='dut']"/>
      <xsl:variable name="inspire-thesaurus"
                    select="document(concat('file:///', $thesaurusDir, '/external/thesauri/theme/inspire-theme.rdf'))"/>
      <xsl:variable name="inspire-theme" select="$inspire-thesaurus//skos:Concept"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($inspire-theme) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                parent="#_{geonet:element/@parent}"
                                test="count($inspire-theme) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
				INSPIRE Thema thesaurus niet gevonden. 
			</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="keyword"
                    select="gmd:descriptiveKeywords/*/gmd:keyword/gco:CharacterString      [../../gmd:thesaurusName/*/gmd:title/*/text()='GEMET - INSPIRE thema''s, versie 1.0' and      ../../gmd:thesaurusName/*/gmd:date/*/gmd:date/gco:Date/text()='2008-06-01' and      ../../gmd:thesaurusName/*/gmd:date/*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='publication']"/>
      <xsl:variable name="inspire-theme-selected"
                    select="count($inspire-thesaurus//skos:Concept[skos:prefLabel[@xml:lang='nl'] = $keyword])"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$inspire-theme-selected &gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                parent="#_{geonet:element/@parent}"
                                test="$inspire-theme-selected &gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
				Er werd geen Nederlandstalig sleutelwoord gevonden afkomstig uit de GEMET - INSPIRE thema''s, versie 1.0 thesaurus gedateerd op 2008-06-01.
			</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$inspire-theme-selected &gt; 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 parent="#_{geonet:element/@parent}"
                                 test="$inspire-theme-selected &gt; 0">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
				Er werd een Nederlandstalig sleutelwoord: <xsl:text/>
               <xsl:copy-of select="$keyword"/>
               <xsl:text/> gevonden dat afkomstig is uit de GEMET - INSPIRE thema''s, versie 1.0 thesaurus gedateerd op 2008-06-01.
			</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
</xsl:stylesheet>