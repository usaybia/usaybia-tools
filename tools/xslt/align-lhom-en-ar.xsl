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
    
    
    <!-- Run this XSLT on the Arabic doc, put the path to the English doc below. -->
    <xsl:variable name="en-doc" select="doc('../../../usaybia-data/data/texts/tei/lhom-en-14.xml')"/>
    
    <!-- Collects place names and URIs for matching and tagging -->
    <xsl:variable 
        name="placeName-docs"
        select="collection('../../../usaybia-data/data/places/tei/?select=*.xml')[position() lt 11]"/>
    <xsl:variable name="placeNames">
        <xsl:for-each select="$placeName-docs/TEI/text/body/listPlace/place/placeName">
            <xsl:variable name="idno" select="./../idno[@type='URI' and starts-with(.,'https://usaybia.net')]"/>
            <placeName 
                xmlns="http://www.tei-c.org/ns/1.0"
                ref="{$idno}">
                <xsl:value-of select="."/>
            </placeName>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:function name="functx:escape-for-regex" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>
        
        <xsl:sequence select="
            replace($arg,
            '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
            "/>
        
    </xsl:function>
    
    <xsl:function name="functx:node-kind" as="xs:string*">
        <xsl:param name="nodes" as="node()*"/>
        
        <xsl:sequence select="
            for $node in $nodes
            return
            if ($node instance of element()) then 'element'
            else if ($node instance of attribute()) then 'attribute'
            else if ($node instance of text()) then 'text'
            else if ($node instance of document-node()) then 'document-node'
            else if ($node instance of comment()) then 'comment'
            else if ($node instance of processing-instruction())
            then 'processing-instruction'
            else 'unknown'
            "/>
        
    </xsl:function>
    
    <xsl:function name="functx:atomic-type" as="xs:string*">
        <xsl:param name="values" as="xs:anyAtomicType*"/>
        
        <xsl:sequence select="
            for $val in $values
            return
            (if ($val instance of xs:untypedAtomic) then 'xs:untypedAtomic'
            else if ($val instance of xs:anyURI) then 'xs:anyURI'
            else if ($val instance of xs:string) then 'xs:string'
            else if ($val instance of xs:QName) then 'xs:QName'
            else if ($val instance of xs:boolean) then 'xs:boolean'
            else if ($val instance of xs:base64Binary) then 'xs:base64Binary'
            else if ($val instance of xs:hexBinary) then 'xs:hexBinary'
            else if ($val instance of xs:integer) then 'xs:integer'
            else if ($val instance of xs:decimal) then 'xs:decimal'
            else if ($val instance of xs:float) then 'xs:float'
            else if ($val instance of xs:double) then 'xs:double'
            else if ($val instance of xs:date) then 'xs:date'
            else if ($val instance of xs:time) then 'xs:time'
            else if ($val instance of xs:dateTime) then 'xs:dateTime'
            else if ($val instance of xs:dayTimeDuration)
            then 'xs:dayTimeDuration'
            else if ($val instance of xs:yearMonthDuration)
            then 'xs:yearMonthDuration'
            else if ($val instance of xs:duration) then 'xs:duration'
            else if ($val instance of xs:gMonth) then 'xs:gMonth'
            else if ($val instance of xs:gYear) then 'xs:gYear'
            else if ($val instance of xs:gYearMonth) then 'xs:gYearMonth'
            else if ($val instance of xs:gDay) then 'xs:gDay'
            else if ($val instance of xs:gMonthDay) then 'xs:gMonthDay'
            else 'unknown')
            "/>
        
    </xsl:function>
    
    <xsl:function name="functx:sequence-type" as="xs:string">
        <xsl:param name="items" as="item()*"/>
        
        <xsl:sequence select="
            concat(
            if (empty($items))
            then 'empty-sequence()'
            else if (every $val in $items
            satisfies $val instance of xs:anyAtomicType)
            then if (count(distinct-values(functx:atomic-type($items)))
            > 1)
            then 'xs:anyAtomicType'
            else functx:atomic-type($items[1])
            else if (some $val in $items
            satisfies $val instance of xs:anyAtomicType)
            then 'item()'
            else if (count(distinct-values(functx:node-kind($items))) > 1)
            then 'node()'
            else concat(functx:node-kind($items[1]),'()')
            ,
            if (count($items) > 1)
            then '+' else '')
            "/>
        
    </xsl:function>
    
    <xsl:function name="usy:tagPlaceName">
        <xsl:param name="text"/>
        <xsl:param name="placeNameWithURI"/>
        <xsl:variable 
            name="placeNameRegex" 
            select="functx:escape-for-regex($placeNameWithURI/text())"/>
        <xsl:for-each select="$text">
            <xsl:choose>
                <!-- Tried 
                    <xsl:when test="matches(.,$placeNameRegex)
                    and functx:sequence-type(.)!='xs:string'"> 
                to avoid "string" error on ./* but is not processing child nodes -->
                <xsl:when test="matches(.,$placeNameRegex)
                    and ./*">
                    <xsl:copy-of select="usy:tagPlaceName(./node(),$placeNameWithURI)"/>
                </xsl:when>
                <!-- Need to add a function to escape regex --> 
                <xsl:when test="matches(.,$placeNameRegex)">
                    <xsl:analyze-string select="."
                        regex="{$placeNameRegex}">
                        <xsl:matching-substring>
                            <xsl:copy-of select="$placeNameWithURI"/>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:copy-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="usy:tagPlaceNames">
        <xsl:param name="text"/>
        <xsl:param name="placeNamesWithURIs"/>      
        <xsl:choose>
            <xsl:when test="$placeNamesWithURIs">
                <xsl:copy-of 
                    select="usy:tagPlaceNames(
                    usy:tagPlaceName($text,$placeNamesWithURIs[1]),
                    remove($placeNamesWithURIs, 1)
                    )"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
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
<!--                <xsl:copy-of select="$en-bio/(p|list|lg)[$n]"/>-->
                <!--<xsl:variable name="testPlaceName">
                    <placeName xmlns="http://www.tei-c.org/ns/1.0" ref="https://usaybia.net/place/18">Alexandria</placeName>
                </xsl:variable>-->
                <xsl:copy-of select="usy:tagPlaceNames($en-bio/(p|list|lg)[$n],$placeNames/placeName)"/>
                <xsl:if test="$en-bio/(p|list|lg)[$n]/following-sibling::*[1]/name() = ('cit','figure')">
                    <xsl:copy-of select="$en-bio/(p|list|lg)[$n]/following-sibling::*[1]"/>
                </xsl:if>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <xsl:template match="TEI/teiHeader"/>
</xsl:stylesheet>