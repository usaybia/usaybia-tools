<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:usy="https://usaybia.net"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs" 
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:template match="/">
        <xsl:variable name="idnos" select="/TEI/text/body/ab[@type='factoid']/idno"/>
        <xsl:variable name="bio-refs" 
            select="distinct-values($idnos/replace(.,'http.*?factoid/(\d+-\d+)-\d+','$1'))"/>
        <xsl:variable name="factoids" select="TEI/text/body/ab[@type='factoid']"/>
        
        <xsl:for-each select="$bio-refs">
            <xsl:variable name="current-ref" select="."/>
            <xsl:variable name="current-filename" select="concat('lhom-',.,'.xml')"/>
            <xsl:variable name="current-factoids" 
                select="$factoids[matches(idno,concat('factoid/',$current-ref,'\-'))]"/>
            <xsl:result-document href="{$current-filename}"
                indent="yes">
                <TEI xmlns="http://www.tei-c.org/ns/1.0">
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title level="a">Ibn Abī Uṣaybiʿa, History of Physicians</title>
                                <title level="m">Wissensgemeinschaften</title>
                                <sponsor ref="https://www.uni-muenchen.de">
                                    <orgName>Ludwig Maximilian University of Munich</orgName>
                                    (<orgName xml:lang="de">Ludwig-Maximilians-Universität München</orgName>)
                                </sponsor>
                                <sponsor ref="http://www.naher-osten.uni-muenchen.de">
                                    <orgName>Institute of Near and Middle Eastern Studies</orgName>
                                    (<orgName xml:lang="de">Institut für den Nahen und Mittleren Osten</orgName>)
                                </sponsor>
                                <funder ref="https://www.bmbf.de/">
                                    <orgName>German Federal Ministry of Education and Research</orgName>
                                    (<orgName xml:lang="de">Bundesministerium für Bildung und Forschung</orgName>)
                                </funder>
                                <principal ref="#ngibson">Nathan P. Gibson</principal>
                                <editor role="creator" ref="#nloehr">Nadine Löhr</editor>
                                <respStmt>
                                    <resp>Data entry and encoding by</resp>
                                    <name xml:id="nloehr" 
                                        ref="https://usaybia.net/documentation/editors.xml#nloehr
                                        https://www.naher-osten.uni-muenchen.de/personen/wiss_ma/nadine_loehr/index.html"
                                        >Nadine Löhr</name>
                                </respStmt>
                                <respStmt>
                                    <resp>Data architecture by</resp>
                                    <name xml:id="dschwartz" 
                                        ref="https://syriaca.org/documentation/editors.xml#dschwartz">
                                        Daniel Schwartz</name>
                                </respStmt>
                            </titleStmt>
                            <editionStmt>
                                <edition n="0.1"/>
                            </editionStmt>
                            <publicationStmt>
                                <authority>Usaybia.net</authority>
                                <idno type="URI">http://usaybia.net/factoid/lhom-<xsl:value-of select="$current-ref"/>/tei</idno>
                                <availability>
                                    <licence target="http://creativecommons.org/licenses/by/3.0/">
                                        <p>Distributed under a Creative Commons Attribution 3.0 Unported
                                            License.</p>
                                    </licence>
                                </availability>
                                <date><!-- INPUT ONCE WE HAVE A "FINAL" DRAFT --></date>
                            </publicationStmt>
                            <sourceDesc>
                                <listBibl>
                                    <head>Sources for the Data in this Born Digital Prosopography</head>
                                    <bibl type="primary">
                                        <editor>
                                            <forename>Emilie</forename>
                                            <surname>Savage-Smith</surname>
                                        </editor>
                                        <editor>
                                            <forename>Simon</forename>
                                            <surname>Swain</surname>
                                        </editor>
                                        <editor>
                                            <forename>G. J. H. van</forename>
                                            <surname>Gelder</surname>
                                        </editor>
                                        <respStmt>
                                            <resp>contributor</resp>
                                            <forename>Ignacio Javier</forename>
                                            <surname>Sánchez Rojo</surname>
                                        </respStmt>
                                        <respStmt>
                                            <resp>contributor</resp>
                                            <forename>N. Peter</forename>
                                            <surname>Joosse</surname>
                                        </respStmt>
                                        <respStmt>
                                            <resp>contributor</resp>
                                            <forename>Alasdair</forename>
                                            <surname>Watson</surname>
                                        </respStmt>
                                        <respStmt>
                                            <resp>contributor</resp>
                                            <forename>Bruce</forename>
                                            <surname>Inksetter</surname>
                                        </respStmt>
                                        <respStmt>
                                            <resp>contributor</resp>
                                            <forename>Franak</forename>
                                            <surname>Hilloowala</surname>
                                        </respStmt>
                                        <title level="m">A literary history of medicine: the 'Uyūn al-anbā' fī ṭabaqāt al-aṭibbā' of Ibn Abī Uṣaybi'ah</title>
                                        <idno type="Zotero">WVSJMDSV</idno>
                                        <idno type="URI">http://zotero.org/groups/2349036/items/WVSJMDSV</idno>
                                        <ref target="https://dh.brill.com/scholarlyeditions/library/urn:cts:arabicLit:0668IbnAbiUsaibia/"/>
                                        <imprint>
                                            <pubPlace>Leiden</pubPlace>
                                            <publisher>Brill</publisher>
                                            <date>2020</date>
                                        </imprint>
                                        <ptr target="https://usaybia.net/bibl/WVSJMDSV"/>
                                    </bibl>
                                    <bibl type="urn">
                                        <ptr target="urn:cts:arabicLit:0668IbnAbiUsaibia.Tabaqatalatibba.lhom-ed-ara1"/>
                                    </bibl>
                                </listBibl>
                            </sourceDesc>
                        </fileDesc>
                        <encodingDesc>
                            <editorialDecl>
                                <p>The prosopographical data in this document was encoded from 
                                    <ref target="https://dh.brill.com/scholarlyeditions/library/urn:cts:arabicLit:0668IbnAbiUsaibia/">
                                        Emilie Savage-Smith, Simon Swain, and G. J. H. van Gelder, eds., 
                                        A Literary History of Medicine: The “Uyūn al-Anbā” Fī Ṭabaqāt al-Aṭibbā’ 
                                        of Ibn Abī Uṣaybi’ah, 5 vols. (Leiden: Brill, 2020)</ref>.</p>
                            </editorialDecl>
                            <classDecl>
                                <taxonomy>
                                    <category xml:id="calculated">
                                        <catDesc> Used to denote a date calculated by the editor from a regnal year
                                            given in the text. </catDesc>
                                    </category>
                                </taxonomy>
                            </classDecl>
                        </encodingDesc>
                        <profileDesc/> 
                        <revisionDesc>
                            <change who="#nloehr" when="2021-08-06">Created factoids for reader-of-handwriting relationships.</change>
                        </revisionDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <xsl:copy-of select="$current-factoids"/>
                        </body>
                    </text>                
                </TEI>
            </xsl:result-document>
        <!--<xsl:result-document href="lhom-14.xml"
            indent="yes">
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="TEI/@*"/>
                <xsl:copy-of select="TEI/teiHeader"/>
                <text>
                    <body>
                        <!-\- Need to adjust CTS references - maybe per bio basis -\->
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
        </xsl:result-document>-->
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="TEI/teiHeader"/>
</xsl:stylesheet>