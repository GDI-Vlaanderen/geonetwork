<?xml version="1.0" encoding="UTF-8"?>
<!--
 this stylesheet removes keywords marking INSPIRE conformance.

 If the descriptiveKeywords element does not contain such a keyword, it is just put out.
 If it does, it is put out retaining all its other keywords (but not the ISNPIRE conformance marker keyword).
 If the INSPIRE conformance marker is the only keyword in this descriptiveKeywords element, it is entirely removed.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
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
                <xsl:choose>
                    <!-- contains a keyword matching  'Conform GDI-Vlaanderen Best Practices - thesaurus' -->
                    <xsl:when test="gmd:MD_Keywords//gmd:keyword/gco:CharacterString = 'Metadata GDI-Vl-conform'">
                        <!-- if there are other keywords, put them out -->
                        <xsl:if test="count(gmd:MD_Keywords/gmd:keyword) > 1">
                            <gmd:descriptiveKeywords>
                                <gmd:MD_Keywords>
                                    <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
                                        <xsl:choose>
                                            <!-- do not put out -->
                                            <xsl:when test="gco:CharacterString = 'Metadata GDI-Vl-conform'"/>
                                            <xsl:otherwise>
                                                <gmd:keyword>
                                                    <xsl:apply-templates select="@*|node()"/>
                                                </gmd:keyword>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                    <!-- do not forget to put out sibling element thesaurusName -->
                                    <xsl:for-each select="gmd:MD_Keywords/gmd:thesaurusName">
                                        <xsl:copy-of select="."></xsl:copy-of>
                                    </xsl:for-each>
                                </gmd:MD_Keywords>
                            </gmd:descriptiveKeywords>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- does not contain a keyword matching  'Conform GDI-Vlaanderen Best Practices - thesaurus' : just put out-->
                        <gmd:descriptiveKeywords>
                            <xsl:apply-templates select="@*|node()"/>
                        </gmd:descriptiveKeywords>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- descriptiveKeywords not using 'GDI-Vlaanderen Best Practices - thesaurus' thesaurus : just put out -->
            <xsl:otherwise>
                <gmd:descriptiveKeywords>
                    <xsl:apply-templates select="@*|node()"/>
                </gmd:descriptiveKeywords>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    </xsl:template>

</xsl:stylesheet>