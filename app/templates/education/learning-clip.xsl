<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
    xmlns="https://production.bbc.co.uk/isite2/project/education/learning-clip"
    xmlns:asset="https://production.bbc.co.uk/isite2/project/education/learning-clip"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="asset">

    <!--
        Output as XML and use the UTF-8 encoding (uppercase to match iSite2)
    -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:template match="//asset:learning-clip">
        <xsl:element name="learning-clip">
            <xsl:element name="details">
                <xsl:element name="id">
                    <xsl:attribute name="label">
                        <xsl:value-of select="asset:details/asset:id" />
                    </xsl:attribute>
                    <xsl:value-of select="asset:details/asset:id" />
                </xsl:element>
                <xsl:element name="meta-keywords">
                    <xsl:value-of select="asset:details/asset:meta-keywords" />
                </xsl:element>
                <xsl:element name="title">
                    <xsl:value-of select="asset:details/asset:title" />
                </xsl:element>
                <xsl:element name="short-synopsis">
                    <xsl:value-of select="asset:details/asset:short-synopsis" />
                </xsl:element>
                <xsl:element name="long-synopsis">
                    <xsl:value-of select="asset:details/asset:long-synopsis" />
                </xsl:element>
                <xsl:element name="topic-of-study">
                    <xsl:choose>
                        <xsl:when test="normalize-space(asset:details/asset:topic-of-study) != ''"><xsl:value-of select="asset:details/asset:topic-of-study" /></xsl:when>
                        <xsl:when test="normalize-space(asset:facets/asset:facets-container/asset:topic-of-study-facet) != ''"><xsl:value-of select="asset:facets/asset:facets-container/asset:topic-of-study-facet" /></xsl:when>
                        <xsl:otherwise></xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:element name="thing-id">
                    <xsl:value-of select="asset:details/asset:thing-id" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="notes">
                <xsl:element name="teacher-notes">
                    <xsl:value-of select="asset:notes/asset:teacher-notes" />
                </xsl:element>
                <xsl:element name="student-notes">
                    <xsl:value-of select="asset:notes/asset:student-notes" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="media">
                <xsl:element name="media-format">
                    <xsl:value-of select="asset:media/asset:media-format" />
                </xsl:element>
                <xsl:element name="pid-video">
                    <xsl:value-of select="asset:media/asset:pid-video" />
                </xsl:element>
                <xsl:element name="pid-audio">
                    <xsl:value-of select="asset:media/pid-audio" />
                </xsl:element>
                <xsl:element name="featured-clip">
                    <xsl:value-of select="asset:media/asset:featured-clip" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="facets">
                <xsl:element name="facets-container">
                    <xsl:apply-templates select="asset:facets/asset:facets-container/node()" />
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="asset:language[ancestor::asset:facets]">
        <xsl:element name="language">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <xsl:template match="asset:nation[ancestor::asset:facets]">
        <xsl:element name="nation">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <xsl:template match="asset:topic-of-study-facet[ancestor::asset:facets]"/>

    <xsl:template match="asset:exam-board[ancestor::asset:facets]"/>

    <xsl:template match="asset:tier[ancestor::asset:facets]"/>
</xsl:stylesheet>
