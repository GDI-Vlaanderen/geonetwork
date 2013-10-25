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
            <th class="padded">
                <label for="schematrons">
                    Schematrons
                </label>
            </th>
            <td>
            <xsl:for-each select="/root/gui/schematrons/schemas/schema">

                    <table class="text-aligned-left">
                        <tr>
                            <th class="padded">
                                <xsl:value-of select="schemaname"/>
                                <xsl:if test="count(schematronname[. != 'schematron-rules-none.xsl']) = 0">
                                    (no schematrons)
                                </xsl:if>
                            </th>
                        </tr>
                        <xsl:for-each select="schematronname">
                            <xsl:if test=". != 'schematron-rules-none.xsl'">
                                <tr>
                                    <td class="padded">
                                        <xsl:text>&#160;</xsl:text>
                                    </td>
                                    <td>  <input class="content" type="checkbox" name="{../schemaname}-{.}" id="{../schemaname}-{.}"/>
                                        <xsl:value-of select="."/>
                                    </td>
                                </tr>
                            </xsl:if>
                        </xsl:for-each>
                    </table>
            </xsl:for-each>
            </td>
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


        <!-- groups -->
        <tr id="gn.groups">
            <th class="padded">
                <xsl:value-of select="/root/gui/strings/group"/>
            </th>
            <td class="padded">
                <select class="content" name="group" size="1" style="width:400px">
                    <xsl:for-each select="/root/gui/groups/record">
                        <xsl:sort select="label/child::*[name() = $lang]"/>
                        <option value="{id}">
                            <xsl:value-of select="label/child::*[name() = $lang]"/>
                        </option>
                    </xsl:for-each>
                </select>
            </td>
        </tr>



        <!-- categories 
        Some users are not using categories, so hide the list and
        set default value to _none_ if no categories available.
        -->
        <xsl:choose>
            <xsl:when test="/root/gui/categories/record and /root/gui/config/category/admin">
                <tr id="gn.categories">
                    <th class="padded">
                        <xsl:value-of select="/root/gui/strings/category"/>
                    </th>
                    <td class="padded">
                        <select class="content" name="category" size="1">
                            <option value="_none_">
                                <xsl:value-of select="/root/gui/strings/none"/>
                            </option>
                            <xsl:for-each select="/root/gui/categories/record">
                                <xsl:sort select="label/child::*[name() = $lang]"/>
                                <option value="{id}">
                                    <xsl:value-of select="label/child::*[name() = $lang]"/>
                                </option>
                            </xsl:for-each>
                        </select>
                    </td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <input type="hidden" name="category" value="_none_"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
