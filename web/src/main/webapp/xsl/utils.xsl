<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:gco="http://www.isotc211.org/2005/gco">

	<xsl:variable name="apos">&#x27;</xsl:variable>

	<xsl:variable name="maxAbstract" select="200"/>
	<xsl:variable name="maxKeywords" select="400"/>
	
	<!-- default: just copy -->
	<xsl:template match="@*|node()" mode="copy">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="escapeString">
		<xsl:param name="expr"/>
		
		<xsl:variable name="e1">
			<xsl:call-template name="replaceString">
				<xsl:with-param name="expr"        select="$expr"/>
				<xsl:with-param name="pattern"     select="'&amp;'"/>
				<xsl:with-param name="replacement" select="' and '"/><!-- FIXME : this is only english -->
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="e2">
			<xsl:call-template name="replaceString">
				<xsl:with-param name="expr"        select="$e1"/>
				<xsl:with-param name="pattern"     select='"&apos;"'/>
				<xsl:with-param name="replacement" select="' '"/><!-- FIXME : Here we should escape by
				valid character and not nothing. Check if that template is only used for JS escaping ? -->
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="replaceString">
			<xsl:with-param name="expr"        select="$e2"/>
			<xsl:with-param name="pattern"     select="'&quot;'"/>
			<xsl:with-param name="replacement" select="' '"/><!-- FIXME : Here we should escape by
				valid character and not nothing. Check if that template is only used for JS escaping ? -->
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="escapeXMLEntities" match="text()">
	
		<xsl:variable name="expr" select="."/>
		
		<xsl:variable name="e1">
			<xsl:call-template name="replaceString">
				<xsl:with-param name="expr"        select="$expr"/>
				<xsl:with-param name="pattern"     select="'&amp;'"/>
				<xsl:with-param name="replacement" select="'&amp;amp;'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="e2">
			<xsl:call-template name="replaceString">
				<xsl:with-param name="expr"        select="$e1"/>
				<xsl:with-param name="pattern"     select="'&lt;'"/>
				<xsl:with-param name="replacement" select="'&amp;lt;'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="e3">
			<xsl:call-template name="replaceString">
				<xsl:with-param name="expr"        select="$e2"/>
				<xsl:with-param name="pattern"     select="'&gt;'"/>
				<xsl:with-param name="replacement" select="'&amp;gt;'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="e4">
			<xsl:call-template name="replaceString">
				<xsl:with-param name="expr"        select="$e3"/>
				<xsl:with-param name="pattern"     select='"&apos;"'/>
				<xsl:with-param name="replacement" select="'&amp;apos;'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="replaceString">
			<xsl:with-param name="expr"        select="$e4"/>
			<xsl:with-param name="pattern"     select="'&quot;'"/>
			<xsl:with-param name="replacement" select="'&amp;quot;'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="replaceString">
		<xsl:param name="expr"/>
		<xsl:param name="pattern"/>
		<xsl:param name="replacement"/>
		
		<xsl:variable name="first" select="substring-before($expr,$pattern)"/>
		<xsl:choose>
			<xsl:when test="$first or starts-with($expr, $pattern)">
				<xsl:value-of select="$first"/>
				<xsl:value-of select="$replacement"/>
				<xsl:call-template name="replaceString">
					<xsl:with-param name="expr"        select="substring-after($expr,$pattern)"/>
					<xsl:with-param name="pattern"     select="$pattern"/>
					<xsl:with-param name="replacement" select="$replacement"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$expr"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="socialBookmarks">
		<xsl:param name="baseURL" />
		<xsl:param name="mdURL" />
		<xsl:param name="title" />
		<xsl:param name="abstract" />
		<xsl:variable name="t">
			<xsl:call-template name="escapeString">
				<xsl:with-param name="expr"        select="normalize-space($title)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="a">
			<xsl:call-template name="escapeString">
				<xsl:with-param name="expr"        select="normalize-space($abstract)"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:if test="not(contains($mdURL,'localhost')) and not(contains($mdURL,'127.0.0.1'))">
			<a href="mailto:?subject={$t}&amp;body=%0ALink:%0A{$mdURL}%0A%0AAbstract:%0A{$a}">
				<img src="{$baseURL}/images/mail.png" 
					alt="{/root/gui/strings/bookmarkEmail}" title="{/root/gui/strings/bookmarkEmail}" 
					style="border: 0px solid;padding:2px;padding-right:10px;"/>
			</a>
				
				<!-- Not browser independent, thus commented out -->
