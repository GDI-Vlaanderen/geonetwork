<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gml="http://www.opengis.net/gml" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" exclude-result-prefixes="#all">

	<xsl:template match="/root">
		<xsl:apply-templates select="gmd:MD_Metadata"/>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="gmd:MD_Metadata">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
	</xsl:template>
	<!-- Only set metadataStandardName and metadataStandardVersion
	if not set. -->
	<xsl:template match="gmd:metadataStandardName" priority="10">
        <xsl:variable name="dataset" select="../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset'"/>
        <xsl:variable name="service" select="../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='service'"/>
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="$service">
					<gco:CharacterString>ISO 19119:2005/Amd 1:2008</gco:CharacterString>
				</xsl:when>
<!--
				<xsl:when test="$dataset">
					<gco:CharacterString>ISO 19115/2003/Cor.1:2006</gco:CharacterString>
				</xsl:when>
-->
				<xsl:otherwise>
					<xsl:copy-of select="@*"/>
					<gco:CharacterString>ISO 19115/2003/Cor.1:2006</gco:CharacterString>
<!--					<xsl:apply-templates select="*"/>-->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="gmd:metadataStandardVersion" priority="10">
		<xsl:copy>
			<gco:CharacterString>GDI-Vlaanderen Best Practices - versie 1.0</gco:CharacterString>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
