<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd">

	<xsl:template match="/root">
		 <xsl:apply-templates select="gmd:MD_Metadata"/>
	</xsl:template>

    <!-- match metadataStandardName, set it to ISO19115 -->
	<xsl:template match="gmd:metadataStandardName/gco:CharacterString">
        <xsl:text>ISO19115</xsl:text>
	</xsl:template>

    <!-- match metadataStandardVersion, set it to 2003/Cor.1:2006 -->
    <xsl:template match="gmd:metadataStandardVersion/gco:CharacterString">
        <xsl:text>2003/Cor.1:2006</xsl:text>
    </xsl:template>

    <xsl:template match="@*|node()">
		 <xsl:copy>
			  <xsl:apply-templates select="@*|node()"/>
		 </xsl:copy>
	</xsl:template>

</xsl:stylesheet>