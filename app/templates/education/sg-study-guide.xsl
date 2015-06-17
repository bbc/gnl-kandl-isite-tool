<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
    xmlns="https://production.bbc.co.uk/isite2/project/education/sg-study-guide"
    xmlns:asset="https://production.bbc.co.uk/isite2/project/education/sg-study-guide"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="asset">

    <!--
        Output as XML and use the UTF-8 encoding (uppercase to match iSite2)
    -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:template match="/">
        <xsl:apply-templates select="//asset:study-guide" />
    </xsl:template>

    <xsl:template match="asset:study-guide">
        <xsl:element name="study-guide">
            <xsl:element name="id">
                <xsl:attribute name="label">
                    <xsl:value-of select="asset:id" />
                </xsl:attribute>
                <xsl:value-of select="asset:id" />
            </xsl:element>
            <xsl:element name="title">
                <xsl:value-of select="asset:title" />
            </xsl:element>
            <xsl:element name="short-synopsis">
                <xsl:value-of select="asset:short-synopsis" />
            </xsl:element>
            <xsl:element name="long-synopsis">
                <xsl:value-of select="asset:long-synopsis" />
            </xsl:element>
            <xsl:element name="subject">
                <xsl:value-of select="asset:subject" />
            </xsl:element>
            <xsl:element name="source">
                <xsl:value-of select="asset:source" />
            </xsl:element>
            <xsl:element name="topic-of-study">
                <xsl:choose>
                    <xsl:when test="asset:topic-of-study"><xsl:value-of select="asset:topic-of-study" /></xsl:when>
                    <xsl:when test="asset:facets/asset:facet[@type = 'topic-of-study']"><xsl:value-of select="asset:facets/asset:facet[@type = 'topic-of-study']/@id" /></xsl:when>
                    <xsl:otherwise></xsl:otherwise>
                </xsl:choose>
            </xsl:element>
            <xsl:element name="thing-id">
                <xsl:value-of select="asset:thing-id" />
            </xsl:element>
            <xsl:element name="chapters">
                <xsl:apply-templates select="asset:chapters/asset:chapter" />
            </xsl:element>
            <xsl:element name="links">
                <xsl:element name="internal-links">
                    <xsl:apply-templates select="asset:links/asset:internal-links/asset:internal-link" />
                </xsl:element>
                <xsl:element name="external-links">
                    <xsl:apply-templates select="asset:links/asset:external-links/asset:external-link" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="facets">
                <xsl:apply-templates select="asset:facets/asset:facet" />
            </xsl:element>
            <xsl:element name="glossary-terms">
                <xsl:apply-templates select="asset:glossary-terms/asset:glossary-term" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="asset:chapter">
        <xsl:element name="chapter">
            <xsl:attribute name="type">
                <xsl:value-of select="@type" />
            </xsl:attribute>
            <xsl:value-of select="text()" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="asset:internal-link">
        <xsl:element name="internal-link">
            <xsl:element name="internal-link-title">
                <xsl:value-of select="asset:internal-link-title" />
            </xsl:element>
            <xsl:element name="internal-link-url">
                <xsl:value-of select="asset:internal-link-url" />
            </xsl:element>
            <xsl:element name="internal-link-short-description">
                <xsl:value-of select="asset:internal-link-short-description" />
            </xsl:element>
            <xsl:element name="internal-link-pid">
                <xsl:value-of select="asset:internal-link-pid" />
            </xsl:element>
            <xsl:element name="internal-link-alt-text">
                <xsl:value-of select="asset:internal-link-alt-text" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="asset:external-link">
        <xsl:element name="external-link">
            <xsl:element name="external-link-title">
                <xsl:value-of select="asset:external-link-title" />
            </xsl:element>
            <xsl:element name="external-link-url">
                <xsl:value-of select="asset:external-link-url" />
            </xsl:element>
            <xsl:element name="external-link-short-description">
                <xsl:value-of select="asset:external-link-short-description" />
            </xsl:element>
            <xsl:element name="external-link-pid">
                <xsl:value-of select="asset:external-link-pid" />
            </xsl:element>
            <xsl:element name="external-link-alt-text">
                <xsl:value-of select="asset:external-link-alt-text" />
            </xsl:element>
            <xsl:element name="external-link-subscription">
                <xsl:value-of select="asset:external-link-subscription" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="asset:facet">
        <xsl:if test="(@type != 'topic-of-study') and (normalize-space(@id) != '')">
            <xsl:element name="facet">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id" />
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:value-of select="@type" />
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="asset:glossary-term">
        <xsl:element name="glossary-term">
            <xsl:element name="glossary">
                <xsl:value-of select="asset:glossary" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
