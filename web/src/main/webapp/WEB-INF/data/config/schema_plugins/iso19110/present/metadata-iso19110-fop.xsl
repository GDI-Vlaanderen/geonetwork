<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:gfc="http://www.isotc211.org/2005/gfc" xmlns:gmx="http://www.isotc211.org/2005/gmx"
	xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd"
	exclude-result-prefixes="xs" version="2.0">

	<xsl:template name="metadata-fop-iso19110">
		<xsl:param name="schema" />

		<xsl:for-each select="*[namespace-uri(.)!=$geonetUri]">
			<xsl:call-template name="blockElementFop">
				<xsl:with-param name="block">
					<xsl:choose>
						<xsl:when test="count(*) > 1">
							<xsl:for-each select="*">
								<xsl:call-template name="blockElementFop">
									<xsl:with-param name="label">
										<xsl:call-template name="getTitle">
											<xsl:with-param name="name" select="name()" />
											<xsl:with-param name="schema" select="$schema" />
										</xsl:call-template>
									</xsl:with-param>
									<xsl:with-param name="block">
										<xsl:apply-templates mode="elementFop"
											select=".">
											<xsl:with-param name="schema" select="$schema" />
										</xsl:apply-templates>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates mode="elementFop"
								select=".">
								<xsl:with-param name="schema" select="$schema" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	
	<xsl:template name="Wmetadata-fop-iso19110">
		<xsl:param name="schema" />
<!-- 		<xsl:for-each select="*[namespace-uri(.)!=$geonetUri]"> -->
			<fo:inline font-size="{$font-size}" font-weight="{$font-weight}"
				color="{$font-color}" margin="8pt">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of select="name(.)" />
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:apply-templates mode="blockedFop" select=".">
							<xsl:with-param name="schema" select="$schema" />
							<xsl:with-param name="blockHeaders">FC_FeatureCatalogue|gfc:producer|gfc:featureType|gfc:FC_FeatureAttribute</xsl:with-param>
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
<!-- 				 <xsl:apply-templates mode="blockedFop" select=".">
					<xsl:with-param name="schema" select="$schema" />
					<xsl:with-param name="blockHeaders">FC_FeatureCatalogue|gfc:producer|gfc:FC_FeatureType|gfc:FC_FeatureAttribute</xsl:with-param>
				</xsl:apply-templates>
 -->			</fo:inline>
<!-- 		</xsl:for-each> -->
	</xsl:template>
	
	
	<xsl:template mode="elementFop-iso19110" match="gco:Boolean">
		<xsl:param name="schema"/>
		<xsl:variable name="bool" select="current()"/>
		
		<xsl:call-template name="info-blocks">
			<xsl:with-param name="label" >
				<xsl:call-template name="getTitle">
					<xsl:with-param name="name">
						<xsl:choose>
							<xsl:when
								test="not(contains($schema, 'iso19139')) and not(contains($schema, 'iso19110')) and not(contains($schema, 'iso19135'))">
								<xsl:value-of select="name(..)" />
							</xsl:when>
							<xsl:when test="@codeList">
								<xsl:value-of select="name(..)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="name(..)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="schema" select="$schema" />
					<xsl:with-param name="node" select="."/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="value">
				<xsl:variable name="mappedBoolean">
					<xsl:variable name="context" select="name(..)"/>
					<xsl:variable name="value" select="."/>
			 		<xsl:value-of select="/root/gui/schemas/*[name(.)=$schema]/codelists/codelist[@name=$context]/entry[code=$value]/label"/>
				</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="$mappedBoolean!=''">
						<xsl:value-of select="$mappedBoolean"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="/root/gui/schemas/*[name(.)=$schema]/strings/*[name(.)=$bool]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


</xsl:stylesheet>