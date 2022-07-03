xquery version "3.1";

declare default element namespace 'http://www.tei-c.org/ns/1.0';
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function local:get-uris($text as node()) as xs:string* {
    distinct-values($text//(persName|rs)/@ref[starts-with(., 'https://usaybia.net/person')])
};

declare function local:network($source as xs:string,$edge as xs:string,$targets as xs:string*) as xs:string* {
    for $target in $targets
    return concat($source,",",$edge,",",$target)
};

let $text := doc('/db/apps/usaybia-data/data/texts/tei/lhom-ar-10.xml')

let $pars := $text/TEI/text/body//div/(p|list|lg)

let $par-person-sets := 
    for $par in $pars
    let $n-regex := ".*\[([\d\.]+)\].*"
    (: Grabs numbered headers  :)
    let $n-text := $par/preceding-sibling::p[matches(hi,$n-regex)][1]/hi[1]
    (: Sanitizes numbered headers  :)
    let $n := $n-text/replace(replace(string-join(./text()),"[\s\n]",""),$n-regex,"$1")
    let $unique-persons-string := string-join(local:get-uris($par),",")
    return if (string-length($unique-persons-string)) then concat($n,";",$unique-persons-string) else ()

let $edges :=
    for $par in $par-person-sets
    let $tokenized := tokenize($par,";")
    let $n := $tokenized[1]
    let $uris := tokenize($tokenized[2],",")
    for $uri at $i in $uris
    return local:network($uri,$n,$uris[position()>$i])

return string-join($edges,"&#10;")