xquery version "3.0";

declare default element namespace "http://www.tei-c.org/ns/1.0";

let $doc := doc('../../../usaybia-data/data/bibl/lhom-all.xml')

let $entries := $doc//p

let $line := 
    for $entry in $entries 
    let $entry-parts := $entry/node()
    let $entry-parts-titles-sanitized := 
        for $part in $entry-parts
        return if (name($part)="hi") then (string-join(("**",$part/text(),"**"))) else $part
    return normalize-space(string-join($entry-parts-titles-sanitized))
           
return string-join(($line),"
")