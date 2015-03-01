<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:template match="/root">
		<xsl:variable name="metadataCount" select="count(/root/metadata)"/>
		<xsl:variable name="status" select="/root/status"/>
		<email>
			<subject>
				<xsl:value-of select="concat(/root/metadatacenter,' - ')"/>
				<xsl:if test="$metadataCount=1">
					<xsl:value-of select="/root/metadata/title"/><xsl:text>.</xsl:text>
				</xsl:if>
				<xsl:if test="$metadataCount>1">
					<xsl:if test="$status='1'">
						<xsl:text>De editeersessie op meerdere metadatarecords werd overgenoemen.</xsl:text>
					</xsl:if>
					<xsl:if test="$status!='1'">
						<xsl:text>meerdere metadatarecords ingediend bij de </xsl:text><xsl:call-template name="aanspreking"/><xsl:text> ter validatie.</xsl:text>
					</xsl:if>
				</xsl:if>
			</subject>	
			<message>
				<xsl:text>Beste </xsl:text><xsl:call-template name="aanspreking"/><xsl:text>,&#10;&#13;</xsl:text>
				<xsl:if test="$metadataCount=1">
					<xsl:call-template name="changeinfo">
						<xsl:with-param name="title" select="/root/metadata/title"/>
						<xsl:with-param name="currentStatus" select="/root/metadata/currentStatus"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$metadataCount>1">
					<xsl:call-template name="changeinfo">
						<xsl:with-param name="currentStatus" select="/root/metadata[1]/currentStatus"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$status!='1' and $status!='3' and $status!='12'">
					<xsl:if test="$metadataCount=1">
						<xsl:text>&#10;&#13;Je kan deze record bekijken via </xsl:text><xsl:value-of select="/root/metadata/url"/><xsl:text>.</xsl:text>
					</xsl:if>
					<xsl:if test="$metadataCount>1">
						<xsl:for-each select="/root/metadata">
							<xsl:text>&#10;&#13;</xsl:text><xsl:value-of select="./title"/>
						</xsl:for-each>				
						<xsl:text>&#10;&#13;Je kan deze records bekijken via volgende URLs:</xsl:text>
						<xsl:for-each select="/root/metadata">
							<xsl:text>&#10;&#13;</xsl:text><xsl:value-of select="./url"/>
						</xsl:for-each>				
					</xsl:if>
				</xsl:if>
				<xsl:if test="$status='2' or $status='9'">
						<xsl:text>&#10;&#13;Voor meer informatie kan je steeds terecht op onze website </xsl:text><xsl:value-of select="/root/siteUrl"/><xsl:text>, of mail naar contactpunt@agiv.be.</xsl:text>
				</xsl:if>
				<xsl:text>&#10;&#13;&#10;&#13;Met vriendelijke groeten,&#10;&#13;Het Metadata-team</xsl:text>
			</message>
		</email>
	</xsl:template>

	<xsl:template name="aanspreking">
		<xsl:variable name="status" select="/root/status"/>
		<xsl:choose>
			<xsl:when test="$status='2' or $status='3' or $status='9' or $status='13' or $status='14'">
				<xsl:text>metadata-editor/-hoofdeditor</xsl:text>
			</xsl:when>
			<xsl:when test="$status='4'">
				<xsl:text>metadata-hoofdeditor</xsl:text>
			</xsl:when>
			<xsl:when test="$status='1' or $status='5'">
				<xsl:text>metadata-editor</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>metadata-beheerder</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
				
	<xsl:template name="changeinfo">
		<xsl:param name="title" />
		<xsl:param name="currentStatus"/>
		<xsl:variable name="metadataCount" select="count(/root/metadata)"/>
		<xsl:variable name="status" select="/root/status"/>
		<xsl:variable name="node" select="/root/node"/>
		<xsl:if test="$currentStatus!='10' and $currentStatus!='11'">
			<xsl:choose>
				<xsl:when test="$status='1'">
					<xsl:text>De editeersessie op </xsl:text><xsl:if test="$metadataCount>1">volgende</xsl:if><xsl:if test="$metadataCount=1">de</xsl:if><xsl:text> metadatarecord</xsl:text><xsl:if test="$metadataCount>1">s</xsl:if><xsl:if test="$metadataCount=1"><xsl:text> met titel '</xsl:text><xsl:value-of select="$title"/><xsl:text>'</xsl:text></xsl:if><xsl:value-of select="concat(' werd door ',/root/user/name, ' ', /root/user/surname, ' van ', /root/group, ' toegekend aan ',/root/targetUser/name, ' ', /root/targetUser/surname, ' van ', /root/targetGroup, '.')"/>
					<xsl:call-template name="changeMessage" />
				</xsl:when>
				<xsl:when test="$status='2'">
					<xsl:text>Jouw wijzigingen aan </xsl:text><xsl:if test="$metadataCount>1">volgende</xsl:if><xsl:if test="$metadataCount=1">de</xsl:if><xsl:text> metadatarecord</xsl:text><xsl:if test="$metadataCount>1">s</xsl:if><xsl:if test="$metadataCount=1"><xsl:text> met titel '</xsl:text><xsl:value-of select="$title"/><xsl:text>'</xsl:text></xsl:if><xsl:text> werden gevalideerd en gepubliceerd.</xsl:text>
					<xsl:call-template name="changeMessage" />
				</xsl:when>
				<xsl:when test="$status='5' or $status='9'">
					<xsl:text>Jouw wijzigingen aan </xsl:text><xsl:if test="$metadataCount>1">volgende</xsl:if><xsl:if test="$metadataCount=1">de</xsl:if><xsl:text> metadatarecord</xsl:text><xsl:if test="$metadataCount>1">s</xsl:if><xsl:if test="$metadataCount=1"><xsl:text> met titel '</xsl:text><xsl:value-of select="$title"/><xsl:text>'</xsl:text></xsl:if><xsl:text> konden niet gevalideerd worden door </xsl:text><xsl:if test="$status='5'">jouw hoofdeditor.</xsl:if><xsl:if test="$status='9'">het AGIV.</xsl:if>
					<xsl:call-template name="changeMessage" />
					<xsl:text>&#10;&#13;&#10;&#13;Je kan de metadatarecord</xsl:text><xsl:if test="$metadataCount>1">s</xsl:if><xsl:text> wijzigen via </xsl:text><xsl:value-of select="/root/siteUrl"/><xsl:text> en opnieuw indienen.</xsl:text>				
				</xsl:when>
				<xsl:when test="$status='12'">
					<xsl:if test="$metadataCount>1">Volgende</xsl:if><xsl:if test="$metadataCount=1">De</xsl:if><xsl:text> metadatarecord</xsl:text><xsl:if test="$metadataCount>1">s</xsl:if><xsl:if test="$metadataCount=1"><xsl:text> met titel '</xsl:text><xsl:value-of select="$title"/><xsl:text>'</xsl:text></xsl:if><xsl:text> werd</xsl:text><xsl:if test="$metadataCount>1">en</xsl:if><xsl:text> </xsl:text><xsl:call-template name="typewijziging"/><xsl:text>.</xsl:text>
					<xsl:call-template name="changeMessage" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$metadataCount>1">Volgende</xsl:if><xsl:if test="$metadataCount=1">De</xsl:if><xsl:text> metadatarecord</xsl:text><xsl:if test="$metadataCount>1">s</xsl:if><xsl:if test="$metadataCount=1"><xsl:text> met titel '</xsl:text><xsl:value-of select="$title"/><xsl:text>'</xsl:text></xsl:if><xsl:text> werd</xsl:text><xsl:if test="$metadataCount>1">en</xsl:if><xsl:text> </xsl:text><xsl:call-template name="typewijziging"/><xsl:value-of select="concat(' door ',/root/user/name, ' ', /root/user/surname, ' van ', /root/group, ' en ')"/><xsl:call-template name="status"/><xsl:text>.</xsl:text>
					<xsl:call-template name="changeMessage" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$currentStatus='10' or $currentStatus='11'">
			<xsl:text>Het </xsl:text><xsl:if test="$currentStatus='10'">depubliceren</xsl:if><xsl:if test="$currentStatus='11'">verwijderen</xsl:if><xsl:text> van </xsl:text><xsl:if test="$metadataCount>1">volgende</xsl:if><xsl:if test="$metadataCount=1">de</xsl:if><xsl:text> metadatarecord</xsl:text><xsl:if test="$metadataCount>1">s</xsl:if><xsl:if test="$metadataCount=1"><xsl:text> met titel '</xsl:text><xsl:value-of select="$title"/><xsl:text>'</xsl:text></xsl:if><xsl:if test="$status='13' or $status='14'"><xsl:text> kon</xsl:text><xsl:if test="$metadataCount>1">den</xsl:if> niet gevalideerd worden</xsl:if><xsl:if test="$status!='13' and $status!='14'"><xsl:text> </xsl:text>werd<xsl:if test="$metadataCount>1">en</xsl:if> gevalideerd</xsl:if><xsl:text> door het AGIV.</xsl:text>
			<xsl:if test="$status='13' or $status='14'">
				<xsl:call-template name="changeMessage" />
