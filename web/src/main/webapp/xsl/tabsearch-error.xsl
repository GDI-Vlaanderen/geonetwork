<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="main.xsl"/>
	
	<!--
	html page
	-->
	<xsl:template match="/">
		<html>
			<head>
				<title><xsl:value-of select="/root/gui/strings/title"/></title>
				<link rel="stylesheet" type="text/css" href="{/root/gui/url}/geonetwork.css"/>
			</head>
			<body>
				<table width="100%" height="100%">
					<tr class="banner">
						<td>
							<img src="{/root/gui/url}/apps/tabsearch/images/logo.gif" align="top" />
						</td>
					</tr>
        			<tr height="100%">
						<td class="content">
							<xsl:call-template name="content"/>
						</td>
        			</tr>
        		</table>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
