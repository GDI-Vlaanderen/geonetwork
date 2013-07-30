<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco">

    <xsl:template match="/root">
        <xsl:apply-templates select="gmd:MD_Metadata"/>
    </xsl:template>

    <!-- match descriptiveKeywords elements -->
    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords">
        <xsl:choose>
            <!-- this descriptiveKeywords uses 'GDI-Vlaanderen Best Practices - thesaurus'  -->
            <xsl:when test="gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'GDI-Vlaanderen Best Practices - thesaurus'">
                <gmd:descriptiveKeywords>
                    <gmd:MD_Keywords>
                        <!-- put out each keyword -->
                        <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
                            <xsl:copy-of select="."></xsl:copy-of>
                        </xsl:for-each>
                        <!-- if the AGIV keyword marker isn't already here, put it out -->
                        <xsl:if test="count(gmd:MD_Keywords/gmd:keyword[gco:CharacterString = 'Metadata GDI-Vl-conform']) = 0">
                            <gmd:keyword>
                                <gco:CharacterString>Metadata GDI-Vl-conform</gco:CharacterString>
                            </gmd:keyword>
                        </xsl:if>
                        <!-- do not forget to put out sibling element thesaurusName -->
                        <xsl:for-each select="gmd:MD_Keywords/gmd:thesaurusName">
                            <xsl:copy-of select="."></xsl:copy-of>
                        </xsl:for-each>
                    </gmd:MD_Keywords>
                </gmd:descriptiveKeywords>
            </xsl:when>
            <!-- this descriptiveKeywords does not use 'GDI-Vlaanderen Best Practices - thesaurus' : just put out  -->
            <xsl:otherwise>
                <xsl:copy-of select="."></xsl:copy-of>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- in case gmd:MD_DataIdentification does not have a gmd:descriptiveKeywords using  'GDI-Vlaanderen Best Practices - thesaurus' , insert it at correct position -->
    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification[count(gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title[normalize-space(gco:CharacterString) = 'GDI-Vlaanderen Best Practices - thesaurus']) = 0]">
        <!-- all elements allowed to follow descriptiveKeywords in MD_DataIdentification -->
        <xsl:variable name="elements-after" select="gmd:resourceSpecificUsage|gmd:resourceConstraints|gmd:aggregationInfo|gmd:spatialRepresentationType|gmd:spatialResolution|gmd:language|gmd:characterSet|gmd:topicCategory|gmd:environmentDescription|gmd:extent|gmd:supplementalInformation"/>
        <xsl:copy>
            <xsl:copy-of select="* except $elements-after"/>
            <gmd:descriptiveKeywords>
                <gmd:MD_Keywords>
                    <gmd:keyword>
                        <gco:CharacterString>Metadata GDI-Vl-conform</gco:CharacterString>
                    </gmd:keyword>
                    <gmd:thesaurusName>
                        <gmd:CI_Citation>
                            <gmd:title>
                                <gco:CharacterString>GDI-Vlaanderen Best Practices - thesaurus</gco:CharacterString>
                            </gmd:title>
                            <gmd:date>
                                <gmd:CI_Date>
                                    <gmd:date>
                                        <gco:Date>2013-06-16</gco:Date>
                                    </gmd:date>
                                    <gmd:dateType>
										<gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</gmd:CI_DateTypeCode>
                                    </gmd:dateType>
                                </gmd:CI_Date>
                            </gmd:date>
                        </gmd:CI_Citation>
                    </gmd:thesaurusName>
                </gmd:MD_Keywords>
            </gmd:descriptiveKeywords>
            <xsl:copy-of select="$elements-after"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>