<!--			<a href="javascript:window.external.AddFavorite('{$mdURL}', '{$t}');">
				<img src="{$baseURL}/images/bookmark.png" 
					alt="Bookmark" title="Bookmark" 
					style="border: 0px solid;padding:2px;"/>
			</a> -->

			<!-- Instead of a bookmark, a permanent link to the record is useful anyway -->
			<a href="{$mdURL}">
				<img src="{$baseURL}/images/bookmark.png" 
					alt="{/root/gui/strings/bookmarkPermanent}" title="{/root/gui/strings/bookmarkPermanent}" style="border: 0px solid;padding:2px;"/>
			</a>
			
			<!-- add first sentence of abstract to the delicious notes -->
			<a href="http://del.icio.us/post?url={$mdURL}&amp;title={$t}&amp;notes={substring-before($a,'. ')}. " target="_blank">
				<img src="{$baseURL}/images/delicious.gif" 
					alt="{/root/gui/strings/bookmarkDelicious}" title="{/root/gui/strings/bookmarkDelicious}" 
					style="border: 0px solid;padding:2px;"/>
			</a> 
			<a href="http://digg.com/submit?url={$mdURL}&amp;title={substring($t,0,75)}&amp;bodytext={substring(substring-before($a,'. '),0,350)}.&amp;topic=environment" target="_blank">
				<img src="{$baseURL}/images/digg.gif" 
					alt="{/root/gui/strings/bookmarkDigg}" title="{/root/gui/strings/bookmarkDigg}" 
					style="border: 0px solid;padding:2px;"/>
			</a> 
			<a href="http://www.facebook.com/sharer.php?u={$mdURL}" target="_blank">
				<img src="{$baseURL}/images/facebook.gif" 
					alt="{/root/gui/strings/bookmarkFacebook}" title="{/root/gui/strings/bookmarkFacebook}" 
					style="border: 0px solid;padding:2px;"/>
			</a> 
			<a href="http://www.stumbleupon.com/submit?url={$mdURL}&amp;title={$t}" target="_blank">
				<img src="{$baseURL}/images/stumbleupon.gif" 
					alt="{/root/gui/strings/bookmarkStumbleUpon}" title="{/root/gui/strings/bookmarkStumbleUpon}" 
					style="border: 0px solid;padding:2px;"/>
			</a> 
		</xsl:if>
	</xsl:template>

  <xsl:template name="getXPath">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:if test="not(position() = 1)">
        <xsl:value-of select="name()"/>
      </xsl:if>
      <xsl:if test="not(position() = 1) and not(position() = last())">
        <xsl:text>/</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <!-- Check if is an attribute: http://www.dpawson.co.uk/xsl/sect2/nodetest.html#d7610e91 -->
    <xsl:if test="count(. | ../@*) = count(../@*)">/@<xsl:value-of select="name()"/></xsl:if>
  </xsl:template>

    <xsl:template name="getLabelElementValue">
        <xsl:param name="name"/>
        <xsl:param name="schema"/>
        <xsl:param name="elementName"/>

        <xsl:variable name="fullContext">
        	<xsl:variable name="fullContextTemp">
	            <xsl:call-template name="getXPath" />
        	</xsl:variable>
        	<xsl:choose>
	        	<xsl:when test="substring-after($fullContextTemp,$name)=''"><xsl:value-of select="$fullContextTemp"/></xsl:when>
	        	<xsl:otherwise><xsl:value-of select="concat(substring-before($fullContextTemp,$name),$name)"/></xsl:otherwise>
        	</xsl:choose>
        </xsl:variable>

        <xsl:variable name="context" select="name(parent::node())"/>
        <xsl:variable name="contextIsoType" select="parent::node()/@gco:isoType"/>

        <xsl:variable name="elementValue">
            <xsl:choose>
                <xsl:when test="starts-with($schema,'iso19139')">

                    <!-- Name with context in current schema -->
                    <xsl:variable name="propertyValueWithContext"
                                  select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/*[name(.)=$elementName])"/>

                    <!-- Name with context in base schema -->
                    <xsl:variable name="propertyValueWithContextIso"
                                  select="string(/root/gui/schemas/iso19139/labels/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/*[name(.)=$elementName])"/>

                    <!-- Name in current schema -->
                    <xsl:variable name="propertyValueWithoutContext" select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and not(@context)]/*[name(.)=$elementName])"/>

                    <!-- <xsl:message>Names <xsl:value-of select="concat($schematitleWithContext,' | ',$schematitleWithContextIso,' | ',$schematitle)"/></xsl:message> -->
                    <xsl:choose>

                        <xsl:when test="normalize-space($propertyValueWithoutContext)='' and
                                        normalize-space($propertyValueWithContext)='' and
                                        normalize-space($propertyValueWithContextIso)=''">
<!--                            <xsl:value-of select="string(/root/gui/schemas/iso19139/labels/element[@name=$name]/*[name(.)=$elementName])"/> -->
                        </xsl:when>
                        <xsl:when test="normalize-space($propertyValueWithContext)='' and
                                        normalize-space($propertyValueWithContextIso)=''">
                            <xsl:value-of select="$propertyValueWithoutContext"/>
                        </xsl:when>
                        <xsl:when test="normalize-space($propertyValueWithContext)='' and
                                        normalize-space($propertyValueWithoutContext)=''">
                            <xsl:value-of select="$propertyValueWithContextIso"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$propertyValueWithContext"/>
                        </xsl:otherwise>

                    </xsl:choose>
                </xsl:when>

                <!-- otherwise just get the title out of the approriate schema help file -->

                <xsl:otherwise>
                    <xsl:value-of select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name]/*[name(.)=$elementName])"/>
                </xsl:otherwise>

            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="normalize-space($elementValue)"/>
    </xsl:template>


    <!--
    	AGIV specific:
    	
        If the element is mandatory (xsd and labels.xml), it returns a string with the
        reason of the mandatory (iso, inspire, gdi).
    -->
    <xsl:template name="getMandatoryType">
        <xsl:param name="name"/>
        <xsl:param name="schema"/>
        
        <xsl:call-template name="getLabelElementValue">
			<xsl:with-param name="name" select="$name"/>
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="elementName">mandatoryType</xsl:with-param>			
        </xsl:call-template>
         
    </xsl:template>

    <!--
    	AGIV specific:
    	
        If the element has an additional tooltip (additional_info tag), then show it with
        an icon.
    -->
    <xsl:template name="getMandatoryTooltip">
        <xsl:param name="name"/>
        <xsl:param name="schema"/>
		<xsl:variable name="tooltip">
	        <xsl:call-template name="getLabelElementValue">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="elementName">mandatoryTooltip</xsl:with-param>			
	        </xsl:call-template>
        </xsl:variable>
		<xsl:variable name="type">
	        <xsl:call-template name="getLabelElementValue">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="elementName">mandatoryType</xsl:with-param>			
	        </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$type = 'iso' or $type = 'gdi' or $type = 'inspire' ">
			    <img src="../../apps/images/default/{$type}.png" >
					<xsl:attribute name="class"><xsl:value-of select="$type"/></xsl:attribute>
			        <xsl:if test="$tooltip">
				    	<xsl:attribute name="alt">
				    		<xsl:value-of select="$tooltip"/>
				    	</xsl:attribute>
				    	<xsl:attribute name="title">
				    		<xsl:value-of select="$tooltip"/>
				    	</xsl:attribute>
			    	</xsl:if>
			    </img>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
