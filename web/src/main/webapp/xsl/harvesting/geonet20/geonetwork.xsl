<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<!-- ============================================================================================= -->
	<!-- === editPanel -->
	<!-- ============================================================================================= -->

	<xsl:template name="editPanel-GN20">
		<div id="gn20.editPanel">
			<xsl:call-template name="site-GN20"/>
			<xsl:call-template name="search-GN20"/>
			<xsl:call-template name="options-GN20"/>
			<xsl:call-template name="content-GN20"/>
			<p/>
			<span style="color:red"><xsl:value-of select="/root/gui/harvesting/gn20Unsafe"/></span>
		</div>
	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template name="site-GN20">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/site"/></h1>

		<table>
			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/name"/></td>
				<td class="padded"><input id="gn20.name" class="content" type="text" value="" size="30"/></td>
			</tr>

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/url"/></td>
				<td class="padded"><input id="gn20.host" class="content" type="text" value="" size="30"/></td>
			</tr>

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/useAccount"/></td>
				<td class="padded"><input id="gn20.useAccount" type="checkbox" checked="on"/></td>
			</tr>

			<tr>
				<td/>
				<td>
					<table id="gn20.account">
						<tr>
							<td class="padded"><xsl:value-of select="/root/gui/harvesting/username"/></td>
							<td class="padded"><input id="gn20.username" class="content" type="text" value="" size="20"/></td>
						</tr>
		
						<tr>
							<td class="padded"><xsl:value-of select="/root/gui/harvesting/password"/></td>
							<td class="padded"><input id="gn20.password" class="content" type="password" value="" size="20"/></td>
						</tr>
					</table>
				</td>
			</tr>			
		</table>
	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template name="search-GN20">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/search"/></h1>

		<table>
			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/siteId"/></td>
				<td class="padded"><input id="gn20.siteId" class="content" type="text" size="20"/></td>
				<td class="padded">
					<button class="content" onclick="harvesting.geonet20.addSearchRow()">
						<xsl:value-of select="/root/gui/harvesting/add"/>
					</button>
				</td>					
			</tr>
		</table>
		
		<div id="gn20.searches"/>

	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template name="options-GN20">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/options"/></h1>
		<xsl:call-template name="schedule-widget">
			<xsl:with-param name="type">gn20</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template name="content-GN20">
	<div>
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/content"/></h1>

		<table border="0">
             <!-- UNUSED -->
			<tr style="display:none;">
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/importxslt"/></td>
				<td class="padded">
					&#160;
					<select id="gn20.importxslt" class="content" name="importxslt" size="1"/>
				</td>
			</tr>

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/validate"/></td>
				<td class="padded"><input id="gn20.validate" type="checkbox" value=""/></td>
			</tr>

            <!-- schematrons to use in validation -->
            <tr>
                <td class="padded"><xsl:value-of select="/root/gui/harvesting/schematrons"/></td>
                <td>
                    <table class="text-aligned-left" id="gn20.schematrons">
                        <xsl:for-each select="/root/gui/schematrons/schemas/schema">


                            <tr>
                                <th class="padded" colspan="2">
                                    <xsl:value-of select="schemaname"/>
                                    <xsl:if test="count(schematronname[. != 'schematron-rules-none.xsl']) = 0">
                                        <xsl:value-of select="/root/gui/harvesting/noschematrons"/>
                                    </xsl:if>
                                </th>
                            </tr>
                            <xsl:for-each select="schematronname">
                                <xsl:if test=". != 'schematron-rules-none.xsl'">
                                    <tr>
                                        <td class="padded">
                                            <xsl:text>&#160;&#160;</xsl:text>
                                        </td>
                                        <td>
                                            <input class="schematron" type="checkbox" name="gn20.{../schemaname}.{.}" id="gn20.{../schemaname}.{.}"/>
                                            <xsl:value-of select="."/>
                                        </td>
                                    </tr>
                                </xsl:if>
                            </xsl:for-each>

                        </xsl:for-each>
                    </table>
                </td>
            </tr>
		</table>
	</div>
	</xsl:template>

	<!-- ============================================================================================= -->

    <xsl:template mode="selectoptions" match="day|hour|minute|dsopt">
		<option>
			<xsl:attribute name="value">
				<xsl:value-of select="."/>
			</xsl:attribute>
			<xsl:value-of select="@label"/>
		</option>
	</xsl:template>

    <!-- ============================================================================================= -->

</xsl:stylesheet>
