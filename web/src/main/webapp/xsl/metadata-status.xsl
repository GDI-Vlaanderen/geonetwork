<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:import href="modal.xsl"/>

    <!--
     page content
     -->
    <xsl:template name="content">
        <xsl:call-template name="formLayout">
            <xsl:with-param name="title" select="/root/gui/strings/status"/>
            <xsl:with-param name="content">

                <div id="status" align="center">
                    <xsl:if test="/root/response/statusvalues/*">

							<input name="id" type="hidden" value="{/root/response/id}"/>
	                        <table>
                            <tr>
                                <th class="padded" align="center" colspan="2"><xsl:value-of select="/root/gui/strings/status"/></th>
                            </tr>

                            <xsl:variable name="lang" select="/root/gui/language"/>
                            <xsl:variable name="profile" select="/root/gui/session/profile"/>
                            <xsl:variable name="nodeType" select="/root/response/nodeType"/>                                            
                            <xsl:variable name="currentStatus" select="/root/response/status"/>                                            
                            <xsl:variable name="isWorkspace" select="/root/response/isWorkspace"/>                                            
                            <xsl:variable name="disabled" select="false"/>                                            


                            <!-- loop on all status -->

                            <xsl:for-each select="/root/response/statusvalues/status[label/child::*[name() = $lang]]">
<!--                                <xsl:sort select="[label/child::*[name() = $lang]]"/>-->
                                <!-- do not display status JUSTCREATED -->
                                <xsl:if test="id != '0' and id != '6'">
                                    <tr>
                                        <td class="padded" align="left" colspan="2">
                                            <input type="radio" name="status" value="{id}" id="st{id}">
                                                <xsl:if test="$currentStatus=id">
                                                    <xsl:attribute name="checked"/>
                                                </xsl:if>
                                                <xsl:if test="contains($profile,'Admin')">
                                                	<xsl:choose>
                                                		<xsl:when test="id='1'">
	                                                		<xsl:if test="$currentStatus='4' or $currentStatus='5' or $currentStatus='7' or $currentStatus='8' or $currentStatus='9' or $currentStatus='10' or $currentStatus='11'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
	                                                        </xsl:if>
                                                		</xsl:when>
                                                		<xsl:when test="id='2'">
	                                                		<xsl:if test="$currentStatus='4' or $currentStatus='5' or $currentStatus='9' or $currentStatus='10' or $currentStatus='11' or $currentStatus='13' or $currentStatus='14'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
	                                                        </xsl:if>
                                                		</xsl:when>
                                                		<xsl:when test="id='3'">
															<xsl:if test="lower-case($nodeType)='agiv' and $currentStatus!='10'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
															</xsl:if>
                                                		</xsl:when>
                                                		<xsl:when test="id='4' or id='5'">
	                                                        <xsl:attribute name="disabled"/>
								                            <xsl:variable name="disabled" select="true"/>                                            
                                                		</xsl:when>
<!-- 
                                                		<xsl:when test="id='4'">
															<xsl:if test="lower-case($nodeType)='agiv'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>
									                        </xsl:if>                                            
                                                		</xsl:when>
                                                		<xsl:when test="id='5'">
	                                                        <xsl:attribute name="disabled"/>
								                            <xsl:variable name="disabled" select="true"/>                                            
                                                		</xsl:when>
