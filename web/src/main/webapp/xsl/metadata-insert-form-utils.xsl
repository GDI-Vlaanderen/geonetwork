<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="metadata-insert-common-form">

        <xsl:variable name="lang" select="/root/gui/language"/>

        <!-- uuid constraints -->
        <tr id="gn.uuidAction">
            <th class="padded" valign="top">
                <xsl:value-of select="/root/gui/strings/uuidAction"/>
            </th>
            <td>
                <table>
                    <tr>
                        <td class="padded">
                            <input type="radio" id="nothing" name="uuidAction" value="nothing" checked="true"/>
                            <label for="nothing">
                                <xsl:value-of select="/root/gui/strings/nothing"/>
                            </label>
                            <xsl:text>&#160;</xsl:text>
                        </td>
                    </tr>
                    <tr>
                        <td class="padded">
                            <input type="radio" id="overwrite" name="uuidAction" value="overwrite"/>
                            <label for="overwrite">
                                <xsl:value-of select="/root/gui/strings/overwrite"/>
                            </label>
                            <xsl:text>&#160;</xsl:text>
                        </td>
                    </tr>
                    <tr>
                        <td class="padded">
                            <input type="radio" id="generateUUID" name="uuidAction" value="generateUUID"/>
                            <label for="generateUUID">
                                <xsl:value-of select="/root/gui/strings/generateUUID"/>
                            </label>
                            <xsl:text>&#160;</xsl:text>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>



        <!-- stylesheet -->
        <tr id="gn.stylesheet">
            <th class="padded">
                <xsl:value-of select="/root/gui/strings/styleSheet"/>
            </th>
            <td class="padded">
                <select class="content" id="styleSheet" name="styleSheet" size="1">
                    <option value="_none_">
                        <xsl:value-of select="/root/gui/strings/none"/>
                    </option>
                    <xsl:for-each select="/root/gui/importStyleSheets/record">
                        <xsl:sort select="name"/>
                        <option value="{id}">
                            <xsl:value-of select="name"/>
                        </option>
                    </xsl:for-each>
                </select>
            </td>
        </tr>


        <!-- validate -->
        <tr id="gn.validate">
            <th class="padded">
                <label for="validate">
                    <xsl:value-of select="/root/gui/strings/validate"/>
                </label>
            </th>
            <td>
                <input class="content" type="checkbox" name="validate" id="validate"/>
            </td>
        </tr>

        <!-- schematrons to use in validation -->
        <tr id="gn.schematrons">
            <th class="padded" colspan="2">
                <label for="schematrons">
                    Valideren schematrons 
                </label>
            </th>
            <xsl:for-each select="/root/gui/schematrons/schemas/schema">
	            <xsl:for-each select="schematronname">
	                <xsl:if test=". != 'schematron-rules-none.xsl'">
                        <tr><td/><td><input class="content" type="checkbox" name="{../schemaname}-{.}" id="{../schemaname}-{.}"/>
                        	<xsl:value-of select="/root/gui/strings/schematronRules"/><xsl:text> </xsl:text>
                        	<xsl:choose>
                        		<xsl:when test="contains(lower-case(.),'rules-gdi-vlaanderen')">
		                            <xsl:value-of select="/root/gui/strings/rulesgdivlaanderen"/>
                        		</xsl:when>
                        		<xsl:when test="contains(lower-case(.),'rules-geonetwork')">
                                    <xsl:value-of select="/root/gui/strings/rulesgeonetwork"/>
                        		</xsl:when>
                        		<xsl:when test="contains(lower-case(.),'rules-inspire')">
                                    <xsl:value-of select="/root/gui/strings/rulesinspire"/>
                        		</xsl:when>
                        		<xsl:when test="contains(lower-case(.),'rules-iso')">
                                    <xsl:value-of select="/root/gui/strings/rulesiso"/>
                        		</xsl:when>
                        		<xsl:otherwise>
                                    <xsl:value-of select="name(.)"/>
                        		</xsl:otherwise>
                        	</xsl:choose>
                        </td></tr>
	                </xsl:if>
	            </xsl:for-each>
             </xsl:for-each>
        </tr>

        <!-- Assign to current catalog -->
        <tr id="gn.assign">
            <th class="padded">
                <label for="assign">
                    <xsl:value-of select="/root/gui/strings/assign"/>
                </label>
            </th>
            <td>
                <input class="content" type="checkbox" name="assign" id="assign"/>
            </td>
        </tr>

        <!-- Only metadata link to groups configured in tabel metadatagrouprelation will be imported -->
        <tr id="gn.relatedOnly">
            <th class="padded" style="witdh:100px">
                <label for="relatedOnly">
                    <xsl:value-of select="/root/gui/strings/relatedOnly"/>
                </label>
            </th>
            <td>
                <input class="content" type="checkbox" name="relatedOnly" id="relatedOnly"/>
            </td>
        </tr>


        <!-- groups -->
        <tr id="gn.groups">
        	<xsl:variable name="groupCount" select="count(/root/gui/groups/record/label/child::*[name() = $lang])"/>
            <th class="padded">
            	<xsl:if test="$groupCount > 1">
	                <xsl:value-of select="/root/gui/strings/group"/>
				</xsl:if>	                
            </th>
            <td class="padded">
            	<xsl:if test="$groupCount = 1">
	                <input class="content" type="hidden" name="group" id="group" value="{/root/gui/groups/record/id}"/>
            	</xsl:if>
            	<xsl:if test="$groupCount > 1">
	                <select class="content" name="group" size="1" style="width:400px">
	                    <xsl:for-each select="/root/gui/groups/record">
	                        <xsl:sort select="label/child::*[name() = $lang]"/>
	                        <option value="{id}">
	                            <xsl:value-of select="label/child::*[name() = $lang]"/>
	                        </option>
	                    </xsl:for-each>
	                </select>
               </xsl:if>
            </td>
        </tr>
		<input type="hidden" name="category" value="_none_"/>
    </xsl:template>
</xsl:stylesheet>
