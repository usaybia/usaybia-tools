<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" 
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    
    <!-- Run this XSLT on the Arabic doc, put the path to the English doc below. -->
    <xsl:variable name="en-doc" select="doc('../../../usaybia-data/data/texts/tei/lhom-en-14.xml')"/>
    
    <xsl:template match="/">
        <xsl:result-document href="lhom-14.xml"
            indent="yes">
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="TEI/@*"/>
                <xsl:copy-of select="TEI/teiHeader"/>
                <text>
                    <body>
                        <!-- Need to adjust CTS references - maybe per bio basis -->
                        <div type="edition" n="urn:cts:arabicLit:0668IbnAbiUsaibia.Tabaqatalatibba.lhom-ed-ara1">
                            <div type="textpart" subtype="chapter" n="14">
                                <xsl:for-each select="//div[@type='textpart' and @subtype='biography']">
                                    <xsl:call-template name="bios">
                                        <xsl:with-param name="bio-n" select="@n"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </div>
                        </div>
                    </body>
                </text>
            </TEI>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template 
        name="bios"
        xpath-default-namespace="http://www.tei-c.org/ns/1.0">
        <xsl:param name="bio-n"/>
        <xsl:param name="en-bio" 
            select="$en-doc//div[@subtype='biography' and @n=$bio-n]"/>
        <div xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="(head,$en-bio/head)"/>
            <xsl:for-each select="p|list|lg">
                <xsl:variable name="n" 
                    select="count(preceding-sibling::p|preceding-sibling::list|preceding-sibling::lg)+1"/>
                <!-- Need to find a way of adding xml:lang="ar-Arab" -->
                <xsl:copy-of select="."/>
                <!-- Need to find a way of adding xml:lang="en" -->
                <xsl:copy-of select="$en-bio/(p|list|lg)[$n]"/>
                <xsl:if test="$en-bio/(p|list|lg)[$n]/following-sibling::*[1]/name() = ('cit','figure')">
                    <xsl:copy-of select="$en-bio/(p|list|lg)[$n]/following-sibling::*[1]"/>
                </xsl:if>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <xsl:template match="TEI/teiHeader"/>
</xsl:stylesheet>