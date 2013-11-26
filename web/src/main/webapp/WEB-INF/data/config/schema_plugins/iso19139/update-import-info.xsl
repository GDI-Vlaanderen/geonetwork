<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gml="http://www.opengis.net/gml" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" exclude-result-prefixes="#all">

	<xsl:include href="../iso19139/convert/functions.xsl"/>

	<!-- ================================================================= -->

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

	<xsl:template match="//gmd:MD_Metadata/gmd:characterSet">
	    <gmd:characterSet>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*"/>
		</gmd:characterSet>
		<xsl:if test="count(../gmd:parentIdentifier)=0">
			<gmd:parentIdentifier gco:nilReason="missing">
				<gco:CharacterString/>
			</gmd:parentIdentifier>
		</xsl:if>
	</xsl:template>
	<xsl:template match="gmd:parentIdentifier">
	    <gmd:parentIdentifier>
			<xsl:copy-of select="@*[not(name()='gco:nilReason')]"/>
			<xsl:if test="normalize-space(gco:CharacterString)=''">
				<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
				<gco:CharacterString/>
			</xsl:if>
			<xsl:if test="not(normalize-space(gco:CharacterString)='')">
				<xsl:apply-templates select="*"/>
			</xsl:if>
		</gmd:parentIdentifier>
	</xsl:template>
    <xsl:template match="gmd:useLimitation">
<!--
			<xsl:if test="normalize-space(gco:CharacterString)=''">
				<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
			    <gmd:useLimitation>
					<gco:CharacterString/>
			    </gmd:useLimitation>
			</xsl:if>
-->
			<xsl:if test="gco:CharacterString and not(normalize-space(gco:CharacterString)='')">
				<xsl:copy-of select="@*[not(name()='gco:nilReason')]"/>
			    <gmd:useLimitation>
					<xsl:apply-templates select="*"/>
			    </gmd:useLimitation>
			</xsl:if>
	</xsl:template>

</xsl:stylesheet>
