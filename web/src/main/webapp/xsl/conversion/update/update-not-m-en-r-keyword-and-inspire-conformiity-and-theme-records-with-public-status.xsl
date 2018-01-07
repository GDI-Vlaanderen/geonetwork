<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:gml="http://www.opengis.net/gml" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gfc="http://www.isotc211.org/2005/gfc" exclude-result-prefixes="#all">
	<xsl:output method="xml"/>
	
	<xsl:template match="/root">
		<xsl:apply-templates select="gmd:MD_Metadata|gfc:FC_FeatureCatalogue"/>
	</xsl:template>
	<!-- ================================================================= -->
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="gmd:report[contains(upper-case(*/gmd:result/*/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString),'VERORDENING')]|gmd:descriptiveKeywords[contains(upper-case(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString),'INSPIRE')]" priority="10">
		<xsl:variable name="fileIdentifier" select="//gmd:fileIdentifier/gco:CharacterString|//gfc:FC_FeatureCatalogue/@uuid"/>
		<xsl:variable name="isRecordToBeUpdated">
			<xsl:call-template name="isRecordToBeUpdated">
				<xsl:with-param name="fileIdentifier" select="$fileIdentifier"/>
			</xsl:call-template>
		</xsl:variable>
<!-- 		<xsl:message select="concat($fileIdentifier,',',$isRecordToBeUpdated=true())"/> -->
		<xsl:if test="$isRecordToBeUpdated=false()">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="isRecordToBeUpdated">
		<xsl:param name="fileIdentifier"/>
		<xsl:choose>
			<xsl:when test="$fileIdentifier='fb0ae5de-3140-42a4-88c2-803fdad4b83d'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='e3fbe556-1a46-4416-a3cf-762302db8fa9'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='e3d37655-ae63-4844-aca0-e559a5d89d0f'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='e10605cf-791f-4326-87f0-7348f339744a'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a5e5ef44-293b-4564-966e-8e8b8af661ce'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0b066d32-a53a-4d52-8ac5-ea4cc4e1724c'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c8428659-e448-4921-9b6d-785ba4e42bc0'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='8e9b6bf0-4f12-4077-a099-48ec56d79671'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='96c68bdb-1bb3-44c1-8fb8-b001f4c19335'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='bcf2eb14-ef51-4355-a30b-685c016472fc'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='456b782a-aa82-4769-ac15-b3786cf36f42'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='976540bc-3097-45f9-85e7-2ad633e91905'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='757859bc-96df-4a59-b1ef-f734c5ee0d24'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='04facb2e-ecf6-4dba-95ef-a490e6086c79'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='29a6e61f-d65f-4a36-88a2-d3928683a377'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='458fb128-b281-4abc-b4ff-4528da3715ee'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9815d015-555e-4821-8def-8007e73a024f'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='cd2569f0-7895-4e38-b2bb-ca00cfd20425'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='8401e6df-4cc1-4edb-bf67-7dcc97cb41fe'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='12f3abcd-8334-441c-991d-3ebb10cd855f'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='aadf4e53-38da-4bd3-81f0-d11aa328bd26'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='8dba452e-8614-4ed7-9903-fc7e4e477641'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='295615a5-3104-47b3-b8d4-9bbeb23b53ea'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='f3ac8e06-2122-474a-a525-969b6e8cf43e'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1745f1a0-7a8a-447d-8530-5e9fe20b43a7'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='49310d1a-6845-4c87-97f7-ce2a505c9911'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9e826fb6-ec5d-452f-8a6e-de903078a844'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ccee8f15-3106-4083-bfb4-dbccbfa8c412'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='eacff45e-0381-4b04-a83a-7e508e341183'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='f4678de9-7fdf-4eae-a99f-a34ba5e92b16'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='b461a917-4df5-40c7-88eb-71a9cfa5c582'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='eb199598-e23d-4137-8211-ea73fa5ea853'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0bc029c0-4943-4710-a3bd-ad615b733ae7'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ced24486-8f53-44da-bb2f-d6d9c5997b9e'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0f62ffdd-2e86-4822-9cfc-4005c117f9cc'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='59c6d618-a69d-4ff6-9ebb-1e42198a2807'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='53ac637c-e1f4-44a6-b89a-b00f224fd2b0'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='dba9b779-d214-4076-b9cb-9a0bb040d7a0'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c74e45c9-f51e-4639-89d3-ba49009fda1c'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6a527ee2-360d-46a6-adc0-f41d02f5f0ce'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='672a21f3-af62-4797-afed-1246337f8f63'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='b72260d8-ee29-4d80-b7d9-91da2007e98c'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a21272d8-0364-4370-8420-cf119d9011d9'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='288be5c6-d70d-45d3-a31d-265c86cc9202'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='e0dd518e-f2fa-4f2c-91e3-155c5b2d153f'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='281537d4-d4a3-4724-80df-c85e6354ceb6'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='751f4d8b-d2ad-467e-bba9-2e84ea3cfb4d'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='91dd46c4-8b62-459e-aad4-46dbb66f0005'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='fe08744b-3aff-40ea-8e8b-95015ff1cd6e'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3f23808b-3137-46ba-a57e-b14820196fdc'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='E5274E60-D896-42D0-A8E7-5FF83D9AC7EC'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='FFC95D55-A300-4957-BA2B-5CC0B88D912E'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='49DCD335-1A9D-48A5-B383-2EA707A07FD1'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='BCB20388-3DEB-4436-AECD-F3B311EE2602'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='52187075-5c08-40d1-beda-a237e248ecdf'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='81b18f6d-975c-424a-bbca-653371693409'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c7be4fa8-c7f4-4e4b-a9de-47375a5520ad'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='8f54a85f-4a89-4a58-8bdf-73972a91c30f'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a5b317f2-1a4c-47df-9b14-bf0cb09de770'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='68621fdf-7948-48eb-b141-3f85751c44cb'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='a72a90d1-c937-4760-8b05-3e2c6efe667f'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5D89DD1E-5C44-11DC-8314-0800200C9A66'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='F14B3B46-5728-4E65-8DFA-0D45D3A7A233'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1AB712CA-3E85-4AC2-B100-29564652F750'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='153A9D29-7D6A-43F6-8F78-1C580B94A4AB'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1acb23e7-09b0-4d92-a0a1-61e4c9ece79b'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='F9DDA633-1F45-483B-8227-91A466646329'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='B2A31F69-24C8-4172-864C-96AB7EBA2D97'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='8933d7a3-5ed1-4a8e-9475-b1e790c7b730'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='8adab771-194e-450c-96b8-317cc6ee4010'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='f4b0d4e0-843c-4cfb-a99b-4cb4d0fd2404'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='03b7c3e3-a960-4724-a179-5fa85063421b'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='51d4cbab-82ba-4e5e-ba47-b45708c11981'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='4dd01e17-12d5-48ef-91dc-a7b115255b19'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='8C406C49-B1B1-45EE-8B55-EBBDB7F285D4'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='2A164246-9025-4426-8EB2-08273E710299'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3267516A-EE40-4B13-81D8-AA66BC30537A'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5d875d1d-d807-4295-b6f2-a3b5cf0bfe11'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6d387317-1272-4085-9849-b899ceacf450'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ba306468-e384-43b4-83eb-d5abd6a83ab7'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='FBC603AE-87DC-4418-B16D-832CE7B30335'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='f835f02d-49e8-480d-ae50-e65454f7ca3a'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='63D62DD2-E800-4406-BF59-74DF33D109E1'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9531f406-ca7c-4987-9e8b-37de471a57b3'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7880ec1a-c3c7-4f4d-b328-230107a1ca3c'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3e88eec1-d697-4672-b4c1-53c9f744b49b'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='E25F6001-1439-4633-9B1D-1CC913D0741F'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1406bf74-3057-4a70-ab26-95d293b59c8f'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ac6a5552-cdf9-4fc3-bc94-41e0c9fd5f57'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ff253d5a-cbc7-4aed-9cda-f2e1f81cec27'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3b6a8160-0e70-43f5-b550-5ed08fde5c0c'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='BE075D52-EE47-47E7-BA04-79E080AE7A68'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0c2f9e96-404a-4e56-b369-ee60183e6f47'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='53723fbf-e785-4fcc-8ae1-5bd9e9178e79'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='f214b842-7ed3-4030-8cef-b366faea36b5'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='47ccb667-22ce-4814-8726-f628c847edd6'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='24b0f71b-8522-4b11-b255-648d37b3e517'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='28ad9b44-6f03-4317-a6e0-765a0aefd282'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='94ad463c-c96d-44f7-bf3e-89b8942895be'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9bf3c6bc-9093-45c3-b7f5-cbfadc78a7bd'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c07719ff-bbf9-4a6d-9a8c-cc3ca08736c1'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7511d678-1a1b-465c-b880-6414b26689cb'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='e2a4923f-3547-4e0a-8016-38c489f106f3'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c4d39e9f-9e0f-441f-80fa-f27def4ed361'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='68e01569-5d34-42c5-9212-350b45283fa2'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='dbf9ede8-97ce-4dd9-93e6-8a5baeba1fa7'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ded85fcf-bf6e-497c-8a89-4896762e04ad'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0038bab3-d375-4000-9ee5-8f973385e462'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='dbbeddd4-0452-4413-9f2a-fa47a4f98e55'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='2d7382ea-d25c-4fe5-9196-b7ebf2dbe352'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='93795cd6-66d3-4310-83b2-5443adfee403'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='8264f16f-45d2-4eae-bc77-f003c7830b20'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='b2027867-cd3e-4e67-b6f1-aec3ff878f44'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5399E688-370B-4727-ABB8-67A1E5B90262'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9B2F2E5D-C905-4BE7-BC9D-C7D08004F5C0'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='242ddabc-3cbc-44f0-9623-bee874b29549'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7e40413e-9c17-492b-ac24-e72d37251e5a'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='22e8caab-cefb-4f7d-a712-3e1cc5a5a7c6'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5683476e-a497-4193-abc5-13c6d1622f20'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3424f4b1-4f2b-457b-943a-d71cc28c4af4'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='9b0f82c7-57c4-463a-8918-432e41a66355'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0da2e5e4-6886-426b-bb82-c0ffe6faeff6'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='f52b1a13-86bc-4b64-8256-88cc0d1a8735'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='B3128BE5-09A0-40C6-9575-C1DE8FF21362'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ab73c4e2-fc4c-4201-b3ce-47ff75e3c436'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='C944D3CD-1946-424C-8A64-FF0AFB994930'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='3631652A-C017-43AD-99B8-F20E7FA118CD'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='01C424BD-3225-4324-8E66-65AA878349F3'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='11673FAA-B8D4-40C4-8C61-EB838AB7BAFA'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0D6F1682-7772-4E22-ABA4-65491F9F9C74'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='87D9CCA9-D1D5-406D-BABD-EA7535D0B6A2'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='4ab6531a-8687-47c6-be3e-ed1bacfe57e6'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='FF9F6F4F-5AA0-44DE-9107-F02EA97CB8D3'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='87029616-A885-4091-8800-54DF893104A8'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6E231EC9-496F-42DB-A3D0-5A637D83D4B8'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='FE97C898-7DE7-4DBB-AC9F-6C1EBDEB7450'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='58F5DD1A-A2CA-4CA1-AD9A-4041F8CF45B7'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c99fa07e-e4c9-4a25-80c2-b994accf91ed'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='e35fbea9-cc41-4044-968c-e8bb097c6b02'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='564cd799-6707-4dba-81c3-5525b7bf861c'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c3c03598-f4e6-4ae2-b92e-298d47d7dc8a'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='74941E03-747F-4922-BB9D-B517B5D7F697'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='cb017421-92d8-4491-929e-1e7f73dd72ae'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='69081c7d-c26b-44d1-b26a-78f2c7e9c2b6'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5A19481A-B69C-4590-A6B1-05EFB39A4A1D'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='DA9C6CFF-6DF3-412A-B4C1-247C188BC638'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='522129BA-9D0D-4D41-AD1E-45DE8D493B12'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='DCF4C103-8886-45CC-8964-B36A35BF0952'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c4a66c9b-a29f-45e8-805d-48ab18877ceb'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='f47ab374-8f6f-4fc3-b714-95305f1fe75c'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0ffedb74-aa2d-4f56-a91d-3c211540263e'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7fa554f2-2580-466e-b50f-d992c2a62e1d'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='358dad8a-7e65-4dd9-9726-318fc2ef1ed7'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='42ac31a7-afe6-44c4-a534-243814fe5b58'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='E13FC852-8DF3-4CBD-B778-F8968AF25636'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='4B325EA1-EAE7-4FAA-931A-A542BE04F6D4'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5cceb59a-b057-4558-8a51-64be6b1aff2a'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6323c1a9-58a1-4ccd-9d44-cbab0eb4ca52'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5a8e61e2-8208-43e7-89a2-c088d984f7a4'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d42c23a4-297e-4046-a344-04eeccf10f3d'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='f0a5ea12-d132-4af3-a24e-34195143c041'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='698e64a4-11d7-4474-bec4-ecf8c89008de'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='cf4ea507-930b-4fdd-a794-8aef47ef0952'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='928a7f14-fdef-4ed9-ad94-2dce0b20fbc5'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6e1686a2-4c8c-4a30-93da-0bff7cae21b6'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='eeca1d86-4d73-40f3-9f82-4671904eae04'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='dd47297a-0916-4ff6-81b1-fc1adebde60c'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='ebde3fca-c97e-4248-9341-e9122896cdfd'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='43f70b7b-c189-4db0-b36d-15caf739a9ab'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='eed108fd-05d3-472d-ad64-b9e65e17055f'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='c2389def-2c5d-4b35-a27c-3cea755b8b17'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='d48f5a30-be85-4eb3-bcc5-e1266f348a1a'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='8E7FE417-1E2F-49C0-BC4D-CD46C6C86948'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='C4F51B28-51BF-4189-8E98-72B94AE8DA13'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='52ED7CDD-DF78-46AE-912A-E8234E1CFFD1'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='98A49F6C-7FB6-406B-B60F-574079741D41'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='14772D1C-6819-11DC-8314-0800200C9A66'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='478f45af-3ac0-4130-9e5d-78db8202c1f6'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='B4F95D00-67E7-488A-9B51-8A6EC8204A4A'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='564CCF18-0D64-4078-999E-7CDDF27F9069'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='2882dd9f-e00c-4a1d-a1d2-386eaf3a84fd'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='E965C068-A1BE-43C3-AD0B-34BC44FE1D2C'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='227EA1CE-7B98-483D-A795-1786F0220622'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='46ACCD7D-A5CB-43B3-8DAE-D4E7BD1C8127'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='DE95B551-F0AC-4599-83F4-899F4BA1CC05'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='CFD4B7F7-FB8B-431A-B194-418535969EAD'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='B2A7F9BD-6082-4226-97FD-96C3A7F85259'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7545ABE2-0E77-4E43-AA76-674EE59B24A9'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='50C3BF1A-FA7F-4E5A-8C6B-A968256FF8B7'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='2A35F4EB-B080-4D7C-AA39-0E001F7AC982'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='08482C99-3682-4A09-A823-C45247E7FF4C'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7867D384-17E1-434E-A46A-2ACD3750671C'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='A39C6F92-9B89-4472-8C14-3AC5A2DDA0B7'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='F4BF64B8-A6BF-447A-BA81-084A1DE5FBDF'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='F220F83B-4E5A-48D6-BE3C-9914692FC09C'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='4CFDD544-CE2F-4669-98FA-BA668BD428DD'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='10DB5A7A-F101-48BB-9D8F-C12353AA7464'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='8C5A3657-81AB-44BB-B059-E6DF953AC8D4'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='F553AF58-FB44-408C-86C9-37BCBC745300'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7D619539-57C1-44B9-8662-EA5DE1AB6647'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6E3E3050-C47C-4E39-9564-9B866081038D'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='538C1EFA-C754-4CBC-AC2D-D81E6D929807'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='4A23F2E7-AADD-4321-82D9-50FCD35FA856'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='5BE63750-0F1C-46E2-B60F-479A2B6CBCC7'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='6B0F7A1F-29D3-4CF3-B76A-110961DEB4D4'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='7DDCD4B1-2C26-43EA-B4B6-97F572CA5511'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0E4B3FB8-418C-4AEF-913A-763401A2CE01'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='825F7A2B-261A-455B-82D8-4017F4AD883C'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='E124AC89-75D6-4B9A-876E-2AB2162AF576'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='1DF92840-60C3-4504-B548-9B7489BA4C52'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='33CFF1D7-0628-404E-989B-BF1CF5D36013'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='49ADAF96-7082-4480-8FAD-209106FF7F19'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='BC2F4945-62CC-4469-BE09-611F7DEC7AAD'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='2F15EF0B-58B4-4C15-B04A-391CDAE93DD3'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="$fileIdentifier='0894E08F-A78F-4360-BB00-BEE3DCE1E94E'"><xsl:value-of select="true()"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
