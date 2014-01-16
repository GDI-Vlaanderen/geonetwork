<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
						xmlns:gco="http://www.isotc211.org/2005/gco"
						xmlns:srv="http://www.isotc211.org/2005/srv"
						xmlns:gmd="http://www.isotc211.org/2005/gmd">

	<xsl:template match="/root">
		 <xsl:apply-templates select="gmd:MD_Metadata"/>
	</xsl:template>

	<xsl:template match="gmd:MD_Metadata">
		<thumbnail>
			<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:graphicOverview/gmd:MD_BrowseGraphic
				|gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:graphicOverview/gmd:MD_BrowseGraphic
				|gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']/gmd:graphicOverview/gmd:MD_BrowseGraphic
				|gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:graphicOverview/gmd:MD_BrowseGraphic
				">
				<xsl:if test="gmd:fileName/gco:CharacterString = /root/env/fileName and gmd:fileDescription/gco:CharacterString = /root/env/type">
					<fileName><xsl:value-of select="gmd:fileName/gco:CharacterString" /></fileName>
				</xsl:if>
			</xsl:for-each>
		</thumbnail>
	</xsl:template>

</xsl:stylesheet>
