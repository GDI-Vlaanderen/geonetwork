<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							xmlns:ogc="http://www.opengis.net/ogc"
							exclude-result-prefixes="ogc">

	<xsl:template match="*">
		<xsl:choose>
			<!-- Applied default criteria to exclude template from results -->
			<xsl:when test="//*[name(.)='ogc:PropertyIsEqualTo' and ogc:PropertyName='_isWorkspace']">
				<isWorkspace><xsl:call-template name="//*[name(.)='ogc:PropertyIsEqualTo' and ogc:PropertyName='_isWorkspace'][1]"/></isWorkspace>
			</xsl:when>
			<xsl:otherwise>
				<isWorkspace>false</isWorkspace>
			</xsl:otherwise>
		</xsl:choose>
		<isWorkspace><xsl:apply-templates select="//*[ogc:PropertyName='_isWorkspace']"/></isWorkspace>
	</xsl:template>

	<xsl:template match="ogc:PropertyIsEqualTo">
		<xsl:choose>
			<xsl:when test="ogc:Literal='true'">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
