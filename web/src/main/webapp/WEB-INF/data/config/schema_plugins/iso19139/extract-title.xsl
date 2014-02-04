<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
						xmlns:gco="http://www.isotc211.org/2005/gco"
		                xmlns:srv="http://www.isotc211.org/2005/srv"
						xmlns:gmd="http://www.isotc211.org/2005/gmd">

	<xsl:template match="gmd:MD_Metadata">
		 <title><xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString|gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/></title>
	</xsl:template>

</xsl:stylesheet>
