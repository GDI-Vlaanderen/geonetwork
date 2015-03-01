<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!--GDI-Vlaanderen Metadata Best practices Schematron regels -->
<!-- 2013-01-30 Versie 0.9 -->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" queryBinding="xslt2">
	<sch:title xmlns="http://www.w3.org/2001/XMLSchema">Technisch GDI Vlaanderen voorschrift voor metadata 3.0</sch:title>
	<sch:ns prefix="gml" uri="http://www.opengis.net/gml"/>
	<sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
	<sch:ns prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
	<sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
	<sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
	<sch:ns prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
	<sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
	<!-- GDI-Vlaanderen SC-1 -->
	<sch:pattern>
		<sch:title>GDI-Vlaanderen SC-1: gmd:MD_Metadata/gmd:fileIdentifier (Iso element nr. 2) is verplicht aanwezig en niet leeg.</sch:title>
		<sch:rule context="//gmd:MD_Metadata">
			<sch:let name="fileIdentifier" value="gmd:fileIdentifier and not(normalize-space(gmd:fileIdentifier) = '')"/>
			<sch:let name="fileIdentifierValue" value="gmd:fileIdentifier/*/text()"/>
			<sch:assert test="$fileIdentifier">gmd:fileIdentifier ontbreekt of is leeg</sch:assert>
			<sch:report test="$fileIdentifier">gmd:fileIdentifier is aanwezig: <sch:value-of select="$fileIdentifierValue"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- GDI-Vlaanderen SC2-->
	<sch:pattern>
		<sch:title>GDI-Vlaanderen SC-2: MD_Metadata.referenceSystemInfo/*/RS_identifier/code (ISO element nr 207) is aanwezig en niet leeg. </sch:title>

        <sch:rule context="//gmd:MD_Metadata[
             gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'series'
             or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'dataset'
             or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = '']">
                            <sch:let name="referenceSystemInfo" value="gmd:referenceSystemInfo"/>
             <sch:assert test="$referenceSystemInfo">
                   Referentie systeem ontbreekt Er dient een horizontaal of verticaal referentiesysteem gedocumenteerd te worden.
                  </sch:assert>
        </sch:rule>

		<sch:rule context="//gmd:MD_Metadata[
        			gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'series'
        			or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = 'dataset'
        			or gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue/normalize-space(.) = '']/gmd:referenceSystemInfo">
                        <sch:let name="ReferenceSystemInfo" value="not(normalize-space(gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code)= '')"/>
        			<sch:let name="ReferenceSystemInfoCodeValue" value="gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code/*/text()"/>
        			<sch:assert test="$ReferenceSystemInfo">
              		Referentie systeem code ontbreekt of is leeg.  Er dient een horizontaal of verticaal referentiesysteem gedocumenteerd te worden.
              </sch:assert>
        			<sch:report test="$ReferenceSystemInfo">Code van een horizontaal of verticaal referentiesysteem is aanwezig:  <sch:value-of select="$ReferenceSystemInfoCodeValue"/>
        			</sch:report>
        		</sch:rule>
	</sch:pattern>
	<!-- GDI-Vlaanderen SC3 -->
	<sch:pattern>
		<sch:title>GDI-Vlaanderen SC-3: organisationName (ISO-element 376) is aanwezig binnen elk voorkomen van CI_ResponsibleParty en is niet leeg.</sch:title>
		<sch:rule context="//*/gmd:CI_ResponsibleParty/gmd:organisationName">
			<sch:let name="organisationName" value=". and not(normalize-space(.)= '')"/>
			<sch:let name="organisationNameValue" value="./*/text()"/>
			<sch:assert test="$organisationName">Naam van de verantwoordelijke organisatie ontbreekt of is leeg.</sch:assert>
			<sch:report test="$organisationName">Naam van de verantwoordelijke organisatie is aanwezig : <sch:value-of select="$organisationNameValue"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- GDI-Vlaanderen SC4 -->
	<sch:pattern>
		<sch:title>GDI-Vlaanderen SC-4: Objectencatalogus is onderdeel van de dataset (= aangevinkt) (ISO-element 236). Objectencatalogus identifier mag daarom niet leeg zijn.</sch:title>
		<sch:rule context="//gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:includedWithDataset">
			<sch:let name="uuidrefValueArray" value="../gmd:featureCatalogueCitation/@uuidref"/>
			<sch:let name="uuidrefValue" value="normalize-space($uuidrefValueArray[1])"/>
			<sch:let name="uuidrefIsValid" value="not(normalize-space(gco:Boolean)='true') or $uuidrefValue!=''"/>
			<sch:assert test="$uuidrefIsValid">Het element 'Objectencatalogus identificator' ontbreekt of is leeg.</sch:assert>
			<sch:report test="$uuidrefIsValid">Het element 'Objectencatalogus identificator' is aanwezig : <sch:value-of select="$uuidrefValue"/>
			</sch:report>
		</sch:rule>
	</sch:pattern>
	<!-- GDI-Vlaanderen SC5 -->
	<sch:pattern>
		<sch:title>Er moet minstens één Nederlandstalig trefwoord aanwezig zijn uit de thesaurus ‘GEMET - INSPIRE thema’s, versie 1.0’ met als datum 2008-06-01 indien de MD_Metadata.language gelijk is aan NL (ISO-element 55)</sch:title>
		<sch:rule context="//gmd:MD_DataIdentification[/gmd:MD_Metadata/gmd:language/*/text()='dut']">
			<sch:let name="inspire-thesaurus" value="document(concat('file:///', $thesaurusDir, '/external/thesauri/theme/inspire-theme.rdf'))"/>
			<sch:let name="inspire-theme" value="$inspire-thesaurus//skos:Concept"/>
			<sch:assert test="count($inspire-theme) > 0">
				INSPIRE Thema thesaurus niet gevonden. 
			</sch:assert>
			<sch:let name="keyword" value="gmd:descriptiveKeywords/*/gmd:keyword/gco:CharacterString
					[../../gmd:thesaurusName/*/gmd:title/*/text()='GEMET - INSPIRE thema''s, versie 1.0' and
					../../gmd:thesaurusName/*/gmd:date/*/gmd:date/gco:Date/text()='2008-06-01' and
					../../gmd:thesaurusName/*/gmd:date/*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='publication']"/>
			<sch:let name="inspire-theme-selected" value="count($inspire-thesaurus//skos:Concept[skos:prefLabel[@xml:lang='nl'] = $keyword])"/>
			<sch:assert test="$inspire-theme-selected >0">
				Er werd geen Nederlandstalig sleutelwoord gevonden afkomstig uit de GEMET - INSPIRE thema''s, versie 1.0 thesaurus gedateerd op 2008-06-01.
			</sch:assert>
			<sch:report test="$inspire-theme-selected > 0">
				Er werd een Nederlandstalig sleutelwoord: <sch:value-of select="$keyword"/> gevonden dat afkomstig is uit de GEMET - INSPIRE thema''s, versie 1.0 thesaurus gedateerd op 2008-06-01.
			</sch:report>
		</sch:rule>
	</sch:pattern>
</sch:schema>