-->
                                                		<xsl:when test="id='7'">
	                                                		<xsl:if test="$currentStatus!='1'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
	                                                        </xsl:if>
                                                		</xsl:when>
                                                		<xsl:when test="id='8'">
	                                                		<xsl:if test="$currentStatus!='1' and $currentStatus!='7'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
	                                                        </xsl:if>
                                                		</xsl:when>
                                                		<xsl:when test="id='9'">
	                                                		<xsl:if test="$currentStatus='1' or $currentStatus='2' or $currentStatus='3' or $currentStatus='4' or $currentStatus='5' or $currentStatus='8' or $currentStatus='10' or $currentStatus='11'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
	                                                        </xsl:if>
                                                		</xsl:when>
                                                		<xsl:when test="id='10'">
															<xsl:if test="$isWorkspace='true' or $currentStatus='3' or $currentStatus='11'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
															</xsl:if>
                                                		</xsl:when>
                                                		<xsl:when test="id='11'">
															<xsl:if test="$isWorkspace='true' or $currentStatus='10'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
															</xsl:if>
                                                		</xsl:when>
                                                		<xsl:when test="id='12'">
															<xsl:if test="lower-case($nodeType)='agiv' and $currentStatus!='11'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
															</xsl:if>
                                                		</xsl:when>
                                                		<xsl:when test="id='13'">
															<xsl:if test="$currentStatus!='10'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
															</xsl:if>
                                                		</xsl:when>
                                                		<xsl:when test="id='14'">
															<xsl:if test="$currentStatus!='11'">
		                                                        <xsl:attribute name="disabled"/>
									                            <xsl:variable name="disabled" select="true"/>                                            
															</xsl:if>
                                                		</xsl:when>
                                                		<xsl:otherwise>
                                                		</xsl:otherwise>
                                                	</xsl:choose>
                                               	</xsl:if>
                                                <xsl:if test="contains($profile,'Hoofdeditor')">
                                                	<xsl:choose>
                                                		<xsl:when test="$currentStatus='7' or $currentStatus='8' or $currentStatus='10' or $currentStatus='11'">
	                                                        <xsl:attribute name="disabled"/>
								                            <xsl:variable name="disabled" select="true"/>                                            
                                                        </xsl:when>
                                                        <xsl:otherwise>
		                                                	<xsl:choose>
		                                                		<xsl:when test="id='0' or id='1' or id='3' or id='6' or id='8' or id='9' or id='12' or id='13' or id='14'">
			                                                        <xsl:attribute name="disabled"/>
										                            <xsl:variable name="disabled" select="true"/>                                            
		                                                		</xsl:when>
		                                                		<xsl:when test="id='2'">
																	<xsl:if test="lower-case($nodeType)='agiv'">
				                                                        <xsl:attribute name="disabled"/>
											                            <xsl:variable name="disabled" select="true"/>                                            
			                                                        </xsl:if>
		                                                		</xsl:when>
		                                                		<xsl:when test="id='4' or id='5' or id='7'">
			                                                		<xsl:if test="$currentStatus='2' or $currentStatus='3'">
				                                                        <xsl:attribute name="disabled"/>
											                            <xsl:variable name="disabled" select="true"/>                                            
			                                                        </xsl:if>
		                                                		</xsl:when>
		                                                		<xsl:when test="id='10'">
																	<xsl:if test="$isWorkspace='true' or $currentStatus='3' or $currentStatus='11'">
				                                                        <xsl:attribute name="disabled"/>
											                            <xsl:variable name="disabled" select="true"/>                                            
																	</xsl:if>
		                                                		</xsl:when>
		                                                		<xsl:when test="id='11'">
																	<xsl:if test="$isWorkspace='true' or $currentStatus='10'">
				                                                        <xsl:attribute name="disabled"/>
											                            <xsl:variable name="disabled" select="true"/>                                            
																	</xsl:if>
		                                                		</xsl:when>
		                                                		<xsl:otherwise>
		                                                		</xsl:otherwise>
		                                                	</xsl:choose>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                               	</xsl:if>
                                                <xsl:if test="contains($profile,'Editor')">
                                                	<xsl:choose>
                                                		<xsl:when test="$currentStatus='4' or $currentStatus='7'">
	                                                        <xsl:attribute name="disabled"/>
															<xsl:variable name="disabled" select="true"/>                                            
                                                        </xsl:when>
                                                        <xsl:otherwise>
		                                                	<xsl:choose>
		                                                		<xsl:when test="id='0' or id='1' or id='2' or id='3' or id='5' or id='6' or id='7' or id='8' or id='9' or id='10' or id='11' or id='12' or id='13' or id='14'">
			                                                        <xsl:attribute name="disabled"/>
																	<xsl:variable name="disabled" select="true"/>                                            
		                                                		</xsl:when>
		                                                		<xsl:when test="id='4'">
			                                                		<xsl:if test="$currentStatus!='1' and $currentStatus!='5' and $currentStatus!='9'">
				                                                        <xsl:attribute name="disabled"/>
											                            <xsl:variable name="disabled" select="true"/>                                            
			                                                        </xsl:if>
		                                                		</xsl:when>
		                                                		<xsl:otherwise>
		                                                		</xsl:otherwise>
		                                                	</xsl:choose>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                               	</xsl:if>
                                               <label for="st{id}">
                                                    <xsl:if test="$disabled">
                                                        <xsl:attribute name="class">status_disabled</xsl:attribute>
                                                    </xsl:if>
                                                    <xsl:value-of select="label/child::*[name() = $lang]"/>
                                                </label>
                                             </input>
                                        </td>
                                    </tr>
                                </xsl:if>
                            </xsl:for-each>
                            <tr width="100%">
                                <td align="left">
                                    <xsl:value-of select="/root/gui/strings/changeLogMessage"/>
                                </td>
                                <td align="left">
                                    <textarea rows="8" cols="25" id="changeMessage" name="changeMessage"><xsl:value-of select="/root/gui/strings/defaultStatusChangeMessage"/></textarea>
                                </td>
                            </tr>
                            <tr width="100%">
                                <td align="center" colspan="2">
                                    <xsl:choose>
                                        <xsl:when test="contains(/root/gui/reqService,'metadata.batch')">
                                            <button class="content" onclick="radioModalUpdate('status','metadata.batch.update.status','true','{concat(/root/gui/strings/results,' ',/root/gui/strings/batchUpdateStatusTitle)}',this);this.disabled = true;"><xsl:value-of select="/root/gui/strings/submit"/></button>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <button class="content" onclick="radioModalUpdate('status','metadata.status','true','{/root/gui/strings/status}',this);this.disabled = true;"><xsl:value-of select="/root/gui/strings/submit"/></button>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>
                    </xsl:if>
                </div>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>