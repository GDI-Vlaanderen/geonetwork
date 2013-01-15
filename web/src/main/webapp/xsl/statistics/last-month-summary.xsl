<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml"/>

    <xsl:template match="/">
                <table border="1">
					<tr><td align="left"> <xsl:value-of select="/root/gui/strings/stat.totalSearches"/>&#160;</td>
						<td>&#160;<b><xsl:value-of select="root/gui/lastMonthSummary/record/totalcount"/></b></td></tr>
					<tr><td align="left"> <xsl:value-of select="/root/gui/strings/stat.numSearchesPerDay"/>&#160;</td>
						<td>&#160;<b><xsl:value-of select="root/gui/lastMonthSummary/meanSearchLastMonth"/></b></td></tr>
					<tr><td align="left"> <xsl:value-of select="/root/gui/strings/stat.numSearchesNoResult"/>&#160;</td>
						<td>&#160;<b><xsl:value-of select="root/gui/lastMonthSummary/record/nohit"/></b></td></tr>
					<tr><td align="left"> <xsl:value-of select="/root/gui/strings/stat.simpleAdvancedSearch"/>&#160;</td>
						<td>&#160;<b><xsl:value-of select="root/gui/lastMonthSummary/simple"/></b> / <b><xsl:value-of select="root/gui/lastMonthSummary/advanced"/></b></td></tr>
					<tr><td align="left"> <xsl:value-of select="/root/gui/strings/stat.mdType"/>&#160;</td>
						<td>
							<table>
								<xsl:for-each select="root/gui/lastMonthSummary/mdType/response/record">
								<tr><td>&#160;
									<xsl:choose>
										<xsl:when test="type = 'all'"><xsl:value-of select="/root/gui/strings/stat.allTypes"/></xsl:when>
										<xsl:when test="type = 'basicgeodata'"><xsl:value-of select="/root/gui/strings/stat.basicGeodataType"/></xsl:when>
										<xsl:when test="type = 'service'"><xsl:value-of select="/root/gui/strings/stat.serviceMdType"/></xsl:when>
										<xsl:when test="type = 'dataset'"><xsl:value-of select="/root/gui/strings/stat.dsMsType"/></xsl:when>
									</xsl:choose>
									<xsl select="$mdTypeString"/>: <b><xsl:value-of select="typecount"/></b>
								</td></tr>
								</xsl:for-each>
							</table>
						</td></tr>
                </table>
								&#160;
                <table>
					<tr><td align="right"> <xsl:value-of select="/root/gui/strings/stat.numAutoGeneratedSearches"/>&#160;:</td>
						<td>&#160;<b><xsl:value-of select="root/gui/lastMonthSummary/autogenerated"/></b></td></tr>
                </table>
    </xsl:template>
</xsl:stylesheet>
