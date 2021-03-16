<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml"/>
    
    <xsl:variable name="n">
        <xsl:text/>
    </xsl:variable>
    
    <xsl:template xpath-default-namespace="http://www.tei-c.org/ns/1.0" 
        match="/TEI/text/body/div[@type='edition']/div[@subtype='chapter']/div[@subtype='biography']">
        
        <!-- creates a variable containing the path of the file to be created for this record, in the location defined by $directory -->
        <xsl:variable name="chapter" select="ancestor::div[@subtype='chapter']/@n"/>  
        <xsl:variable name="uri-prefix" select="concat('https://usaybia.net/text/',$chapter,'-')"/>
        <xsl:variable name="bio" select="@n"/>
        <xsl:variable name="prev-bio" select="number($bio)-1"/>
        <xsl:variable name="prev-bio-att" select="if (number($bio) gt 1) then concat($uri-prefix,$prev-bio,'#chapter-div') else ()"/>
        <xsl:variable name="next-bio" select="number($bio)+1"/>
        <xsl:variable name="next-bio-att" select="if (following-sibling::div[@subtype='biography' and @n=$next-bio]) then concat($uri-prefix,$next-bio,'#chapter-div') else ()"/>
        <xsl:variable name="filename" select="concat($chapter,'-',$bio,'.xml')"/>
        
        <!-- creates the XML file, if the filename has been sucessfully created. -->
        <xsl:if test="$filename != ''">
            <xsl:result-document href="{$filename}" format="xml">
                <!-- adds the xml-model instruction with the link to the Syriaca.org validator -->
                <xsl:processing-instruction name="xml-model">
                    <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
                </xsl:processing-instruction>
                <xsl:value-of select="$n"/>
                <TEI xmlns="http://www.tei-c.org/ns/1.0">  
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <xsl:variable name="current-bio" select="//div[@subtype='biography' and @n=$bio]"/>
                                <xsl:variable name="first-p" select="$current-bio/p[@n='1']"/>
                                <title xml:lang="ar-Arab" level="a">
                                    <xsl:value-of select="$first-p[@xml:lang='ar-Arab']/hi[@rend='bold'][1]/text()/normalize-space()"/>
                                </title>
                                <title xml:lang="en-Latn" level="a">
                                    <xsl:value-of select="$first-p[@xml:lang='en-Latn']/hi[@rend='bold'][1]/text()/normalize-space()"/>
                                </title>
                                <title xml:lang="ar-Arab" level="a">
                                    <xsl:copy-of select="//head[@xml:lang='ar-Arab'][1]/text()/normalize-space()"/>
                                </title>
                                <title xml:lang="en-Latn" level="a">
                                    <xsl:copy-of select="//head[@xml:lang='en-Latn'][1]/text()/normalize-space()"/>
                                </title>
                                <xsl:copy-of select="/TEI/teiHeader/fileDesc/titleStmt/*[not(@level='a')]"/>
                            </titleStmt>
                            <publicationStmt>
                                <xsl:copy-of select="/TEI/teiHeader/fileDesc/publicationStmt/idno/preceding-sibling::*"/>
                                <idno type="URI"><xsl:value-of select="concat($uri-prefix,$bio)"/></idno>
                                <xsl:copy-of select="/TEI/teiHeader/fileDesc/publicationStmt/idno/following-sibling::*"/>
                            </publicationStmt>
                            <xsl:copy-of select="/TEI/teiHeader/fileDesc/sourceDesc"/>
                        </fileDesc>
                        <revisionDesc>
                            <xsl:copy-of select="/TEI/teiHeader/revisionDesc/change"/>
                            <change xml:id="change-7" who="#ngibson" when="2021-03-16">Split chapter text file into individual biography files via https://github.com/usaybia/usaybia-tools/blob/33d7a4c0e9246efd9121553310e6b5e85dd68b02/tools/xslt/split-chapters-into-bios.xsl.</change>
                        </revisionDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <div type="textpart" subtype="chapter" n="12" xml:id="chapter-div">
                                <xsl:if test="string-length($prev-bio-att)">
                                    <xsl:attribute name="prev" select="$prev-bio-att"/>
                                </xsl:if>
                                <xsl:if test="string-length($next-bio-att)">
                                    <xsl:attribute name="next" select="$next-bio-att"/>
                                </xsl:if>
                                <xsl:copy-of select="."/>
                            </div>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>