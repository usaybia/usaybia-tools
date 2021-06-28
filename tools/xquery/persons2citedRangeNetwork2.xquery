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
            srophe:citation-self-and-ancestors(replace($citation,'\.\d+$',''), $min-decimals))
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
    ( $source-uris as xs:string*, $citations-to-query as node()*, $refs as xs:string*, $end-ref-pattern as xs:string ) as node()* {
        for $source at $i in $source-uris
            for $ref at $level in $refs
            let $matching-citations := $citations-to-query[matches(.,concat($ref,$end-ref-pattern))][position()>(if ($level=1) then $i else 0)]
            return srophe:cooccurrence-relations($source, $matching-citations/ancestor::person/idno[matches(.,'https://usaybia.net')]/text(), $ref, $level)
    };


let $collection := collection('/db/apps/usaybia-data/data/persons/tei/')
let $persons-all := $collection/TEI/text/body/listPerson/person
let $lhom-cited := $persons-all/bibl[ptr/@target='https://usaybia.net/bibl/WVSJMDSV']/citedRange
let $lhom-digits-only := $lhom-cited/replace(.,'([\d\.]+)[^\d\.]*','$1')
let $lhom-digits-distinct := distinct-values($lhom-digits-only)
let $end-string := 'p?(\s|$)'

let $persons-index := 
    for $person in $persons-all 
    return
        <person ref="{$person/idno[starts-with(.,'https://usaybia.net')]/text()}">
            { for $citedRange in $person/bibl[ptr/@target='https://usaybia.net/bibl/WVSJMDSV']/citedRange[not(matches(.,'nos?\.'))]
            return
                element citedRange {replace($citedRange,'([\d\.]+)[^\d\.]*','$1')}
                }
        </person>

for $citation in $lhom-digits-distinct[position()<100]
    let $ancestor-refs: = srophe:citation-self-and-ancestors($citation, 1)
    for $ref in $ancestor-refs
        let $matching-persons-uris := 
            for $person in $persons-index[$ref=citedRange/text()]/@ref/string()
            return <person uri="{$person}"/>
    return 
        <ref value="{$ref}">
            {$matching-persons-uris}
        </ref>

(: for $citation in $lhom-digits-distinct[position()<100]
    let $end-string := 'p?(\s|$)'
    let $persons-with-citation := $lhom-cited[matches(.,concat($citation,$end-string))]/ancestor::person/idno[matches(.,'https://usaybia.net')]/text()
    let $ancestor-refs: = srophe:citation-self-and-ancestors($citation, 1)
    return srophe:cooccurrence-relations-from-refs($persons-with-citation, $lhom-cited, $ancestor-refs, $end-string) :)

    (: This is very slow! Need to create index of all URIs per distinct-refs.  :)