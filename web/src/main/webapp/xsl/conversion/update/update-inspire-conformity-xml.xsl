<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gml="http://www.opengis.net/gml" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" exclude-result-prefixes="#all">

	<xsl:output method="xml"/>
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
	
	<xsl:template match="gmd:pass" priority="10">
		<xsl:variable name="value" select="gco:Boolean/string(.)"/>
	    <xsl:copy>
	    	<gco:Boolean><xsl:choose><xsl:when test="$value='true'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose></gco:Boolean>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
