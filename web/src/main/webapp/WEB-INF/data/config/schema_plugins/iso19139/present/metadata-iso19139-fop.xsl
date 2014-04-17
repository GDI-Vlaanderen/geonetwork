<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:fra="http://www.cnig.gouv.fr/2005/fra" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:geonet="http://www.fao.org/geonetwork" xmlns:date="http://exslt.org/dates-and-times"
	xmlns:exslt="http://exslt.org/common" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs" version="2.0">


	<xsl:template name="metadata-fop-iso19139-unused">
		<xsl:param name="schema" />

		<!-- TODO improve block level element using mode -->
		<xsl:for-each select="*[namespace-uri(.)!=$geonetUri]">

			<xsl:call-template name="blockElementFop">
				<xsl:with-param name="block">
					<xsl:choose>
						<xsl:when test="count(*/*) > 1">
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


	<xsl:template name="metadata-fop-iso19139">
		<xsl:param name="schema" />

		<!-- Title -->
		<xsl:variable name="title">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$title" />
		</xsl:call-template>

		<!-- Date -->
		<xsl:variable name="date">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date |
                ./gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$date" />
		</xsl:call-template>

		<!-- Abstract -->
		<xsl:variable name="abstract">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:abstract">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$abstract" />
		</xsl:call-template>

		<!-- Service Type -->
		<xsl:variable name="serviceType">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/srv:serviceType/gco:LocalName ">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$serviceType" />
		</xsl:call-template>

		<!-- Service Type Version -->
		<xsl:variable name="srvVersion">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/srv:serviceTypeVersion">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$srvVersion" />
		</xsl:call-template>

		<!-- Coupling Type -->
		<xsl:variable name="couplingType">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/srv:couplingType/srv:SV_CouplingType/@codeListValue">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$couplingType" />
		</xsl:call-template>

		<!-- Code -->
		<xsl:variable name="code">
			<xsl:apply-templates mode="elementFop"
				select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$code" />
		</xsl:call-template>

		<!-- Language -->
		<xsl:variable name="lang">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:language">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$lang" />
		</xsl:call-template>

		<!-- Charset Encoding -->
		<xsl:variable name="lang">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:characterSet">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$lang" />
		</xsl:call-template>

		<!-- Hierarchy Level -->
		<xsl:variable name="hierarchy">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$hierarchy" />
		</xsl:call-template>

		<!-- Source Online -->
		<xsl:variable name="online">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage |
                                  ./gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$online" />
			<xsl:with-param name="label">
				<xsl:value-of
					select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:onLine']/label" />
			</xsl:with-param>
		</xsl:call-template>

		<!-- Contact -->
		<xsl:variable name="poc">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:individualName    |
                                  ./gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName  |
                                  ./gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:positionName      |
                                  ./gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$poc" />
			<xsl:with-param name="label">
				<xsl:value-of
					select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:pointOfContact']/label" />
			</xsl:with-param>
		</xsl:call-template>

		<!-- Topic category -->
		<xsl:variable name="topicCat">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:topicCategory">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$topicCat" />
		</xsl:call-template>

		<!-- Keywords -->
		<xsl:variable name="keyword">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword | 
              ./gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$keyword" />
			<xsl:with-param name="label">
				<xsl:value-of
					select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:keyword']/label" />
			</xsl:with-param>
		</xsl:call-template>

		<!-- Geographical extent -->
		<xsl:for-each select="./gmd:identificationInfo/*/gmd:extent">
			<xsl:variable name="geoDesc">
				<xsl:apply-templates mode="elementFop"
					select="./gmd:EX_Extent/gmd:description |
	                ./gmd:identificationInfo/*/srv:extent/gmd:EX_Extent/gmd:description">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:variable name="geoBbox">
				<xsl:apply-templates mode="elementFop"
					select="./gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox |
	              ./gmd:identificationInfo/*/srv:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:variable name="timeExtent">
				<xsl:apply-templates mode="elementFop"
					select="./gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:variable name="geoExtent">
				<xsl:call-template name="blockElementFop">
					<xsl:with-param name="block" select="$geoDesc" />
				</xsl:call-template>
				<xsl:call-template name="blockElementFop">
					<xsl:with-param name="block" select="$geoBbox" />
					<xsl:with-param name="label">
						<xsl:value-of
							select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:EX_GeographicBoundingBox']/label" />
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="blockElementFop">
					<xsl:with-param name="block" select="$timeExtent" />
					<xsl:with-param name="label">
						<xsl:value-of
							select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:temporalElement']/label" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:call-template name="blockElementFop">
				<xsl:with-param name="block" select="$geoExtent" />
				<xsl:with-param name="label">
					<xsl:value-of
						select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:EX_Extent']/label" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<!-- Spatial resolution -->
		<xsl:variable name="spatialResolution">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:spatialResolution">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$spatialResolution" />
			<xsl:with-param name="label">
				<xsl:value-of
					select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:spatialResolution']/label" />
			</xsl:with-param>
		</xsl:call-template>

		<!-- "Généalogie" -->
		<xsl:if
			test="./gmd:identificationInfo/*[name(.)!='srv:SV_ServiceIdentification']">
			<xsl:variable name="qual">
				<xsl:apply-templates mode="elementFop"
					select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:statement">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
				<xsl:apply-templates mode="elementFop"
					select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="blockElementFop">
				<xsl:with-param name="block" select="$qual" />
				<xsl:with-param name="label">
					<xsl:value-of
						select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:lineage']/label" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<!-- Constraints -->
		<xsl:variable name="constraints">
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation/gco:CharacterString">
				<xsl:apply-templates mode="elementFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>

			<xsl:for-each select="./gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:classification">
				<xsl:apply-templates mode="elementFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$constraints" />
			<xsl:with-param name="label">
				<xsl:value-of
					select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:resourceConstraints']/label" />
			</xsl:with-param>
		</xsl:call-template>

		<!-- Identifier -->
		<xsl:variable name="identifier">
			<xsl:apply-templates mode="elementFop" select="./gmd:fileIdentifier">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$identifier" />
		</xsl:call-template>

		<!-- Language -->
		<xsl:variable name="language">
			<xsl:apply-templates mode="elementFop" select="./gmd:language">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$language" />
		</xsl:call-template>

		<!-- Encoding -->
		<xsl:variable name="charset">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:characterSet/gmd:MD_CharacterSetCode/@codeListValue">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$charset" />
		</xsl:call-template>

		<!-- Contact -->
		<xsl:variable name="contact">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:contact/gmd:CI_ResponsibleParty/gmd:individualName">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
			<xsl:apply-templates mode="elementFop"
				select="./gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
			<xsl:apply-templates mode="elementFop"
				select="./gmd:contact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$contact" />
			<xsl:with-param name="label">
				<xsl:value-of
					select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:contact' and not(@context)]/label" />
			</xsl:with-param>
		</xsl:call-template>

		<!-- Date stamp -->
		<xsl:variable name="dateStamp">
			<xsl:apply-templates mode="elementFop" select="./gmd:dateStamp">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="blockElementFop">
			<xsl:with-param name="block" select="$dateStamp" />
		</xsl:call-template>

		<!-- Conformance -->
		<xsl:if
			test="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult[contains(gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString, 'INSPIRE')]">
			<xsl:variable name="conf">
				<xsl:apply-templates mode="elementFop"
					select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
				<xsl:apply-templates mode="elementFop"
					select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
				<xsl:apply-templates mode="elementFop"
					select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
				<xsl:apply-templates mode="elementFop"
					select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:explanation">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
				<xsl:apply-templates mode="elementFop"
					select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:pass">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="blockElementFop">
				<xsl:with-param name="block" select="$conf" />
				<xsl:with-param name="label">
					INSPIRE
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

