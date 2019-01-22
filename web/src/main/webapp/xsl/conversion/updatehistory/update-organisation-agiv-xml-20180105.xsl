<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:gml="http://www.opengis.net/gml" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gfc="http://www.isotc211.org/2005/gfc" exclude-result-prefixes="#all">
	<xsl:output method="xml"/>
	
	<xsl:variable name="responsibleParty">
		<gmd:CI_ResponsibleParty>
			<gmd:individualName>
				<gco:CharacterString>Helpdesk Informatie Vlaanderen</gco:CharacterString>
			</gmd:individualName>
			<gmd:organisationName><gco:CharacterString>agentschap Informatie Vlaanderen</gco:CharacterString>
			</gmd:organisationName>
			<gmd:contactInfo>
				<gmd:CI_Contact>
					<gmd:phone>
						<gmd:CI_Telephone>
							<gmd:voice>
								<gco:CharacterString>+32 9 276 15 00</gco:CharacterString>
							</gmd:voice>
							<gmd:facsimile gco:nilReason="missing">
								<gco:CharacterString />
							</gmd:facsimile>
						</gmd:CI_Telephone>
					</gmd:phone>
					<gmd:address>
						<gmd:CI_Address>
							<gmd:deliveryPoint>
								<gco:CharacterString>Havenlaan 88</gco:CharacterString>
							</gmd:deliveryPoint>
							<gmd:city>
								<gco:CharacterString>Brussel</gco:CharacterString>
							</gmd:city>
							<gmd:postalCode>
								<gco:CharacterString>1000</gco:CharacterString>
							</gmd:postalCode>
							<gmd:country>
								<gco:CharacterString>België</gco:CharacterString>
							</gmd:country>
							<gmd:electronicMailAddress>
								<gco:CharacterString>informatie.vlaanderen@vlaanderen.be</gco:CharacterString>
							</gmd:electronicMailAddress>
						</gmd:CI_Address>
					</gmd:address>
					<gmd:onlineResource>
						<gmd:CI_OnlineResource>
							<gmd:linkage>
								<gmd:URL>https://overheid.vlaanderen.be/informatie-vlaanderen</gmd:URL>
							</gmd:linkage>
						</gmd:CI_OnlineResource>
					</gmd:onlineResource>
				</gmd:CI_Contact>
			</gmd:contactInfo>
		</gmd:CI_ResponsibleParty>
	</xsl:variable>
	
	<xsl:template match="/root">
		<xsl:apply-templates select="gmd:MD_Metadata|gfc:FC_FeatureCatalogue"/>
	</xsl:template>
	<!-- ================================================================= -->
	
	<xsl:template match="gmd:MD_Metadata|gfc:FC_FeatureCatalogue">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="gmd:CI_ResponsibleParty[gmd:organisationName/gco:CharacterString[contains(.,'AGIV') or contains(.,'AIV') or contains(.,'Agentschap Geografische Informatie Vlaanderen') or contains(.,'Agentschap Informatie Vlaanderen') or contains(.,'Informatie Vlaanderen')]]" priority="10">
		<xsl:variable name="xpathExpression"><xsl:call-template name="genPath"/></xsl:variable>
		<xsl:variable name="fileIdentifier" select="//gmd:fileIdentifier/gco:CharacterString|//gfc:FC_FeatureCatalogue/@uuid"/>
		<xsl:variable name="xpath" select="concat($xpathExpression,'/gmd:organisationName/gco:CharacterString')"/>
		<xsl:variable name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/>
		<xsl:variable name="isResponsiblePartyToBeUpdated">
			<xsl:call-template name="isResponsiblePartyToBeUpdated">
				<xsl:with-param name="fileIdentifier" select="$fileIdentifier"/>
				<xsl:with-param name="xpath" select="$xpath"/>
				<xsl:with-param name="role" select="$role"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:message select="concat($fileIdentifier,',',$xpath,',',$role,',',$isResponsiblePartyToBeUpdated=true())"/>
		<xsl:if test="$isResponsiblePartyToBeUpdated=true()">
			<gmd:CI_ResponsibleParty>
				<xsl:for-each select="$responsibleParty/gmd:CI_ResponsibleParty/*">
					<xsl:copy-of select="."/>
				</xsl:for-each>
				<gmd:role>
					<gmd:CI_RoleCode
						codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_RoleCode">
						<xsl:attribute name="codeListValue"
							select="$role" />
					</gmd:CI_RoleCode>
				</gmd:role>
			</gmd:CI_ResponsibleParty>
		</xsl:if>
		<xsl:if test="$isResponsiblePartyToBeUpdated=false()">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="isResponsiblePartyToBeUpdated">
		<xsl:param name="fileIdentifier"/>
		<xsl:param name="xpath"/>
		<xsl:param name="role"/>
		<xsl:choose>
			<xsl:when test="$fileIdentifier='ecc4e0d3-e7be-4755-be91-48985559495d' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ecc4e0d3-e7be-4755-be91-48985559495d' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ecc4e0d3-e7be-4755-be91-48985559495d' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ecc4e0d3-e7be-4755-be91-48985559495d' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ecc4e0d3-e7be-4755-be91-48985559495d' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='4148deef-24c5-4656-b5a4-b11e2aa3efca' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='4148deef-24c5-4656-b5a4-b11e2aa3efca' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='4148deef-24c5-4656-b5a4-b11e2aa3efca' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5751f64f-a0f3-4cb3-aa27-09aace1ec6ef' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5751f64f-a0f3-4cb3-aa27-09aace1ec6ef' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5751f64f-a0f3-4cb3-aa27-09aace1ec6ef' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9b8227ea-fcea-4e17-883e-31ef63e7ee34' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9b8227ea-fcea-4e17-883e-31ef63e7ee34' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9b8227ea-fcea-4e17-883e-31ef63e7ee34' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ae636093-f96c-47b4-ae98-94b3c9fac813' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ae636093-f96c-47b4-ae98-94b3c9fac813' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ae636093-f96c-47b4-ae98-94b3c9fac813' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='b37943c9-8731-4f01-9fc3-c847f387fd23' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='b37943c9-8731-4f01-9fc3-c847f387fd23' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='b37943c9-8731-4f01-9fc3-c847f387fd23' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='cc335613-ace3-49c2-a689-03ccecb7b676' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='cc335613-ace3-49c2-a689-03ccecb7b676' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='cc335613-ace3-49c2-a689-03ccecb7b676' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c5da8a65-ed16-441b-a856-3d399b8cb5ff' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c5da8a65-ed16-441b-a856-3d399b8cb5ff' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c5da8a65-ed16-441b-a856-3d399b8cb5ff' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d7e9c60f-1bd7-4e02-906e-c23434061a55' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d7e9c60f-1bd7-4e02-906e-c23434061a55' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d7e9c60f-1bd7-4e02-906e-c23434061a55' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='bdde74b2-7075-495a-94cc-1972b9d406a6' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='bdde74b2-7075-495a-94cc-1972b9d406a6' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='bdde74b2-7075-495a-94cc-1972b9d406a6' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='224bf8cb-131a-4246-8e71-170964ed6e78' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='224bf8cb-131a-4246-8e71-170964ed6e78' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='224bf8cb-131a-4246-8e71-170964ed6e78' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='16448b03-eb28-45e5-8f0e-5e55989f2087' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='16448b03-eb28-45e5-8f0e-5e55989f2087' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='16448b03-eb28-45e5-8f0e-5e55989f2087' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='49515fac-068f-4b41-a4ac-8e29d43df696' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='49515fac-068f-4b41-a4ac-8e29d43df696' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='49515fac-068f-4b41-a4ac-8e29d43df696' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='49515fac-068f-4b41-a4ac-8e29d43df696' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='49515fac-068f-4b41-a4ac-8e29d43df696' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='49515fac-068f-4b41-a4ac-8e29d43df696' and $xpath='/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmd:LI_ProcessStep/gmd:processor/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='49515fac-068f-4b41-a4ac-8e29d43df696' and $xpath='/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source/gmd:sourceStep/gmd:LI_ProcessStep/gmd:processor/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='cf978e1d-e5ff-4373-95a6-e79c418478e6' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='cf978e1d-e5ff-4373-95a6-e79c418478e6' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3c9e77f4-2e5f-4c1a-a3f3-dd07a0b4918b' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3c9e77f4-2e5f-4c1a-a3f3-dd07a0b4918b' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3918d77d-bb88-4f06-a771-f63a100fa19e' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3918d77d-bb88-4f06-a771-f63a100fa19e' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3a6adf70-b2bf-4ea8-a6d3-ff8bee7e1d46' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3a6adf70-b2bf-4ea8-a6d3-ff8bee7e1d46' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d88aa18d-e72c-4063-969c-1ead406c4775' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d88aa18d-e72c-4063-969c-1ead406c4775' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d88aa18d-e72c-4063-969c-1ead406c4775' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9fe58f02-66f4-4128-b778-4bd2ba2ba4c8' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9fe58f02-66f4-4128-b778-4bd2ba2ba4c8' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9fe58f02-66f4-4128-b778-4bd2ba2ba4c8' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='fe3a8deb-dc08-43c7-9dbc-35fdb084ad06' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='fe3a8deb-dc08-43c7-9dbc-35fdb084ad06' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d0f8f18d-f399-4709-9d3d-122a63249250' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c00cb31e-acf3-4aca-809b-f999131557b5' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c00cb31e-acf3-4aca-809b-f999131557b5' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6ab8947a-2366-4dbc-b40a-74512c123ce2' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6ab8947a-2366-4dbc-b40a-74512c123ce2' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6ab8947a-2366-4dbc-b40a-74512c123ce2' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='publisher'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6ab8947a-2366-4dbc-b40a-74512c123ce2' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='088d800b-70f0-4d79-94e9-ac2478077c8e' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='088d800b-70f0-4d79-94e9-ac2478077c8e' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='088d800b-70f0-4d79-94e9-ac2478077c8e' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a0472f3b-0927-42f5-909b-c765a4fa4721' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a0472f3b-0927-42f5-909b-c765a4fa4721' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a0472f3b-0927-42f5-909b-c765a4fa4721' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d12e8d78-8c1a-48e1-b398-c4cc17501d30' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d12e8d78-8c1a-48e1-b398-c4cc17501d30' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d12e8d78-8c1a-48e1-b398-c4cc17501d30' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='publisher'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d12e8d78-8c1a-48e1-b398-c4cc17501d30' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='e302a6a1-65b3-433e-8828-b26dfd5893d9' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='e302a6a1-65b3-433e-8828-b26dfd5893d9' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='e302a6a1-65b3-433e-8828-b26dfd5893d9' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6916fcba-c2f9-4146-ae69-550edc905cad' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6916fcba-c2f9-4146-ae69-550edc905cad' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6916fcba-c2f9-4146-ae69-550edc905cad' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='publisher'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6916fcba-c2f9-4146-ae69-550edc905cad' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='11d62398-8fa2-44e5-8d98-ec3c2032684d' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='11d62398-8fa2-44e5-8d98-ec3c2032684d' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7bd48678-7c0b-4230-b734-cb5638c66096' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7bd48678-7c0b-4230-b734-cb5638c66096' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7bd48678-7c0b-4230-b734-cb5638c66096' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7bd48678-7c0b-4230-b734-cb5638c66096' and $xpath='/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source/gmd:sourceStep/gmd:LI_ProcessStep/gmd:processor/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='2b043102-8e40-4bd9-8bd3-3afe9e92e822' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='2b043102-8e40-4bd9-8bd3-3afe9e92e822' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='2b043102-8e40-4bd9-8bd3-3afe9e92e822' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='2b043102-8e40-4bd9-8bd3-3afe9e92e822' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='baebdc26-318e-4dea-aaf0-84229d2d6eeb' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='baebdc26-318e-4dea-aaf0-84229d2d6eeb' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='baebdc26-318e-4dea-aaf0-84229d2d6eeb' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='baebdc26-318e-4dea-aaf0-84229d2d6eeb' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='baebdc26-318e-4dea-aaf0-84229d2d6eeb' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1823ffa2-f23e-4253-8251-f6a454b07b73' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1823ffa2-f23e-4253-8251-f6a454b07b73' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c7dc8171-298d-4891-a87a-c75019ae7947' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c7dc8171-298d-4891-a87a-c75019ae7947' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='14b42a7e-da8c-4023-8ad3-850319b10635' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='14b42a7e-da8c-4023-8ad3-850319b10635' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='fbd27f92-0294-4ecd-abb4-fad439edad85' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='fbd27f92-0294-4ecd-abb4-fad439edad85' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a012bbe5-85ec-4e53-ad3e-5b836dc18b26' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a012bbe5-85ec-4e53-ad3e-5b836dc18b26' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a012bbe5-85ec-4e53-ad3e-5b836dc18b26' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a4bfa69d-d6af-4fc9-a3f9-dbac18cf7c93' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a4bfa69d-d6af-4fc9-a3f9-dbac18cf7c93' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d1f7dc6f-a7ce-45d5-917b-22c13e38c6cc' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d1f7dc6f-a7ce-45d5-917b-22c13e38c6cc' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a6a2cedf-4d9b-47c5-9a0a-aec4affa106b' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a6a2cedf-4d9b-47c5-9a0a-aec4affa106b' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a6a2cedf-4d9b-47c5-9a0a-aec4affa106b' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a6a2cedf-4d9b-47c5-9a0a-aec4affa106b' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a6a2cedf-4d9b-47c5-9a0a-aec4affa106b' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a6a2cedf-4d9b-47c5-9a0a-aec4affa106b' and $xpath='/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmd:LI_ProcessStep/gmd:processor/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a6a2cedf-4d9b-47c5-9a0a-aec4affa106b' and $xpath='/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source/gmd:sourceStep/gmd:LI_ProcessStep/gmd:processor/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1539e4b0-b951-4e9d-af7a-da3e8ae02ed5' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1539e4b0-b951-4e9d-af7a-da3e8ae02ed5' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='874b240f-12ac-471f-a2e5-e66e80c1afc3' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='874b240f-12ac-471f-a2e5-e66e80c1afc3' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='05742d0e-1123-4729-a9d3-afa02cb7323e' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='05742d0e-1123-4729-a9d3-afa02cb7323e' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0def6418-8124-4e6a-aebe-8baeb5581e00' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0def6418-8124-4e6a-aebe-8baeb5581e00' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ae12f97a-2f39-47d2-9bd5-a3f9f3fda28a' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ae12f97a-2f39-47d2-9bd5-a3f9f3fda28a' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ae12f97a-2f39-47d2-9bd5-a3f9f3fda28a' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ae12f97a-2f39-47d2-9bd5-a3f9f3fda28a' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5cd08643-9713-4086-a17f-3563e64c3451' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5cd08643-9713-4086-a17f-3563e64c3451' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5cd08643-9713-4086-a17f-3563e64c3451' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1ab51257-3f85-4d46-a1bb-69f21ce08833' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1ab51257-3f85-4d46-a1bb-69f21ce08833' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1ab51257-3f85-4d46-a1bb-69f21ce08833' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1ab51257-3f85-4d46-a1bb-69f21ce08833' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='75bbeac8-86e7-47d3-b00c-e3ae251304bb' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='4790644d-cb9c-4f6f-8dc5-5c01b8546715' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='4790644d-cb9c-4f6f-8dc5-5c01b8546715' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='abee6312-84a9-487a-b1d2-4170fe39356a' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='abee6312-84a9-487a-b1d2-4170fe39356a' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='abee6312-84a9-487a-b1d2-4170fe39356a' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='45a19b58-1ebe-4f7a-bed2-e5259b110686' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='45a19b58-1ebe-4f7a-bed2-e5259b110686' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='45a19b58-1ebe-4f7a-bed2-e5259b110686' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='efd8d2d5-86d5-4f8e-8b09-e2535d5960ba' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='efd8d2d5-86d5-4f8e-8b09-e2535d5960ba' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1014baa5-4eb9-4f25-91e2-ca9fe3af6716' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1014baa5-4eb9-4f25-91e2-ca9fe3af6716' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6b79e452-847b-4fce-8776-c3685b2322cc' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='f5b2c84c-0d78-4efa-a97d-7cd172726572' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='f5b2c84c-0d78-4efa-a97d-7cd172726572' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7eed2ea7-c235-4970-bc26-a9ee50990c43' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7eed2ea7-c235-4970-bc26-a9ee50990c43' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7eed2ea7-c235-4970-bc26-a9ee50990c43' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c9c22523-1f4c-4e83-9453-ca56c6adc3b9' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c9c22523-1f4c-4e83-9453-ca56c6adc3b9' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='148cfb81-9b40-4c62-81b2-14d47f605d63' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='148cfb81-9b40-4c62-81b2-14d47f605d63' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9ac8774b-86d8-4afc-b22a-224a8bb13aee' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9ac8774b-86d8-4afc-b22a-224a8bb13aee' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5ef360a3-8d7d-4bb3-a56a-92e78f4a7f4f' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c220ade3-795a-44ed-93eb-a72dbed8014c' and $xpath='/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='pointOfContact'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c220ade3-795a-44ed-93eb-a72dbed8014c' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c220ade3-795a-44ed-93eb-a72dbed8014c' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c220ade3-795a-44ed-93eb-a72dbed8014c' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c220ade3-795a-44ed-93eb-a72dbed8014c' and $xpath='/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='distributor'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c220ade3-795a-44ed-93eb-a72dbed8014c' and $xpath='/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmd:LI_ProcessStep/gmd:processor/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c220ade3-795a-44ed-93eb-a72dbed8014c' and $xpath='/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source/gmd:sourceStep/gmd:LI_ProcessStep/gmd:processor/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='owner'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0d9b9979-dff1-4144-95b4-042b93fc2129' and $xpath='/gfc:FC_FeatureCatalogue/gfc:producer/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='bcbaf0e5-0711-4694-87dc-c70584ed593f' and $xpath='/gfc:FC_FeatureCatalogue/gfc:producer/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='55507397-030b-4934-9390-8832b18bc70e' and $xpath='/gfc:FC_FeatureCatalogue/gfc:producer/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='originator'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6B0F7A1F-29D3-4CF3-B76A-110961DEB4D4' and $xpath='/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString' and $role='custodian'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="genPath">
		<xsl:param name="prevPath"/>
		<xsl:variable name="attributePrefix"><xsl:if test="count(.|../@*)=count(../@*)">@</xsl:if></xsl:variable>
<!--		<xsl:variable name="currPath" select="concat('/',$attributePrefix,name(),'[',count(preceding-sibling::*[name() = name(current())])+1,']',$prevPath)"/>-->
		<xsl:variable name="elementName"><xsl:choose><xsl:when test="name()='gmd:RS_Identifier' or name()='gmd:MD_Identifier'">*</xsl:when><xsl:otherwise><xsl:value-of select="name()"/></xsl:otherwise></xsl:choose></xsl:variable>
		<xsl:variable name="currPath" select="concat('/',$attributePrefix,$elementName, $prevPath)"/>
		<xsl:if test="not(starts-with($currPath,'/gmd:MD_Metadata')) and not(starts-with($currPath,'/gfc:FC_FeatureCatalogue'))">
			<xsl:for-each select="parent::*">
				<xsl:call-template name="genPath">
					<xsl:with-param name="prevPath" select="$currPath"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="starts-with($currPath,'/gmd:MD_Metadata') or starts-with($currPath,'/gfc:FC_FeatureCatalogue')">
			<xsl:value-of select="$currPath"/>      
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
