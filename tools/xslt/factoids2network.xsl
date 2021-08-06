<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:usy="https://usaybia.net"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="text" indent="yes"/>
    
    <!-- Joins all input nodes as comma-separated values, followed by a line break.
    Assumes that rows with blank Column 1 values should be joined to previous row.-->
    <xsl:function name="usy:create-csv-row">
        <xsl:param name="cells-as-nodes" as="item()+"/>
        <xsl:value-of 
                    xml:space="preserve"
                    select="replace(concat(string-join($cells-as-nodes,','),'&#10;'),'\n,',',')"/>
    </xsl:function>
    
    <!-- Creates 1 row for each of the items in $items2, in the format item1,item2 -->
    <xsl:function name="usy:item1-x-items2-csv">
        <xsl:param name="item1" as="item()"/>
        <xsl:param name="items2" as="item()+"/>
        <xsl:for-each select="$items2">
            <xsl:value-of select="usy:create-csv-row(($item1,.))"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Creates 1 row for each possible pair of $items1 and $items2 in the format item1, item2 -->
    <xsl:function name="usy:items1-x-items2-csv">
        <xsl:param name="items1" as="item()+"/>
        <xsl:param name="items2" as="item()+"/>
        <xsl:for-each select="$items1">
            <xsl:value-of select="usy:item1-x-items2-csv(.,$items2)"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Creates 1 row for each possible directional pair among $items and adds $edge to the end of each row. -->
    <!-- This must be called separately for each relation/edge type. -->
    <xsl:function name="usy:relation-mutual-csv">
        <xsl:param name="items" as="item()+"/>
        <xsl:param name="edge" as="item()"/>
        <xsl:variable name="permutations">
            <xsl:for-each select="$items">
                <xsl:value-of select="usy:item1-x-items2-csv(.,$items[.!=current()])"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$permutations">
            <xsl:value-of select="replace(.,'\n',concat(',',$edge,'&#10;'))"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Creates 1 row (including edge) for each possible pair of sources and targets. -->
    <xsl:function name="usy:relation-csv">
        <!-- This must be called separately for each relation/edge type. -->
        <xsl:param name="sources" as="item()+"/>
        <xsl:param name="targets" as="item()+"/>
        <xsl:param name="edge" as="item()"/>
        <xsl:variable name="permutations" select="usy:items1-x-items2-csv($sources,$targets)"/>
        <xsl:for-each select="$permutations">
            <xsl:value-of select="replace(.,'\n',concat(',',$edge,'&#10;'))"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Creates 1 row (including edge) for each possible pair of sources and targets, 
        plus an additional row for the inverse. -->    
    <!-- This must be called separately for each relation/edge type. -->
    <xsl:function name="usy:relation-csv-with-inverse">
        <xsl:param name="sources" as="item()+"/>
        <xsl:param name="targets" as="item()+"/>
        <xsl:param name="edge" as="item()"/>
        <xsl:value-of select="usy:relation-csv($sources,$targets,$edge)"/>
        <xsl:value-of select="usy:relation-csv($targets,$sources,concat('inverse of ',$edge))"/>
    </xsl:function>
    
    <!-- Converts a space-separated URI string into a sequence. -->
    <xsl:function name="usy:sequence-multi-uris">
        <xsl:param name="space-separated-uris" as="item()*"/>
        <xsl:for-each select="$space-separated-uris">
            <xsl:sequence select="tokenize(string(.),'\s+')"/>
        </xsl:for-each>        
    </xsl:function>
    
    <xsl:template 
        xpath-default-namespace="http://www.tei-c.org/ns/1.0" 
        match="/">
        
        <!-- Grabs factoids filename to use in outputing relations csv. --> 
        <xsl:variable name="factoids-filename" select="replace(document-uri(),'file:.*/(.*)\.xml','$1')"/>
        
        <!-- Creates a CSV file of relations (edges). -->
        <xsl:result-document href="../csv/{$factoids-filename}-edges.csv">
            
            <!-- Column headers -->
            <xsl:value-of select="usy:create-csv-row(('Source','Target','Relation'))"/>
            
            <!-- Loops through all factoids -->
            <xsl:for-each select="TEI/text/body/ab[@type='factoid']">
                
                <!-- Handles relation factoids -->
                <xsl:if 
                    test="@subtype='relation' and listRelation/relation/@type='person'">
                    
                    <xsl:variable name="relation"
                        select="listRelation/relation"/>
                    <xsl:variable name="active-items" 
                        select="usy:sequence-multi-uris($relation/@active)"/>
                    <xsl:variable name="passive-items" 
                        select="usy:sequence-multi-uris($relation/@passive)"/>
                    <xsl:variable name="mutual-items" 
                        select="usy:sequence-multi-uris($relation/@mutual)"/>
                    <xsl:variable name="edge" 
                        select="$relation/@ref"/>
                    
                    <xsl:value-of select="if (count($active-items)) then usy:relation-csv-with-inverse($active-items,$passive-items,$edge) else ()"/>
                    <xsl:value-of select="if (count($mutual-items)) then usy:relation-mutual-csv($mutual-items,$edge) else ()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        
        <!-- Creates a CSV file of person attributes (nodes). -->
        <xsl:result-document href="../csv/{$factoids-filename}-persons.csv">
            <xsl:variable name="all-persNames-csv">
                <xsl:for-each select="TEI/text/body/ab//persName">
                    <xsl:value-of select="usy:create-csv-row((@ref,normalize-space(replace(text(),'\s+',' '))))"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="usy:create-csv-row(('URI','Name'))"/>
            
            <!-- Outputs only unique URI-name combinations -->
            <xsl:for-each select="distinct-values(tokenize($all-persNames-csv,'\n'))">
                <xsl:value-of select="concat(.,'&#10;')"/>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>