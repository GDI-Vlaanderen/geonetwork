<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan"
	exclude-result-prefixes="xalan" xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gfc="http://www.isotc211.org/2005/gfc"
	xmlns:geonet="http://www.fao.org/geonetwork" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:gml="http://www.opengis.net/gml"
	xmlns:saxon="http://saxon.sf.net/"
	extension-element-prefixes="saxon"
	xmlns:xlink="http://www.w3.org/1999/xlink">


	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
	<!-- callbacks from schema templates -->
	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<xsl:template name="newBlock">
		<xsl:param name="title" />
		<xsl:param name="content" />

		<xsl:if test="$content and $content!=''">
			<fo:block-container margin-left="10pt" margin-right="0pt" margin-bottom="5pt">
<!-- 				<fo:block-container width="100%" margin-left="0pt"> -->
					<fo:block width="100%" margin-top="5pt" margin-bottom="5pt">
						<fo:inline font-size="{$title-size}" font-weight="{$title-weight}"
							color="{$title-color}">
							<xsl:value-of select="$title" />
						</fo:inline>
					</fo:block>
					<xsl:copy-of select="$content" />
<!-- 				</fo:block-container>
 -->			</fo:block-container>
		</xsl:if>
	</xsl:template>


	<xsl:template mode="blockedFop" match="*">
		<xsl:param name="schema" />
		<xsl:param name="blockHeaders" />
		<xsl:param name="skipTags" />

		<xsl:if test="not($skipTags) or not(contains($skipTags, node-name(current())))">
			<xsl:choose>
				<xsl:when test="contains($blockHeaders, node-name(current()))">
					<xsl:call-template name="newBlock">
						<xsl:with-param name="title">
							<xsl:call-template name="getTitle">
	
								<xsl:with-param name="name">
									<xsl:choose>
										<xsl:when
											test="not(contains($schema, 'iso19139')) and not(contains($schema, 'iso19110')) and not(contains($schema, 'iso19135'))">
											<xsl:value-of select="name(.)" />
										</xsl:when>
										<xsl:when test="@codeList">
											<xsl:value-of select="name(.)" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="name(.)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="schema" select="$schema" />
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="content">
							<xsl:apply-templates mode="elementFop" select=".">
								<xsl:with-param name="schema" select="$schema" />
								<xsl:with-param name="blockHeaders" select="$blockHeaders" />
								<xsl:with-param name="skipTags" select="$skipTags" />
							</xsl:apply-templates>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="elementFop" select=".">
						<xsl:with-param name="schema" select="$schema" />
						<xsl:with-param name="blockHeaders" select="$blockHeaders" />
						<xsl:with-param name="skipTags" select="$skipTags" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
			
	</xsl:template>


	<xsl:template mode="elementFop" match="*|@*">
		<xsl:param name="schema" />
		<xsl:param name="blockHeaders" />
		<xsl:param name="skipTags" />
	
		<xsl:call-template name="elementFop">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="blockHeaders" select="$blockHeaders"/>
			<xsl:with-param name="skipTags" select="$skipTags"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="elementFop">
		<xsl:param name="schema" />
		<xsl:param name="blockHeaders" />
		<xsl:param name="skipTags" />
	
		<xsl:choose>
			<!-- Is a localized element -->
			<xsl:when test="contains($schema, 'iso19139') and gmd:PT_FreeText">
				<xsl:apply-templates mode="localizedElemFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:when>
			<!-- has children or attributes, existing or potential -->
			<xsl:when
				test="*[namespace-uri(.)!=$geonetUri]|*/@*|geonet:child|geonet:element/geonet:attribute">
				<!-- if it does not have children show it as a simple element -->
				<xsl:if
					test="not(*[namespace-uri(.)!=$geonetUri]|geonet:child|geonet:element/geonet:attribute)">
					<xsl:apply-templates mode="simpleElementFop"
						select=".">
						<xsl:with-param name="schema" select="$schema" />
					</xsl:apply-templates>
				</xsl:if>
				<!-- existing attributes -->
				<xsl:apply-templates mode="simpleElementFop"
					select="*/@*">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>


				<!-- existing and new children -->
				<!-- <xsl:choose> <xsl:when test="$table=''"> -->
				<xsl:apply-templates mode="blockedFop"
					select="*[namespace-uri(.)!=$geonetUri and local-name(.)!='listedValue']|geonet:child">
					<xsl:with-param name="schema" select="$schema" />
					<xsl:with-param name="blockHeaders" select="$blockHeaders" />
					<xsl:with-param name="skipTags" select="$skipTags" />
				</xsl:apply-templates>

				<xsl:variable name="table">
					<xsl:apply-templates mode="tableElementFop"
						select="*[local-name(.)='listedValue']">
						<xsl:sort select="*/gfc:code/gco:CharacterString"
							data-type="number" />
						<xsl:with-param name="schema" select="$schema" />
					</xsl:apply-templates>
				</xsl:variable>

				<xsl:if test="$table!=''">
					<xsl:call-template name="newBlock">
						<xsl:with-param name="title" select="'Domein'"/>
						<xsl:with-param name="content" >
							<fo:table width="100%" table-layout="fixed" border-top=".1pt solid {$title-color}">
								<xsl:choose>
									<xsl:when test="contains($table, '-8: niet gekend')">
										<fo:table-column column-width="80%" border-right=".1pt solid {$title-color}"/>
										<fo:table-column column-width="10%" border-right=".1pt solid {$title-color}"/>
										<fo:table-column column-width="10%" />
									</xsl:when>
									<xsl:otherwise>
										<fo:table-column column-width="10%" border-right=".1pt solid {$title-color}"/>
										<fo:table-column column-width="45%" border-right=".1pt solid {$title-color}"/>
										<fo:table-column column-width="45%" />
									</xsl:otherwise>
								</xsl:choose>
		
								<fo:table-body>
									<fo:table-row background-color="{$background-color}">
										<fo:table-cell >
											<fo:block>Waarde</fo:block>
										</fo:table-cell>
										<fo:table-cell >
											<fo:block>Code</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block>Definitie</fo:block>
										</fo:table-cell>
									</fo:table-row>
									<xsl:copy-of select="$table" />
								</fo:table-body>
							</fo:table>
						</xsl:with-param>
					</xsl:call-template>	
				</xsl:if>
			</xsl:when>

			<!-- neither children nor attributes, just text -->
			<xsl:otherwise>
				<xsl:apply-templates mode="simpleElementFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:template>

	<xsl:template mode="localizedElemFop" match="*">
		<xsl:param name="schema" />
		<xsl:variable name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name" select="name(.)" />
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="UPPER">
			ABCDEFGHIJKLMNOPQRSTUVWXYZ
		</xsl:variable>
		<xsl:variable name="LOWER">
			abcdefghijklmnopqrstuvwxyz
		</xsl:variable>
		<xsl:variable name="text">
			<xsl:call-template name="translatedString">
				<xsl:with-param name="schema" select="$schema" />
				<xsl:with-param name="langId"
					select="concat('#',translate(substring(/root/gui/language,1,2),$LOWER,$UPPER))" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:call-template name="info-blocks">
			<xsl:with-param name="label" select="$title" />
			<xsl:with-param name="value" select="$text" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="simpleElementFop" match="*">
		<xsl:param name="schema" />
		<xsl:param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name">
					<xsl:choose>
						<xsl:when
							test="not(contains($schema, 'iso19139')) and not(contains($schema, 'iso19110')) and not(contains($schema, 'iso19135'))">
							<xsl:value-of select="name(.)" />
						</xsl:when>
						<xsl:when test="@codeList">
							<xsl:value-of select="name(.)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="name(..)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="schema" select="$schema" />
				<xsl:with-param name="node" select=".."/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="text">
			<xsl:call-template name="getElementText">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:param>
		
		<xsl:call-template name="info-blocks">
			<xsl:with-param name="label" select="$title" />
			<xsl:with-param name="value" select="$text" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="simpleElementFop" match="@*">
		<xsl:param name="schema" />
		<xsl:param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name" select="name(../..)" />
				<!-- Usually codelist -->
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="text">
			<xsl:call-template name="getAttributeText">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:param>

		<xsl:call-template name="info-blocks">
			<xsl:with-param name="label" select="$title" />
			<xsl:with-param name="value" select="$text" />
		</xsl:call-template>
	</xsl:template>



	<xsl:template mode="complexElement" match="*">
		<xsl:param name="schema" />
		<xsl:param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name" select="name(.)" />
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="content">
			<xsl:call-template name="getContent">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:param>

		<xsl:call-template name="complexElementFop">
			<xsl:with-param name="title" select="$title" />
			<xsl:with-param name="text" select="text()" />
			<xsl:with-param name="content" select="$content" />
			<xsl:with-param name="schema" select="$schema" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="tableElementFop" match="*">
		<xsl:param name="schema" />
		<fo:table-row>
			<fo:table-cell>
				<fo:block>
					<xsl:value-of select="*/gfc:code/gco:CharacterString" />
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:value-of select="*/gfc:label/gco:CharacterString" />
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:value-of select="*/gfc:definition/gco:CharacterString" />
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template>

	<!-- Special rules -->
	<xsl:template mode="blockedFop" match="gfc:FC_FeatureType">
		<xsl:param name="schema" />
		<xsl:param name="blockHeaders" />
		<xsl:param name="skipTags" />

		<xsl:apply-templates mode="blockedFop" select="*">
			<xsl:with-param name="schema" select="$schema" />
			<xsl:with-param name="blockHeaders" select="$blockHeaders" />
			<xsl:with-param name="skipTags" select="$skipTags" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="elementFop" match="gfc:producer/gmd:CI_ResponsibleParty">
		<xsl:param name="schema" />
		<xsl:param name="blockHeaders" />
		<xsl:param name="skipTags" />

		<xsl:apply-templates mode="blockedFop" select="gmd:organisationName">
			<xsl:with-param name="schema" select="$schema" />
			<xsl:with-param name="blockHeaders" select="$blockHeaders" />
			<xsl:with-param name="skipTags" select="$skipTags" />
		</xsl:apply-templates>
		<xsl:apply-templates mode="blockedFop" select="gmd:role">
			<xsl:with-param name="schema" select="$schema" />
			<xsl:with-param name="blockHeaders" select="$blockHeaders" />
			<xsl:with-param name="skipTags" select="$skipTags" />
		</xsl:apply-templates>
		<xsl:apply-templates mode="blockedFop" select="gmd:contactInfo">
			<xsl:with-param name="schema" select="$schema" />
			<xsl:with-param name="blockHeaders" select="$blockHeaders" />
			<xsl:with-param name="skipTags" select="$skipTags" />
		</xsl:apply-templates>
	</xsl:template>


	<xsl:template mode="simpleElementFop" match="gfc:FC_FeatureType/@*">
	</xsl:template>

	<xsl:template mode="elementFop" match="gmd:MD_Keywords">
		<xsl:param name="schema" />
		<xsl:param name="blockHeaders" />
		<xsl:param name="skipTags" />
		
		<xsl:choose>
		<xsl:when test="$schema='iso19139'">
			<xsl:apply-templates mode="elementFop-iso19139" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			</xsl:apply-templates>
		</xsl:when>
		
		<xsl:otherwise>
			<xsl:call-template name="elementFop">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="blockHeaders" select="$blockHeaders"/>
				<xsl:with-param name="skipTags" select="$skipTags"/>
			</xsl:call-template>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	


	<xsl:template mode="elementFop" match="gmd:CI_ResponsibleParty" >
		<xsl:param name="schema" />
		<xsl:param name="blockHeaders" />
		<xsl:param name="skipTags" />
		
		<xsl:choose>
		<xsl:when test="$schema='iso19139'">
			<xsl:apply-templates mode="elementFop-iso19139" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			</xsl:apply-templates>
		</xsl:when>
		
		<xsl:otherwise>
			<xsl:call-template name="elementFop">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="blockHeaders" select="$blockHeaders"/>
				<xsl:with-param name="skipTags" select="$skipTags"/>
			</xsl:call-template>
		</xsl:otherwise>
		</xsl:choose>
 	</xsl:template>
 	
 	<xsl:template mode="elementFop" match="gmd:RS_Identifier" >
		<xsl:param name="schema" />
		<xsl:param name="blockHeaders" />
		<xsl:param name="skipTags" />
		
		<xsl:choose>
		<xsl:when test="$schema='iso19139'">
			<xsl:apply-templates mode="elementFop-iso19139" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			</xsl:apply-templates>
		</xsl:when>
		
		<xsl:otherwise>
			<xsl:call-template name="elementFop">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="blockHeaders" select="$blockHeaders"/>
				<xsl:with-param name="skipTags" select="$skipTags"/>
			</xsl:call-template>
		</xsl:otherwise>
		</xsl:choose>
 	</xsl:template>
 	
 	
	<xsl:template mode="simpleElementFop" match="gml:beginPosition|gml:endPosition">
		<xsl:param name="schema" />
		<xsl:param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name">
					<xsl:choose>
						<xsl:when
							test="not(contains($schema, 'iso19139')) and not(contains($schema, 'iso19110')) and not(contains($schema, 'iso19135'))">
							<xsl:value-of select="name(.)" />
						</xsl:when>
						<xsl:when test="@codeList">
							<xsl:value-of select="name(.)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="name(.)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="schema" select="$schema" />
				<xsl:with-param name="node" select="."/>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="text">
			<xsl:call-template name="getElementText">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:param>
		
		<xsl:call-template name="info-blocks">
			<xsl:with-param name="label" select="$title" />
			<xsl:with-param name="value" select="$text" />
		</xsl:call-template>
	</xsl:template>
 	
	<!-- prevent drawing of geonet:* elements -->
	<xsl:template mode="elementFop"
		match="geonet:element|geonet:info|geonet:attribute|geonet:schematronerrors" />
	<xsl:template mode="simpleElementFop"
		match="geonet:element|geonet:info|geonet:attribute|geonet:schematronerrors|@codeList|*[@codeList]|@xlink:type|@gco:nilReason" />
	<xsl:template mode="simpleElementFop"
		match="gml:TimePeriod/@gml:id|gml:TimePeriod/@frame|gml:TimePeriod/*/@frame" />
	<xsl:template mode="complexElementFop"
		match="geonet:element|geonet:info|geonet:attribute|geonet:schematronerrors" />

</xsl:stylesheet>
