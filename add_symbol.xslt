<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:gpx="http://www.topografix.com/GPX/1/1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="gpx">

  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="symbol_name">Light</xsl:param>

<!--Identity template, 
        provides default behavior that copies all content into the output -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gpx:wpt">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <gpx:sym><xsl:value-of select="$symbol_name"/></gpx:sym>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>

