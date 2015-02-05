<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:java="java:org.fao.geonet.util.XslUtil">

	<xsl:include href="main.xsl"/>
    
	<!-- ================================================================================ -->
	<!-- page content	-->
	<!-- ================================================================================ -->

	<xsl:template mode="script" match="/">
		<script type="text/javascript" language="JavaScript">
			function init() {
				onXslChanged();
				onFilterChanged();
			}
			function updateFields(combo) {
				var value = combo.options[combo.selectedIndex].value; 
				switch(value) {
					case "1":
					case "2":
						if (value=="1") {
							document.getElementById("xpathExpression").value = "gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:pass/*[local-name(.)='Boolean']";
						}
						document.getElementById("childTextValue").value = "true";
						document.getElementById("tooltip").innerHTML = "";
						break;
					default:
						document.getElementById("xpathExpression").value = "";
						document.getElementById("childTextValue").value = "";
						document.getElementById("tooltip").innerHTML = "";
						break;
				}
			}
			function onXslChanged() {
				var value = getRadioButtonValue(document.getElementsByName("xslChoice"));
				if (value=="1") {
					document.getElementById("xpathExpressionHelper").disabled = false;
					document.getElementById("xpathExpression").disabled = false;
					document.getElementById("childTextValue").disabled = false;
				} 
				if (value=="2") {
					document.getElementById("styleSheet").disabled = false;
				} 
				if (value!="1") {
					document.getElementById("xpathExpressionHelper").selectedIndex = -1;
					document.getElementById("xpathExpression").value = "";
					document.getElementById("childTextValue").value = "";
					document.getElementById("xpathExpressionHelper").disabled = true;
					document.getElementById("xpathExpression").disabled = true;
					document.getElementById("childTextValue").disabled = true;
				}
				if (value!="2") {
					document.getElementById("styleSheet").selectedIndex = -1;
					document.getElementById("styleSheet").disabled = true;
				}
			}
			function onFilterChanged() {
				var value = getRadioButtonValue(document.getElementsByName("filterChoice"));
				if (value=="1") {
					document.getElementById("uuids").disabled = false;
				} 
				if (value=="2") {
					document.getElementById("groups").disabled = false;
				} 
				if (value!="1") {
					document.getElementById("uuids").value = "";
					document.getElementById("uuids").disabled = true; 
				}
				if (value!="2") {
					document.getElementById("groups").value = "";
					document.getElementById("groups").disabled = true; 
				}
			}
			function submitForm() {
				var filterChoiceValue = getRadioButtonValue(document.getElementsByName("filterChoice"));
				var xslChoiceValue = getRadioButtonValue(document.getElementsByName("xslChoice"));
				var uuids = document.getElementById("uuids").value;
				var groups = document.getElementById("groups").value;
				var xpathExpression = document.getElementById("xpathExpression").value;
				var childTextValue = document.getElementById("childTextValue").value;
				var styleSheetSelectedIndex = document.getElementById("styleSheet").selectedIndex;
				var executeTypeSelectedIndex = document.getElementById("executeType").selectedIndex;
				var message = "";
				var bProceed = true;
				switch(filterChoiceValue) {
					case "1":
						if (uuids==null || uuids.trim()=="") {
							message = "<xsl:value-of select="/root/gui/strings/uuids"/>";
						}
						break;
					case "2":
						if (groups==null || groups.trim()=="") {
							message = "<xsl:value-of select="/root/gui/strings/usergroups"/>";
						}
						break;
					default:
						break;
				}
				switch(xslChoiceValue) {
					case "1":
						if (xpathExpression==null || xpathExpression.trim()=="") {
							message += (message.length > 0 ? "\n" : "") + "<xsl:value-of select="/root/gui/strings/xpathExpression"/>";
						}
						if (childTextValue==null || childTextValue.trim()=="") {
							message += (message.length > 0 ? "\n" : "") + "<xsl:value-of select="/root/gui/strings/updateValue"/>";
						}
						break;
					case "2":
						if (styleSheetSelectedIndex==-1) {
							message += (message.length > 0 ? "\n" : "") + "<xsl:value-of select="/root/gui/strings/styleSheet"/>";
						}
						break;
					default:
						break;
				}
				if (message.length > 0) {
					alert("<xsl:value-of select="/root/gui/strings/isMandatory"/>" + "\n\n" + message);
					bProceed = false;
				}
				if (filterChoiceValue==3 &amp;&amp; bProceed &amp;&amp; executeTypeSelectedIndex==1) {
					var r = confirm("<xsl:value-of select="/root/gui/strings/updateAllMetadata"/>");
					if (r == false) {
					    bProceed = false;
					}
				}
				if (bProceed) {
 					return goSubmit("xmlUpdate");
 				} else {
 					return false;
 				}
			}
			
			function getRadioButtonValue(radioButton)
			{
				var i = 0;
				value = "";
				if (radioButton.length!=null)
				{
					for (i=0;i &lt; radioButton.length;i++)
					{
						if (radioButton[i].checked)
						{
							value = radioButton[i].value;
							break;
						}
					}
				}
				else
				{
					if (radioButton.checked)
						value = radioButton.value;
				}
				return value;
			}

			
		</script>
	</xsl:template>

	<xsl:template name="content">
		<xsl:call-template name="formLayout">
			<xsl:with-param name="title" select="/root/gui/strings/xmlUpdate"/>
			<xsl:with-param name="content">
				<form name="xmlUpdate" accept-charset="UTF-8" method="post" action="{/root/gui/locService}/metadata.xmlchildelementtextupdate"
				      enctype="application/x-www-form-urlencoded" encoding="application/x-www-form-urlencoded" target="_self">
					<input type="submit" style="display: none;" />
			        <xsl:variable name="lang" select="/root/gui/language"/>
					<table id="gn.UpdateTable" class="text-aligned-left">
				        <!-- stylesheet -->
				        <tr id="gn.xslChoice">
				            <td class="padded" colspan="2">
				            	<xsl:for-each select="/root/gui/strings/xslChoice">
					                <input class="content" type="radio" name="xslChoice" onchange="onXslChanged()">
						                <xsl:attribute name="value"><xsl:value-of select="./@value" /></xsl:attribute>
										<xsl:if test="./@value='1'">
											<xsl:attribute name="checked"/>
										</xsl:if>
						                <xsl:value-of select="." />
					                </input>
				            	</xsl:for-each>
				            </td>
				        </tr>
				        <tr id="gn.xpathExpressionHelper">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/xpathExpressionHelper"/>
				            </th>
				            <td class="padded">
				                <select class="content" id="xpathExpressionHelper" name="xpathExpressionHelper" onchange="updateFields(this);">
				                	<option value="0"></option>
				                	<option value="1">INSPIRE conformity statement</option>
			                	</select>
				            </td>
				        </tr>
				        <tr id="gn.xpathExpression">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/xpathExpression"/> (*)
				            </th>
				            <td class="padded">
				                <input class="content" type="text" style="width:400px" id="xpathExpression" name="xpathExpression" />
				            </td>
				        </tr>
				        <tr id="gn.childTextValue">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/updateValue"/> (*)
				            </th>
				            <td class="padded">
				                <input class="content" type="text" id="childTextValue" name="childTextValue" />
				                <span id="tooltip"></span>
				            </td>
				        </tr>
				        <tr id="gn.stylesheet">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/styleSheet"/>
				            </th>
				            <td class="padded">
				                <select class="content" id="styleSheet" name="styleSheet" size="1">
				                    <xsl:for-each select="/root/gui/updateStyleSheets/record">
				                        <xsl:sort select="name"/>
				                        <option value="{id}">
				                            <xsl:value-of select="name"/>
				                        </option>
				                    </xsl:for-each>
				                </select>
				            </td>
				        </tr>
				        <tr id="gn.filterChoice">
				            <td class="padded" colspan="2">
				            	<xsl:for-each select="/root/gui/strings/filterChoice">
					                <input class="content" type="radio" name="filterChoice" onchange="onFilterChanged()">
						                <xsl:attribute name="value"><xsl:value-of select="./@value" /></xsl:attribute>
										<xsl:if test="./@value='1'">
											<xsl:attribute name="checked"/>
										</xsl:if>
						                <xsl:value-of select="." />
					                </input>
				            	</xsl:for-each>
				            </td>
				        </tr>
				        <tr id="gn.uuids">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/uuids"/>
				            </th>
				            <td class="padded">
								<textarea class="content" id="uuids" name="uuids" cols="60" rows="6" wrap="soft"></textarea>
				            </td>
				        </tr>
				        <tr id="gn.groups">
							<th class="padded"><xsl:value-of select="/root/gui/strings/usergroups"/></th>
							<td class="padded">
								<select class="content" size="7" name="groups" multiple="" id="groups" disabled="disabled">
									<xsl:for-each select="/root/gui/groups/record">
										<xsl:sort select="name"/>
										<option value="{id}">
											<xsl:value-of select="label/child::*[name() = $lang]"/>
										</option>
									</xsl:for-each>
								</select>
							</td>
				        </tr>
				        <tr id="gn.scope">
				            <th class="padded">Scope</th>
				            <td class="padded">
				                <select class="content" id="scope" name="scope" size="1">
				                    <option value="0">Metadata tabel</option>
				                    <option value="1">Workspace tabel</option>
				                </select>
				            </td>
				        </tr>
				        <tr id="gn.executeType">
				            <th class="padded">Uitvoeringstype</th>
				            <td class="padded">
				                <select class="content" id="executeType" name="executeType" size="1">
				                    <option value="0">Enkel uuids tonen</option>
				                    <option value="1">Update uitvoeren</option>
				                </select>
				            </td>
				        </tr>
 			        </table>
                    <table id="gn.result" style="display:none;">
	                    <tr>
	                        <th id="gn.resultTitle" class="padded-content">
	                            <h2><xsl:value-of select="/root/gui/strings/existingMdUpdate" /></h2>
	                        </th>
	                        <td id="gn.resultContent" class="padded-content" />
	                    </tr>
                    </table>
				</form>
			</xsl:with-param>
			<xsl:with-param name="buttons">
				<button class="content" onclick="goBack()" id="back"><xsl:value-of select="/root/gui/strings/back"/></button>
				&#160;
				<button class="content" onclick="return submitForm()"  id="btUpdate"><xsl:value-of select="/root/gui/strings/existingUpdate"/></button>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ================================================================================ -->

</xsl:stylesheet>
