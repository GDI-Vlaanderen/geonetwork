<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
						xmlns:gco="http://www.isotc211.org/2005/gco"
						xmlns:gmd="http://www.isotc211.org/2005/gmd">

	<xsl:template match="/root">
		<xsl:choose>
			<!-- Export ISO19115/19139 XML (just a copy)-->
			<xsl:when test="gmd:MD_Metadata">
				<xsl:apply-templates select="gmd:MD_Metadata"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="gmd:MD_Metadata">
		 <mduuid><xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/[gmd:MD_Identifier|gmd:RS_Identifier]/gmd:code/gco:CharacterString"/></mduuid>
	</xsl:template>

</xsl:stylesheet>
