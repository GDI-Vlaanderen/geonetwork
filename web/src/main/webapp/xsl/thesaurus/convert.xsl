<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:saxon="http://saxon.sf.net/" xmlns:gmx="http://www.isotc211.org/2005/gmx"
	xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:xlink="http://www.w3.org/1999/xlink" extension-element-prefixes="saxon">

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- Default template to use (ISO19139 keyword by default). -->
	<xsl:variable name="defaultTpl" select="'to-iso19139-keyword'"/>

	<!-- TODO : use a global function -->
	<xsl:variable name="serviceUrl" select="concat(/root/gui/env/server/protocol, '://', 
		/root/gui/env/server/host, ':', /root/gui/env/server/port, /root/gui/locService)"/>
	
	<!-- Load schema plugin conversion -->
	<xsl:include href="../../WEB-INF/data/config/schema_plugins/iso19139/convert/thesaurus-transformation.xsl"/>
	
	<xsl:template match="/">
		<xsl:variable name="tpl"
			select="if (/root/request/transformation and /root/request/transformation != '') 
			then /root/request/transformation else $defaultTpl"/>
		
		<xsl:variable name="keywords" select="/root/*[name() != 'gui' and name() != 'request']/keyword"/>
		
		<xsl:choose>
			<xsl:when test="$keywords">
				<xsl:for-each-group select="$keywords"
					group-by="thesaurus">
					<saxon:call-template name="{$tpl}"/>
				</xsl:for-each-group>
			</xsl:when>
			<xsl:otherwise>
				<saxon:call-template name="{$tpl}"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
</xsl:stylesheet>
