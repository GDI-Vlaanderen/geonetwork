<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl">

  <xsl:include href="main.xsl"/>

  <!--
	page content
	-->
  <xsl:template name="content">
    <xsl:call-template name="formLayout">
      <xsl:with-param name="title" select="/root/gui/strings/metadataUpdateResults"/>
      <xsl:with-param name="content">

        <table width="100%">
          <tr>
            <td align="left">
              <xsl:choose>
                <xsl:when test="/root/response/modified">
                	<b>UUID's van gewijzigde records:</b><br/>
                	<xsl:for-each select="/root/response/modified/uuid">
						<xsl:value-of select="."/><br/>
                	</xsl:for-each>
                	<b>UUID's van ongewijzigde records:</b><br/>
                	<xsl:for-each select="/root/response/unchanged/uuid">
						<xsl:value-of select="."/><br/>
                	</xsl:for-each>
                	<b>UUID's van ongewijzigde records vanwege een fout tijdens het updaten:</b><br/>
                	<xsl:for-each select="/root/response/unchangedbyerror/uuid">
						<xsl:value-of select="."/><br/>
                	</xsl:for-each>
                	<b>UUID's van locked records:</b><br/>
                	<xsl:for-each select="/root/response/lockedby/uuid">
						<xsl:value-of select="."/><br/>
                	</xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="errors" select="count(/root/response/exceptions/exception)"/>
                  <br/>
                  <xsl:value-of select="concat($errors, ' ', /root/gui/strings/errors)"/>
                  <br/>
                  <ul>
                    <xsl:for-each select="/root/response/exceptions/exception">
                      <li>
							<xsl:value-of select="."/>
                      </li>
                    </xsl:for-each>
                  </ul>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </table>
      </xsl:with-param>

      <xsl:with-param name="buttons">
        <xsl:if test="/root/response/modified">
          
          <xsl:choose>
            <xsl:when test="/root/gui/config/client/@widget='true'">
              <button class="content" onclick="goBack()" id="back"><xsl:value-of
                select="/root/gui/strings/back"/></button>
            </xsl:when>
            <xsl:otherwise>
              <button class="content" onclick="goBack()" id="back"><xsl:value-of
                select="/root/gui/strings/back"/></button>
            </xsl:otherwise>
          </xsl:choose>
          
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
