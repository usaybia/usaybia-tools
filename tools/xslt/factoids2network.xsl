<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:usy="https://usaybia.net"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="text" indent="yes"/>
    <xsl:function name="usy:create-csv-row">
        <xsl:param name="cells-as-nodes" as="item()+"/>
        <xsl:value-of 
                    xml:space="preserve"
                    select="(string-join($cells-as-nodes,','), '&#x0D;')"/>
    </xsl:function>
    <xsl:template 
        xpath-default-namespace="http://www.tei-c.org/ns/1.0" 
        match="/">
        <xsl:result-document href="../csv/test-edges.csv">
            <xsl:value-of select="usy:create-csv-row(('Source','Target','Relation'))"/>
            <xsl:for-each select="TEI/text/body/ab[@type='factoid']">
                <xsl:if 
                    test="@subtype='relation' and listRelation/relation/@type='person'">
                    <xsl:variable name="relation"
                        select="listRelation/relation"/>
                    <xsl:variable name="mutual" 
                        select="tokenize($relation/@mutual,'\s+')"/>
                    <xsl:variable name="source"
                        select="string($relation/@active),$mutual[1]"/>
                    <xsl:variable name="target" 
                        select="string($relation/@passive),$mutual[2]"/>
                    <xsl:variable name="edge" 
                        select="$relation/@ref"/>
                    <xsl:value-of select="usy:create-csv-row(($source,$target,$edge))"/>
                    <xsl:variable name="edge-inverse" 
                        select="if ($relation/@active) then concat('inverse of ',$edge) else $edge"/>
                    <xsl:value-of select="usy:create-csv-row(($target,$source,$edge-inverse))"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="../csv/test-persons.csv">
            <xsl:variable name="all-person-uris" select=""/>
            <xsl:for-each select="distinct-values(TEI/text/body/ab//persName)">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>