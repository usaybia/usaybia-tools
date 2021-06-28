xquery version "3.1";

declare default element namespace 'http://www.tei-c.org/ns/1.0';
declare namespace functx = "http://www.functx.com";
declare namespace srophe = "https://srophe.app";

declare function functx:escape-for-regex
  ( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;

(: Takes a citation in dot notation (e.g., 1.1.1.1) and returns the citation with its ancestors up to the level specified by $min-decimals (e.g., 1.1) :)
declare function srophe:citation-self-and-ancestors
    ( $citation as xs:string, $min-decimals as xs:integer) as xs:string* {
        if (count(tokenize($citation,'\.')) gt ($min-decimals + 1)) then
            ($citation,
            srophe:citation-self-and-ancestors(replace($citation,'\.[\dＡⅠ]+$',''), $min-decimals))
        else $citation
    };

(: Produces cooccurrence relation elements between the source and each of the target URIs. :)
declare function srophe:cooccurrence-relations
    ( $source-uri as xs:string, $target-uris as xs:string*, $ref as xs:string, $level as xs:integer) as node()* {
        for $target-uri in $target-uris
        return
    <relation type="cooccurrence" ana="level{$level}" ref="{$ref}" mutual="{$source-uri} {$target-uri}"/>
    };

(: Finds citations matching a series of hierarchically organized refs (dot notation, from most-to-least specific) and creates cooccurence relations from these. :)
declare function srophe:cooccurrence-relations-from-refs
    ( $persons-index as node()*, $refs as xs:string* ) as node()* {
        (: Using an index like this makes it 2x as efficient  :)
        let $ref-index := 
            for $ref in $refs
                let $matching-persons := 
                    for $person in $persons-index[$ref=citedRange/text()]/@ref/string()
                    return <person ref="{$person}"/>
                return 
                    <ref value="{$ref}">
                        {$matching-persons}
                    </ref>
        let $source-uris := $ref-index[1]/person/@ref/string()
        return 
            for $source-uri at $i in $source-uris
                for $ref at $level in $ref-index
                    let $target-uris := 
                        if ($level=1) then 
                            $source-uris[position()>$i]
                        else 
                            $ref/person/@ref/string()
                    return 
                        if ($level=1) then 
                            srophe:cooccurrence-relations($source-uri, $target-uris, $ref/@value/string(), $level)
                        else
                            srophe:cooccurrence-relations($source-uri, $target-uris, $ref/@value/string(), $level)
    };


let $collection := collection('/db/apps/usaybia-data/data/persons/tei/')
let $persons-all := $collection/TEI/text/body/listPerson/person
let $lhom-cited := $persons-all/bibl[ptr/@target='https://usaybia.net/bibl/WVSJMDSV']/citedRange
let $lhom-digits-only := $lhom-cited/replace(.,'([\dＡⅠ\.]+)[^\d\.]*','$1')
let $lhom-digits-distinct := distinct-values($lhom-digits-only)
let $end-string := 'p?(\s|$)'

let $persons-index := 
    for $person in $persons-all 
    return
        <person ref="{$person/idno[starts-with(.,'https://usaybia.net')]/text()}">
            { for $citedRange in $person/bibl[ptr/@target='https://usaybia.net/bibl/WVSJMDSV']/citedRange[not(matches(.,'nos?\.'))]
            return
                element citedRange {replace($citedRange,'([\dＡⅠ\.]+)[^\d\.]*','$1')}
                }
        </person>

for $citation in $lhom-digits-distinct[position()<290 and position() gt 280]
    let $ancestor-refs: = srophe:citation-self-and-ancestors($citation, 1)
    return srophe:cooccurrence-relations-from-refs($persons-index, $ancestor-refs)