<xsl:template name="Wmetadata-fop-iso19139">
	<xsl:param name="schema" />
	<xsl:param name="server" />
	<xsl:param name="metadata" />
	<xsl:call-template name="newBlock">
		<xsl:with-param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name">
					<xsl:value-of select="name(./gmd:identificationInfo)" />
				</xsl:with-param>
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="content">
			<!-- Title -->
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:alternateTitle">
				<xsl:apply-templates mode="elementFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>
			<!-- Date -->
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date">
				<xsl:apply-templates mode="elementFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:edition">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
 -->
			<!-- Coupling Type -->
<!-- 			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/srv:couplingType/srv:SV_CouplingType/@codeListValue">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>
 -->			<!-- Code -->
			
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier">
				<xsl:apply-templates mode="elementFop"
					select="./gmd:MD_Identifier/gmd:code">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>


	<xsl:call-template name="newBlock">
		<xsl:with-param name="title" select="'Inhoud'" />
		<xsl:with-param name="content">
			<!-- Abstract -->
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:abstract">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<!-- Purpose -->
			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:purpose">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<!-- Status -->
			
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:status">
				<xsl:apply-templates mode="elementFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>

			<!-- Contactpoints -->
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:pointOfContact">
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
						<xsl:apply-templates mode="elementFop" select=".">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			
			
			<!-- Voorbeeld weergave -->
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:graphicOverview">
				<fo:table>
					<fo:table-column column-width="5cm" />
					<fo:table-column />
					<fo:table-body>
	
					<fo:table-row>
						<fo:table-cell
							background-color="{$background-color}"
							color="{$title-color}" padding-top="4pt" padding-bottom="4pt"
							padding-right="4pt" padding-left="4pt" >
	 						<fo:block linefeed-treatment="preserve">
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name">
										<xsl:value-of select="name(.)" />
									</xsl:with-param>
									<xsl:with-param name="schema" select="$schema" />
								</xsl:call-template>
							</fo:block>						
						</fo:table-cell>
						<fo:table-cell color="{$font-color}" padding-top="4pt"
							padding-bottom="4pt" padding-right="4pt" padding-left="4pt">
	 						<fo:block linefeed-treatment="preserve">
					            <fo:external-graphic content-width="4.6cm">
					              <xsl:variable name="urlTemp" select="/root/gui/imageLinks/link[starts-with(@url,normalize-space(./gmd:MD_BrowseGraphic/gmd:fileName))]"/>
					              <xsl:variable name="url">
									<xsl:choose>
										<xsl:when test="not($urlTemp) or $urlTemp=''">
											<xsl:value-of select="./gmd:MD_BrowseGraphic/gmd:fileName" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$urlTemp" />
										</xsl:otherwise>
									</xsl:choose>
					              </xsl:variable>
								  
					              <xsl:attribute name="src">
					                <xsl:text>url('</xsl:text>
					               		<xsl:value-of select="$url" disable-output-escaping="yes"/> 
					                <xsl:text>')"</xsl:text>
					              </xsl:attribute>
								</fo:external-graphic>
								<xsl:value-of select="./gmd:MD_BrowseGraphic/gmd:fileName" />
							</fo:block>
						</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</xsl:for-each>
			<!-- Keywords -->
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:descriptiveKeywords">
				<xsl:apply-templates mode="elementFop" select="./gmd:MD_Keywords">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>

			<!-- Service type -->
			<xsl:call-template name="newBlock">
				<xsl:with-param name="title">
					<xsl:call-template name="getTitle">
						<xsl:with-param name="name">
							<xsl:value-of select="name(./gmd:identificationInfo/*/srv:serviceType)" />
						</xsl:with-param>
						<xsl:with-param name="schema" select="$schema" />
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="content">
					<!-- Service Type -->
		 			<xsl:apply-templates mode="elementFop"
						select="./gmd:identificationInfo/*/srv:serviceType">
						<xsl:with-param name="schema" select="$schema" />
					</xsl:apply-templates>
		
					<!-- Service Type Version -->
					
					
					<xsl:for-each select="./gmd:identificationInfo/*/srv:serviceTypeVersion">
			 			<xsl:apply-templates mode="elementFop"
							select=".">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
					</xsl:for-each>
					</xsl:with-param>
			</xsl:call-template>

			<!-- Toepassing -->
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:resourceSpecificUsage">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of
									select="name(.)" />
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:apply-templates mode="elementFop"
							select="./gmd:MD_Usage">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			
			<!-- Verwante dataset(series) -->
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:aggregationInfo">
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
						<xsl:apply-templates mode="elementFop"
							select="./gmd:MD_AggregateInformation">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>

			<xsl:for-each select="./gmd:identificationInfo/*/gmd:spatialRepresentationType">
				<xsl:apply-templates mode="elementFop" select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>

			<xsl:for-each select="./gmd:identificationInfo/*/gmd:spatialResolution">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of
									select="name(.)" />
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:for-each select=".">
							<xsl:apply-templates mode="elementFop"
								select=".">
								<xsl:with-param name="schema" select="$schema" />
							</xsl:apply-templates>
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>

			<!-- Language -->
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:language">
				<xsl:apply-templates mode="elementFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>

			<!-- Charset Encoding -->
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:characterSet">
				<xsl:apply-templates mode="elementFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>
			
			<!-- Categorieen -->
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:topicCategory">
				<xsl:apply-templates mode="elementFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>
			
			<!-- Extent -->
			<xsl:for-each select="./gmd:identificationInfo/*/*[local-name()='extent']">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of
									select="name(.)" />
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:apply-templates mode="elementFop"
							select="./gmd:EX_Extent/gmd:description">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
	
						<xsl:call-template name="newBlock">
							<xsl:with-param name="title">
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name">
										<xsl:value-of
											select="name(./gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox[1])" />
									</xsl:with-param>
									<xsl:with-param name="schema" select="$schema" />
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="content">
								<xsl:apply-templates mode="elementFop"
									select="./gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
									<xsl:with-param name="schema" select="$schema" />
								</xsl:apply-templates>
							</xsl:with-param>
						</xsl:call-template>
						
						<xsl:for-each select="./gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicDescription">
							<xsl:apply-templates mode="elementFop" select=".">
								<xsl:with-param name="schema" select="$schema" />
							</xsl:apply-templates>
						</xsl:for-each>
	
						<xsl:call-template name="newBlock">
							<xsl:with-param name="title">
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name">
										<xsl:value-of
											select="name(./gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent)" />
									</xsl:with-param>
									<xsl:with-param name="schema" select="$schema" />
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="content">
								<xsl:apply-templates mode="elementFop"
									select="./gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent">
									<xsl:with-param name="schema" select="$schema" />
								</xsl:apply-templates>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			
			<xsl:for-each select="./gmd:identificationInfo/*/srv:coupledResource">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of
									select="name(.)" />
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
							<xsl:apply-templates mode="elementFop"
								select=".">
								<xsl:with-param name="schema" select="$schema" />
							</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			
			<xsl:for-each select="./gmd:identificationInfo/*/srv:couplingType">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of
									select="name(.)" />
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:apply-templates mode="elementFop"
							select=".">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			
			<xsl:for-each select="./gmd:identificationInfo/*/srv:containsOperations">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of
									select="name(.)" />
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:apply-templates mode="elementFop"
							select=".">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			
			<xsl:for-each select="./gmd:identificationInfo/*/srv:operatesOn">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of
									select="name(.)" />
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:call-template name="info-blocks">
							<xsl:with-param name="label">
								<xsl:text>Datasetnaam waarop de service opereert</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="value">
								<xsl:variable name="idParamValue" select="substring-after(./@xlink:href,';id=')"/>
								<xsl:variable name="uuid">
									<xsl:call-template name="getUuidRelatedMetadata">
										<xsl:with-param name="mduuidValue" select="./@xlink:href"/>
										<xsl:with-param name="idParamValue" select="$idParamValue"/>
									</xsl:call-template>
								</xsl:variable>
								
								<xsl:call-template name="getMetadataTitle">
									<xsl:with-param name="uuid" select="$uuid"/>
								</xsl:call-template>
									
							</xsl:with-param>
						</xsl:call-template>
						<xsl:apply-templates mode="elementFop" select="./@uuidref">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
						<xsl:apply-templates mode="elementFop" select="./@xlink:href">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			

			<xsl:apply-templates mode="elementFop"
				select="./gmd:identificationInfo/*/gmd:supplementalInformation">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

		</xsl:with-param>
	</xsl:call-template>

	<xsl:for-each select="./gmd:referenceSystemInfo">
		<xsl:call-template name="newBlock">
			<xsl:with-param name="title">
				<xsl:call-template name="getTitle">
					<xsl:with-param name="name">
						<xsl:value-of
							select="name(.)" />
					</xsl:with-param>
					<xsl:with-param name="schema" select="$schema" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:apply-templates mode="elementFop" select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:for-each>

	<xsl:for-each select="./gmd:dataQualityInfo">
		<xsl:apply-templates mode="blockedFop" select=".">
			<xsl:with-param name="schema" select="$schema" />
			<xsl:with-param name="blockHeaders">
				gmd:dataQualityInfo|gmd:DQ_DataQuality|gmd:DQ_ThematicClassificationCorrectness|gmd:DQ_AbsoluteExternalPositionalAccuracy|
				gmd:DQ_CompletenessOmission|gmd:DQ_QuantitativeResult|gmd:DQ_QualitativeResult|
				gmd:lineage|gmd_gmd:description|gmd:processStep|gmd:processor|gmd:valueUnit
			</xsl:with-param>
			<xsl:with-param name="skipTags">
				gmd:DQ_DomainConsistency
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:for-each>

	<xsl:call-template name="newBlock">
		<xsl:with-param name="title">
			<xsl:text>INSPIRE Domeinconsistentie</xsl:text>
		</xsl:with-param>
		<xsl:with-param name="content">
			<xsl:apply-templates mode="blockedFop"
				select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency">
				<xsl:with-param name="schema" select="$schema" />
				<xsl:with-param name="blockHeaders">
					gmd:DQ_ConformanceResult|gmd:specification
				</xsl:with-param>
			</xsl:apply-templates>
<!--
			<xsl:call-template name="newBlock">
				<xsl:with-param name="title">
					<xsl:call-template name="getTitle">
						<xsl:with-param name="name">
							<xsl:value-of
								select="name(./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult)" />
						</xsl:with-param>
						<xsl:with-param name="schema" select="$schema" />
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="content">
					<xsl:call-template name="newBlock">
						<xsl:with-param name="title">
							<xsl:call-template name="getTitle">
								<xsl:with-param name="name">
									<xsl:value-of
										select="name(./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification)" />
								</xsl:with-param>
								<xsl:with-param name="schema" select="$schema" />
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="content">
							<xsl:apply-templates mode="elementFop"
								select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title">
								<xsl:with-param name="schema" select="$schema" />
							</xsl:apply-templates>
							<xsl:apply-templates mode="elementFop"
								select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:date">
								<xsl:with-param name="schema" select="$schema" />
							</xsl:apply-templates>
						</xsl:with-param>
					</xsl:call-template>
				
					<xsl:apply-templates mode="elementFop" select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:explanation">
						<xsl:with-param name="schema" select="$schema" />
					</xsl:apply-templates>
					
					<xsl:apply-templates mode="elementFop" select="./gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:pass">
						<xsl:with-param name="schema" select="$schema" />
					</xsl:apply-templates>
				</xsl:with-param>
			</xsl:call-template>
-->
		</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="newBlock">
		<xsl:with-param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name">
					<xsl:text>Gebruiksrecht</xsl:text>	
				</xsl:with-param>
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="content">
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_Constraints">
				<xsl:apply-templates mode="elementFop"
					select=".">
					<xsl:with-param name="schema" select="$schema" />
				</xsl:apply-templates>
			</xsl:for-each>
			<xsl:for-each select="./gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of
									select="name(.)" />
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:apply-templates mode="elementFop"
							select=".">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="newBlock">
		<xsl:with-param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name">
					<xsl:value-of
						select="name(./gmd:distributionInfo)" />
				</xsl:with-param>
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="content">
			<xsl:apply-templates mode="blockedFop"
				select="./gmd:distributionInfo">
				<xsl:with-param name="schema" select="$schema" />
				<xsl:with-param name="blockHeaders">
					gmd:distributionFormat|gmd:distributor|gmd:distributionOrderProcess|gmd:transferOptions|
					gmd:onLine
				</xsl:with-param>
			</xsl:apply-templates>
		</xsl:with-param>
	</xsl:call-template>

	<!-- Meta-metadata -->
	<xsl:call-template name="newBlock">
		<xsl:with-param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name">
					<xsl:value-of
						select="'Meta-metadata'"/>
				</xsl:with-param>
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="content">
			<xsl:apply-templates mode="elementFop" select="./gmd:fileIdentifier">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<xsl:apply-templates mode="elementFop" select="./gmd:language">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<xsl:apply-templates mode="elementFop" select="./gmd:characterSet">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<xsl:apply-templates mode="elementFop"
				select="./gmd:parentIdentifier">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<xsl:apply-templates mode="elementFop" select="./gmd:hierarchyLevel">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<xsl:apply-templates mode="elementFop" select="./gmd:hierarchyLevelName">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<xsl:apply-templates mode="elementFop" select="./gmd:dateStamp">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<xsl:apply-templates mode="elementFop"
				select="./gmd:metadataStandardName">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<xsl:apply-templates mode="elementFop"
				select="./gmd:metadataStandardVersion">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>


			<!-- Meta-metadata -->
			<xsl:for-each select="./gmd:contact">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of
									select="'Metadata-auteur'"/>
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:apply-templates mode="elementFop" select=".">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			
		</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="newBlock">
		<xsl:with-param name="title">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name">
					<xsl:value-of
						select="name(./gmd:contentInfo)" />
				</xsl:with-param>
				<xsl:with-param name="schema" select="$schema" />
			</xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="content">
			<xsl:apply-templates mode="elementFop"
				select="./gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:includedWithDataset">
				<xsl:with-param name="schema" select="$schema" />
			</xsl:apply-templates>

			<xsl:for-each select="./gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:featureCatalogueCitation">
				<xsl:call-template name="newBlock">
					<xsl:with-param name="title">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name">
								<xsl:value-of
									select="name(.)" />
							</xsl:with-param>
							<xsl:with-param name="schema" select="$schema" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:apply-templates mode="elementFop"
							select="./gmd:CI_Citation/gmd:title">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
						<xsl:apply-templates mode="elementFop"
							select="./@uuidref">
							<xsl:with-param name="schema" select="$schema" />
						</xsl:apply-templates>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:with-param>
	</xsl:call-template>

	</xsl:template>

	<xsl:template mode="elementFop-iso19139" match="gmd:CI_ResponsibleParty" >
		<xsl:param name="schema" />
		
		<xsl:apply-templates mode="elementFop"
			select="./gmd:individualName |
					./gmd:organisationName  |
		            ./gmd:positionName">
			<xsl:with-param name="schema" select="$schema" />
		</xsl:apply-templates>
	
		<!-- Contact -->
		<xsl:apply-templates mode="elementFop"
			select="./gmd:contactInfo">
			<xsl:with-param name="schema" select="$schema" />
		</xsl:apply-templates>
		
		<!-- Role -->
		<xsl:apply-templates mode="elementFop"
			select="./gmd:role">
			<xsl:with-param name="schema" select="$schema" />
		</xsl:apply-templates>
	
	</xsl:template>
	
	<xsl:template mode="elementFop-iso19139" match="gmd:CI_ResponsibleParty/gmd:role|gmd:DQ_Scope/gmd:level|gmd:MD_LegalConstraints/gmd:accessConstraints|gmd:MD_LegalConstraints/gmd:useConstraints|gmd:dateType|gmd:status|gmd:associationType|gmd:spatialRepresentationType|gmd:hierarchyLevel|gmd:MD_Medium/gmd:name" >
		<xsl:param name="schema" />
		<xsl:variable name="codeList"><xsl:value-of select="*/@codeListValue"/></xsl:variable>
		<xsl:if test="$codeList!=''">
			<xsl:call-template name="info-blocks">
				<xsl:with-param name="label">
					<xsl:call-template name="getTitle">
						<xsl:with-param name="name" select="name(.)" />
						<xsl:with-param name="schema" select="$schema" />
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="value">
					<xsl:variable name="nameOfFirstChild"><xsl:value-of select="name(*[1])"/></xsl:variable>
					<xsl:variable name="label"><xsl:value-of select="/root/gui/schemas/*[name(.)='iso19139']/codelists/codelist[@name=$nameOfFirstChild]/entry[code=$codeList]/label"/></xsl:variable>
					<xsl:variable name="description"><xsl:value-of select="/root/gui/schemas/*[name(.)='iso19139']/codelists/codelist[@name=$nameOfFirstChild]/entry[code=$codeList]/description"/></xsl:variable>
					<xsl:value-of select="$label"/>: <xsl:value-of select="$description"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="elementFop-iso19139" match="gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty|gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty" >
		<xsl:param name="schema" />
		
		<xsl:apply-templates mode="elementFop"
			select="./gmd:individualName |
					./gmd:organisationName  |
		            ./gmd:positionName">
			<xsl:with-param name="schema" select="$schema" />
		</xsl:apply-templates>
	
		<!-- Role -->
		<xsl:apply-templates mode="elementFop"
			select="./gmd:role">
			<xsl:with-param name="schema" select="$schema" />
		</xsl:apply-templates>
	
		<!-- Contact -->
		<xsl:apply-templates mode="elementFop"
			select="./gmd:contactInfo">
			<xsl:with-param name="schema" select="$schema" />
		</xsl:apply-templates>
		
	</xsl:template>
	
	<xsl:template mode="elementFop-iso19139" match="gmd:MD_Keywords">
		<xsl:param name="schema" />
		<xsl:call-template name="info-blocks">
			<xsl:with-param name="label">
				<xsl:call-template name="getTitle">
					<xsl:with-param name="name" select="name(.)" />
					<xsl:with-param name="schema" select="$schema" />
				</xsl:call-template>

				<xsl:if test="gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString">
					<xsl:text>&#xA;</xsl:text>
					<fo:inline font-style="italic">
						<xsl:value-of select="gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString" />
					</fo:inline>
					<xsl:text>&#xA;</xsl:text>
				</xsl:if>
			</xsl:with-param>
			<xsl:with-param name="value">
				<xsl:for-each select="gmd:keyword">
					<xsl:if test="position() &gt; 1">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="*"/>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	
	
	<xsl:template mode="elementFop-iso19139" match="gmd:RS_Identifier">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
		<xsl:variable name="code" select="."/>
		
        <xsl:apply-templates mode="simpleElementFop" select=".">
            <xsl:with-param name="schema"   select="$schema"/>
            <xsl:with-param name="title">
				<xsl:call-template name="getTitle">
				    <xsl:with-param name="name"   select="name($code/gmd:code)"/>
				    <xsl:with-param name="schema" select="$schema"/>
				    <xsl:with-param name="node" select="$code/gmd:code"/>
				</xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="text">
            	<xsl:variable name="codeDescription" select="normalize-space(/root/gui/schemas/iso19139/labels/element[@name = 'gmd:code' and @context='gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code']/helper/option[@value=$code/gmd:code/gco:CharacterString])"/>
            	<xsl:if test="$codeDescription=''">
            		<xsl:value-of select="gco:CharacterString"/>
           		</xsl:if>
            	<xsl:if test="not($codeDescription='')">
            		<xsl:value-of select="$codeDescription"/>
           		</xsl:if>
            </xsl:with-param>
         </xsl:apply-templates>
        <xsl:apply-templates mode="elementFop" select="./gmd:codeSpace">
            <xsl:with-param name="schema"   select="$schema"/>
         </xsl:apply-templates>
    </xsl:template>

 	<xsl:template mode="elementFop-iso19139" match="gco:Boolean">
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
	
	<xsl:template mode="elementFop-iso19139" match="gmd:DQ_QuantitativeResult">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
        
			<xsl:call-template name="newBlock">
				<xsl:with-param name="title">
					<xsl:call-template name="getTitle">
						<xsl:with-param name="name">
							<xsl:value-of
								select="name(./gmd:valueUnit/gml:UnitDefinition)" />
						</xsl:with-param>
						<xsl:with-param name="schema" select="$schema" />
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="content">
					<xsl:apply-templates mode="elementFop"
						select="./gmd:valueUnit/gml:UnitDefinition/gml:identifier">
						<xsl:with-param name="schema" select="$schema" />
					</xsl:apply-templates>
					
					<xsl:apply-templates mode="elementFop"
						select="./gmd:valueUnit/gml:UnitDefinition/gml:identifier/@codeSpace">
						<xsl:with-param name="schema" select="$schema" />
					</xsl:apply-templates>
					
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates mode="elementFop"
			select="./gmd:valueUnit/gml:UnitDefinition/gml:name">
			<xsl:with-param name="schema" select="$schema" />
		</xsl:apply-templates>
					
		<xsl:apply-templates mode="elementFop"
			select="./gmd:value">
			<xsl:with-param name="schema" select="$schema" />
		</xsl:apply-templates>
	
	
        
    </xsl:template>
		
	<xsl:template mode="elementFop-iso19139" match="gmd:language">
        <xsl:param name="schema"/>
        <xsl:param name="edit"/>
		
        <xsl:variable name="guilang"  select="/root/gui/language"/>
		<xsl:variable name="lang">
			<xsl:choose>
				<xsl:when test="gmd:LanguageCode">
					<xsl:value-of select="string(gmd:LanguageCode/@codeListValue)"/>
				</xsl:when>
				<xsl:when test="gco:CharacterString">
					<xsl:value-of select="gco:CharacterString"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>dut</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
       	
		<xsl:call-template name="info-blocks">
			<xsl:with-param name="label" >
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
			</xsl:with-param>
			<xsl:with-param name="value" select="/root/gui/isolanguages/record[code=$lang]/label/child::*[name() = $guilang]" />
		</xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>
