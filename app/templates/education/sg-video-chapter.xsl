<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bs="https://production.bbc.co.uk/isite2/project/education/sg-video-chapter">

    <xsl:namespace-alias result-prefix="#default" stylesheet-prefix="bs" />

    <xsl:strip-space elements="*" />

    <!-- XML output and UTF-8 encoding (uppercased to match iSite2) -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
