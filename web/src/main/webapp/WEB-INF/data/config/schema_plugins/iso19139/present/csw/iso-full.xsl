<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gco="http://www.isotc211.org/2005/gco"
										xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
										xmlns:dc ="http://purl.org/dc/elements/1.1/"
										xmlns:dct="http://purl.org/dc/terms/"
										xmlns:gmd="http://www.isotc211.org/2005/gmd"
										xmlns:ows="http://www.opengis.net/ows"
										xmlns:geonet="http://www.fao.org/geonetwork"
										xmlns:skos="http://www.w3.org/2004/02/skos/core#"
										xmlns:xlink="http://www.w3.org/1999/xlink"
										xmlns:gmx="http://www.isotc211.org/2005/gmx"
										exclude-result-prefixes="#all">

	<xsl:param name="lang"/>
	<xsl:param name="displayInfo"/>
	<xsl:param name="thesauriDir"/>
	
<!--
	<xsl:include href="../metadata-iso19139-utils.xsl"/>

	<xsl:variable name="inspire-theme-thesaurus" select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-theme.rdf'))"/>
	<xsl:variable name="inspireThemes" select="$inspire-theme-thesaurus//skos:Concept"/>
	<xsl:variable name="inspire-service-taxonomy-thesaurus" select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-service-taxonomy.rdf'))"/>
	<xsl:variable name="inspireServiceTaxonomyThemes" select="$inspire-service-taxonomy-thesaurus//skos:Concept"/>
	<xsl:variable name="gemet-thesaurus" select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/gemet.rdf'))"/>
	<xsl:variable name="gemetThemes" select="$gemet-thesaurus//skos:Concept"/>
	<xsl:variable name="priority-dataset-thesaurus" select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/PriorityDataset.rdf'))"/>
	<xsl:variable name="priorityDatasetThemes" select="$priority-dataset-thesaurus//skos:Concept"/>
	<xsl:variable name="inspire-featureconcept-thesaurus" select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/featureconcept.rdf'))"/>
	<xsl:variable name="inspireFeatureconceptThemes" select="$inspire-featureconcept-thesaurus//skos:Concept"/>
-->

	<!-- ============================================================================= -->

	<xsl:template match="@*|node()[name(.)!='geonet:info']">
		<xsl:variable name="info" select="geonet:info"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()[name(.)!='geonet:info']"/>
			<!-- GeoNetwork elements added when resultType is equal to results_with_summary -->
			<xsl:if test="$displayInfo = 'true'">
				<xsl:copy-of select="$info"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- ============================================================================= -->

<!--
	<xsl:template match="gmd:keyword[gco:CharacterString]" priority="1000">
		<gmd:keyword>
			<xsl:variable name="title" select="../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString"/>
			<xsl:variable name="anchor">
				<xsl:if test="$title and gco:CharacterString!=''">
				  	<xsl:choose>
				  		<xsl:when test="contains(normalize-space($title),'GEMET') and contains(normalize-space($title),'INSPIRE')">
							<xsl:call-template name="getAnchorByThesaurusAndLangAndTheme">
								<xsl:with-param name="thesaurus" select="$inspireThemes"/>
								<xsl:with-param name="lang" select="'nl'"/>
								<xsl:with-param name="theme" select="gco:CharacterString"/>
							</xsl:call-template>
				  		</xsl:when>
				  		<xsl:when test="contains(normalize-space($title),'GEMET')">
							<xsl:call-template name="getAnchorByThesaurusAndLangAndTheme">
								<xsl:with-param name="thesaurus" select="$gemetThemes"/>
								<xsl:with-param name="lang" select="'nl'"/>
								<xsl:with-param name="theme" select="gco:CharacterString"/>
							</xsl:call-template>
				  		</xsl:when>
				  		<xsl:when test="contains(normalize-space($title),'INSPIRE') and contains(normalize-space($title),'feature concept')">
							<xsl:call-template name="getAnchorByThesaurusAndLangAndTheme">
								<xsl:with-param name="thesaurus" select="$inspireFeatureconceptThemes"/>
								<xsl:with-param name="lang" select="'nl'"/>
								<xsl:with-param name="theme" select="gco:CharacterString"/>
							</xsl:call-template>
				  		</xsl:when>
				  		<xsl:when test="contains(normalize-space($title),'priority data set')">
							<xsl:call-template name="getAnchorByThesaurusAndLangAndTheme">
								<xsl:with-param name="thesaurus" select="$priorityDatasetThemes"/>
								<xsl:with-param name="lang" select="'nl'"/>
								<xsl:with-param name="theme" select="gco:CharacterString"/>
							</xsl:call-template>
				  		</xsl:when>
				  		<xsl:when test="contains(normalize-space($title),'D.4 van de verordening')">
							<xsl:call-template name="getAnchorByThesaurusAndLangAndTheme">
								<xsl:with-param name="thesaurus" select="$inspireServiceTaxonomyThemes"/>
								<xsl:with-param name="lang" select="'nl'"/>
								<xsl:with-param name="theme" select="gco:CharacterString"/>
							</xsl:call-template>
				  		</xsl:when>
				  		<xsl:when test="contains(normalize-space($title),'Vlaamse regio')"></xsl:when>
				  		<xsl:when test="contains(normalize-space($title),'GDI-Vlaanderen') and contains(normalize-space($title),'Service Types')"></xsl:when>
				  		<xsl:when test="contains(normalize-space($title),'GDI-Vlaanderen') and contains(normalize-space($title),'Trefwoorden')"></xsl:when>
				  	</xsl:choose>
				</xsl:if>
			</xsl:variable>
			<xsl:if test="$anchor and $anchor!=''">
				<gmx:Anchor xlink:href="{$anchor}"><xsl:value-of select="gco:CharacterString"/></gmx:Anchor>
			</xsl:if>
			<xsl:if test="not($anchor and $anchor!='')">
				<gco:CharacterString><xsl:value-of select="gco:CharacterString"/></gco:CharacterString>
			</xsl:if>
		</gmd:keyword>
	</xsl:template>
-->

	<!-- ============================================================================= -->

	<xsl:template match="gmd:date[contains(normalize-space(../gmd:title/gco:CharacterString),'GEMET - INSPIRE them')]" priority="1000">
		<gmd:date>
		   <gmd:CI_Date>
		      <gmd:date>
		         <gco:Date>2008-06-01</gco:Date>
		      </gmd:date>
		      <gmd:dateType>
		         <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode"
		                              codeListValue="publication"/>
		      </gmd:dateType>
		   </gmd:CI_Date>
		</gmd:date>
	</xsl:template>

	<xsl:template match="gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString[contains(normalize-space(.),'GEMET - INSPIRE them')]" priority="1000">
		<gco:CharacterString>GEMET - INSPIRE themes, version 1.0</gco:CharacterString>
	</xsl:template>

	</xsl:stylesheet>

