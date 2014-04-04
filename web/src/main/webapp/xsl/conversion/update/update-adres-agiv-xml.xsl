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
	
	<xsl:template match="gmd:deliveryPoint/gco:CharacterString" priority="10">
        <xsl:analyze-string select="lower-case(normalize-space(.))" regex=".*gebroeders.*van.*ey.*k.*16.*">
            <xsl:matching-substring>
				<gco:CharacterString>Koningin Maria Hendrikaplein 70 bus 110</gco:CharacterString>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="gmd:voice/gco:CharacterString" priority="10">
        <xsl:analyze-string select="normalize-space(.)" regex=".*9.*2.*6.*1.*5.*2.*0.*0.*">
            <xsl:matching-substring>
				<gco:CharacterString>+3292761500</gco:CharacterString>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="gmd:facsimile/gco:CharacterString" priority="10">
        <xsl:analyze-string select="normalize-space(.)" regex=".*9.*2.*6.*1.*5.*2.*9.*9.*">
            <xsl:matching-substring>
				<gco:CharacterString>+3292761505</gco:CharacterString>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
	</xsl:template>
<!-- 	
	<xsl:template match="gmd:country/gco:CharacterString" priority="10">
        <xsl:choose>
            <xsl:when test="lower-case(normalize-space(.))='belgium'">
				<gco:CharacterString>België</gco:CharacterString>
            </xsl:when>
            <xsl:otherwise>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>
 -->	
	<xsl:template match="gmd:electronicMailAddress/gco:CharacterString" priority="10">
        <xsl:choose>
            <xsl:when test="lower-case(normalize-space(.))='info@agiv.be'">
				<gco:CharacterString>contactpunt@agiv.be</gco:CharacterString>
            </xsl:when>
            <xsl:otherwise>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>
	
	<xsl:template match="gmd:useLimitation/gco:CharacterString" priority="10">
		<xsl:variable name="useLimitationLc" select="lower-case(normalize-space(.))"/>		
		<xsl:variable name="length">		
	        <xsl:choose>
	            <xsl:when test="starts-with($useLimitationLc,'geen.') and string-length($useLimitationLc)>5">6</xsl:when>
	            <xsl:when test="starts-with($useLimitationLc,'nvt.') and string-length($useLimitationLc)>4">5</xsl:when>
	            <xsl:when test="starts-with($useLimitationLc,'niet van toepassing.') and string-length($useLimitationLc)>20">21</xsl:when>
	            <xsl:when test="starts-with($useLimitationLc,'geen') and string-length($useLimitationLc)>4">5</xsl:when>
	            <xsl:when test="starts-with($useLimitationLc,'nvt') and string-length($useLimitationLc)>3">4</xsl:when>
	            <xsl:when test="starts-with($useLimitationLc,'niet van toepassing') and string-length($useLimitationLc)>19">20</xsl:when>
	        	<xsl:otherwise>0</xsl:otherwise>
	        </xsl:choose>
        </xsl:variable>
       	<xsl:choose>
           	<xsl:when test="$length!='0'">
				<gco:CharacterString><xsl:value-of select="normalize-space(substring(normalize-space(.),number($length)))"/></gco:CharacterString>
			</xsl:when>
        	<xsl:otherwise>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
            </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
