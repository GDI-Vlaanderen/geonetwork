<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Page to redirect according to config-gui.xml configuration.
  It allows to switch from the main.home default service to the widget based GUI.
  -->
  <xsl:output omit-xml-declaration="yes" method="html"
    doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
    doctype-system="http://www.w3.org/TR/html4/loose.dtd" indent="yes" encoding="UTF-8"/>

  <xsl:template match="/">
    <html>
      <head>
                <script type="text/javascript" src="{/root/gui/url}/scripts/ext/adapter/ext/ext-base.js"></script>
        <script type="text/javascript" src="{/root/gui/url}/scripts/ext/ext-all.js"></script>
        <script language="Javascript1.5" type="text/javascript">
          // Redirect according to config-gui.xml client configuration
          <xsl:if test="string(/root/gui/session/userId)!=''">
				var GNCookie = new Ext.state.CookieProvider({
				  	expires: new Date(new Date().getTime()+(1000*60*60*24*365))
											//1 year from now
								});
				GNCookie.set('user', {
					id: '<xsl:value-of select="string(/root/gui/session/userId)" />',					
                    username: '<xsl:value-of select="string(/root/gui/session/username)" />',
                    name: '<xsl:value-of select="string(/root/gui/session/name)" />',
                    surname: '<xsl:value-of select="string(/root/gui/session/surname)" />',
                    role: '<xsl:value-of select="string(/root/gui/session/role)" />'
                }); 
          </xsl:if>
          var search = window.location.search;
          var url = '<xsl:value-of select="/root/gui/config/client/@url"/>';
          if (url === '') {
            url = 'main.home'
          }
          var parameters = '<xsl:value-of select="/root/gui/config/client/@parameters"/>';
          
          if (search) {
            window.location = url + search + (parameters!=='' ? '&amp;' + parameters:'');
          } else {
            window.location = url + (parameters!=='' ? '?' + parameters:'');
          }
        </script>
      </head>
      <body>
        <h2>JavaScript warning</h2>
        <p>To use GeoNetwork you need to enable JavaScript in your browser</p>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
