<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<!-- ============================================================================================= -->
	<!-- === editPanel -->
	<!-- ============================================================================================= -->

	<xsl:template name="editPanel-OAI">
		<div id="harvesterBusy" style="position:absolute;
		                               left:45%;top:45%;display:none;">
			<img src="{/root/gui/url}/images/spinner.gif" alt="busy"/>
		</div>
		<div id="oai.editPanel">
			<xsl:call-template name="site-OAI"/>
			<div class="dots"/>
			<xsl:call-template name="search-OAI"/>
			<div class="dots"/>
			<xsl:call-template name="options-OAI"/>
			<div class="dots"/>
			<xsl:call-template name="content-OAI"/>
			<div class="dots"/>
			<xsl:call-template name="privileges-OAI"/>
			<div class="dots"/>
			<xsl:call-template name="categories-OAI"/>
		</div>
	</xsl:template>

	<!-- ============================================================================================= -->

	<xsl:template name="site-OAI">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/site"/></h1>
	
		<table border="0">
			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/name"/></td>
				<td class="padded"><input id="oai.name" class="content" type="text" value="" size="30"/></td>
			</tr>

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/url"/></td>
				<td class="padded"><input id="oai.url" class="content" type="text" value="" size="30"/></td>
			</tr>

			<tr>
				<td class="padded" valign="bottom"><xsl:value-of select="/root/gui/harvesting/icon"/></td>
				<td class="padded">
					<select id="oai.icon" class="content" name="icon" size="1"/>
					&#xA0;
					<img id="oai.icon.image" src="" alt="" />
				</td>
			</tr>
			
			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/useAccount"/></td>
				<td class="padded"><input id="oai.useAccount" type="checkbox" checked="on"/></td>
			</tr>

			<tr>
				<td/>
				<td>
					<table id="oai.account">
						<tr>
							<td class="padded"><xsl:value-of select="/root/gui/harvesting/username"/></td>
							<td class="padded"><input id="oai.username" class="content" type="text" value="" size="20"/></td>
						</tr>
		
						<tr>
							<td class="padded"><xsl:value-of select="/root/gui/harvesting/password"/></td>
							<td class="padded"><input id="oai.password" class="content" type="password" value="" size="20"/></td>
						</tr>
					</table>
				</td>
			</tr>			
		</table>
	</xsl:template>
	
	<!-- ============================================================================================= -->
	
	<xsl:template name="search-OAI">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/search"/></h1>

		<div id="oai.searches"/>
		
		<div>
			<button id="oai.addSearch" class="content" onclick="harvesting.oaipmh.addSearchRow()">
				<xsl:value-of select="/root/gui/harvesting/add"/>
			</button>
			&#xA0;
			<button id="oai.retrInfo" class="content" onclick="harvesting.oaipmh.retrieveInfo()">
				<xsl:value-of select="/root/gui/harvesting/retrieveSetsPrefixes"/>
			</button>
		</div>
	</xsl:template>

	<!-- ============================================================================================= -->
	
	<xsl:template name="options-OAI">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/options"/></h1>
		<xsl:call-template name="schedule-widget">
			<xsl:with-param name="type">oai</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ============================================================================================= -->

	<xsl:template name="content-OAI">
	<div style="display:none;"> <!-- UNUSED -->
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/content"/></h1>

		<table border="0">
			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/importxslt"/></td>
				<td class="padded">
					&#160;
					<select id="oai.importxslt" class="content" name="importxslt" size="1"/>
				</td>
			</tr>

			<tr>
				<td class="padded"><xsl:value-of select="/root/gui/harvesting/validate"/></td>
				<td class="padded"><input id="oai.validate" type="checkbox" value=""/></td>
			</tr>

            <!-- schematrons to use in validation -->
            <tr>
                <td class="padded"><xsl:value-of select="/root/gui/harvesting/schematrons"/></td>
                <td>
                    <table class="text-aligned-left" id="oai.schematrons">
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
                                            <input class="schematron" type="checkbox" name="oai.{../schemaname}.{.}" id="oai.{../schemaname}.{.}"/>
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

	<xsl:template name="privileges-OAI">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/privileges"/></h1>
		
		<table>
			<tr>
				<td class="padded" valign="top"><xsl:value-of select="/root/gui/harvesting/groups"/></td>
				<td class="padded"><select id="oai.groups" class="content" size="8" multiple="on"/></td>					
				<td class="padded" valign="top">
					<div align="center">
						<button id="oai.addGroups" class="content" onclick="harvesting.oaipmh.addGroupRow()">
							<xsl:value-of select="/root/gui/harvesting/add"/>
						</button>
					</div>
				</td>					
			</tr>
		</table>
		
		<table id="oai.privileges">
			<tr>
				<th class="padded"><b><xsl:value-of select="/root/gui/harvesting/group"/></b></th>
				<th class="padded"><b><xsl:value-of select="/root/gui/harvesting/oper/op[@id='0']"/></b></th>
				<th class="padded"><b><xsl:value-of select="/root/gui/harvesting/oper/op[@id='5']"/></b></th>
				<th class="padded"><b><xsl:value-of select="/root/gui/harvesting/oper/op[@id='6']"/></b></th>
				<th/>
			</tr>
		</table>
		
	</xsl:template>
	
	<!-- ============================================================================================= -->

	<xsl:template name="categories-OAI">
		<h1 align="left"><xsl:value-of select="/root/gui/harvesting/categories"/></h1>
		
		<select id="oai.categories" class="content" size="8" multiple="on"/>
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
