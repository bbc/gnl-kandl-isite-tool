<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
	xmlns="https://production.bbc.co.uk/isite2/project/education/sg-study-guide-list"
	xmlns:asset="https://production.bbc.co.uk/isite2/project/education/sg-study-guide-list"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="asset">

	<!--
		Output as XML and use the UTF-8 encoding (uppercase to match iSite2)
	-->
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />

	<!--
		Some documents have URNs in the old and new formats, use this key
		to ensure that each URN is only output once.
	-->
	<xsl:key name="urns" match="//asset:study-guide" use="." />

	<xsl:template match="/">
		<xsl:apply-templates select="//asset:study-guide-list" />
	</xsl:template>

	<xsl:template match="asset:study-guide-list">
		<xsl:element name="study-guide-list">
			<xsl:element name="details">
				<xsl:element name="topic-of-study">
					<xsl:value-of select="//asset:topic-of-study" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="study-guides">
				<xsl:for-each select="//asset:study-guide[generate-id() = generate-id(key('urns',.)[1])]">
					<xsl:element name="study-guide">
						<xsl:element name="guide">
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
			<xsl:element name="iwonder-guides">
				<xsl:for-each select="//asset:iwonder-guide">
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>