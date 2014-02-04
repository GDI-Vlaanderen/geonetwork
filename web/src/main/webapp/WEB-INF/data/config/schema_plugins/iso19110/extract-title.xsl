<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:gfc="http://www.isotc211.org/2005/gfc"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:gco="http://www.isotc211.org/2005/gco">

    <xsl:template match="gfc:FC_FeatureCatalogue|gfc:FC_FeatureType">
		 <title><xsl:value-of select="gmx:name/gco:CharacterString"/></title>
	</xsl:template>

</xsl:stylesheet>