<!-- 				<xsl:text>&#10;&#13;&#10;&#13;De metadatarecord</xsl:text><xsl:if test="$metadataCount>1">s</xsl:if><xsl:text> werd</xsl:text><xsl:if test="$metadataCount>1">en</xsl:if><xsl:text> om die reden terug naar zijn oorspronkelijke status "Goedgekeurd door AGIV en gepubliceerd" gebracht.</xsl:text>-->
				<xsl:text>&#10;&#13;&#10;&#13;De metadatarecord</xsl:text><xsl:if test="$metadataCount>1">s</xsl:if><xsl:text> werd</xsl:text><xsl:if test="$metadataCount>1">en</xsl:if><xsl:text> om die reden terug naar zijn oorspronkelijke status</xsl:text><xsl:if test="$metadataCount=1"><xsl:call-template name="previousStatus"/></xsl:if><xsl:text> gebracht.</xsl:text>
			</xsl:if>				
		</xsl:if>
	</xsl:template>

	<xsl:template name="status">
		<xsl:variable name="status" select="/root/status"/>
		<xsl:variable name="node" select="/root/node"/>
		<xsl:choose>
			<xsl:when test="$node='agiv'">
				<xsl:choose>
					<xsl:when test="$status='0'">onbekend</xsl:when>
					<xsl:when test="$status='1'">ontwerp</xsl:when>
					<xsl:when test="$status='2'">goedgekeurd door AGIV en gepubliceerd</xsl:when>
					<xsl:when test="$status='3'">gedepubliceerd</xsl:when>
					<xsl:when test="$status='4'">intern ingediend bij de hoofdeditor ter validatie</xsl:when>
					<xsl:when test="$status='5'">afgekeurd door Hoofdeditor</xsl:when>
					<xsl:when test="$status='6'">pas gecreëerd</xsl:when>
					<xsl:when test="$status='7'">intern goedgekeurd en ingediend bij het AGIV ter validatie</xsl:when>
					<xsl:when test="$status='8'">is klaar voor publicatie</xsl:when>
					<xsl:when test="$status='9'">afgekeurd door AGIV-validator</xsl:when>
					<xsl:when test="$status='10'">ingediend bij het AGIV ter validatie</xsl:when>
					<xsl:when test="$status='11'">ingediend bij het AGIV ter validatie</xsl:when>
					<xsl:when test="$status='12'">verwijderd</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$status='0'">onbekend</xsl:when>
					<xsl:when test="$status='1'">ontwerp</xsl:when>
					<xsl:when test="$status='2'">intern goedgekeurd en gepubliceerd</xsl:when>
					<xsl:when test="$status='3'">gedepubliceerd</xsl:when>
					<xsl:when test="$status='4'">intern ingediend ter validatie</xsl:when>
					<xsl:when test="$status='5'">afgekeurd door Hoofdeditor</xsl:when>
					<xsl:when test="$status='6'">pas gecreëerd</xsl:when>
					<xsl:when test="$status='12'">verwijderd</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="typewijziging">
		<xsl:variable name="status" select="/root/status"/>
		<xsl:choose>
			<xsl:when test="$status='10'">
				<xsl:text>gedepubliceerd</xsl:text>
			</xsl:when>
			<xsl:when test="$status='11' or $status='12'">
				<xsl:text>verwijderd</xsl:text>
			</xsl:when>
			<xsl:otherwise><xsl:text>gewijzigd</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="previousStatus">
		<xsl:variable name="status" select="/root/metadata/previousStatus"/>
		<xsl:text> "</xsl:text>
		<xsl:choose>
			<xsl:when test="$status='0'">Onbekend</xsl:when>
			<xsl:when test="$status='1'">Ontwerp</xsl:when>
			<xsl:when test="$status='2'">Goedgekeurd door AGIV en gepubliceerd</xsl:when>
			<xsl:when test="$status='3'">Gedepubliceerd</xsl:when>
			<xsl:when test="$status='4'">Intern ingediend</xsl:when>
			<xsl:when test="$status='5'">Afgekeurd door Hoofdeditor</xsl:when>
			<xsl:when test="$status='6'">Pas gecreëerd</xsl:when>
			<xsl:when test="$status='7'">Intern goedgekeurd en ingediend bij AGIV</xsl:when>
			<xsl:when test="$status='8'">klaar voor publicatie</xsl:when>
			<xsl:when test="$status='9'">Afgekeurd door AGIV-validator</xsl:when>
			<xsl:when test="$status='10'">Ingediend voor depubliceren</xsl:when>
			<xsl:when test="$status='11'">Ingediend voor verwijderen</xsl:when>
			<xsl:when test="$status='12'">Verwijderd</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
		<xsl:text>"</xsl:text>
	</xsl:template>
	
	<xsl:template name="changeMessage">
		<xsl:variable name="changeMessage" select="normalize-space(/root/changeMessage)"/>
		<xsl:if test="$changeMessage!='Beschrijf hier extra informatie' and $changeMessage!=''">
			<xsl:text>&#10;&#13;&#10;&#13;Extra informatie hierover:</xsl:text>
			<xsl:text>&#10;&#13;</xsl:text><xsl:value-of select="/root/changeMessage"/><xsl:text>&#10;&#13;</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
