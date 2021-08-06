xquery version "3.1";

declare default element namespace "http://www.tei-c.org/ns/1.0";

let $collection := collection('/db/apps/scholarnet/data/texts/tei')
(:let $bios := $collection/TEI/text/body//div[@subtype='biography']:)
let $heads := $collection/TEI/text/body//p[hi/@rend='bold' and matches(hi,'.*\[([\d\.]+)\].*')]
let $lines := 
    for $head in $heads
    let $head-n := normalize-space(replace(string-join(($head/hi[@rend='bold' and matches(.,'.*\[([\d\.]+)\].*')]/text())),'.*\[([\d\.]+)\].*','$1'))
    let $head-next-position := $head/following-sibling::p[hi/@rend='bold' and matches(hi,'.*\[([\d\.]+)\].*')][1]/position()
    let $pars := $head/following-sibling::*[position() lt $head-next-position]
(:    let $pars := $head/following-sibling::*[not(hi/@rend='bold' and matches(hi,'.*\[([\d\.]+)\].*')) and count(.|$head-next/preceding-sibling::node())=count($head-next/preceding-sibling::node())]:)
    let $languages := string-join(distinct-values($pars//rs/@ref[matches(.,'keyword')]/string()),',')
    return concat($head-n,',','[',$languages,']')
(:let $pars := $collection/TEI/text/body//p[descendant::rs[matches(@ref,'keyword')] and not(hi[@rend='bold'])]:)
(:let $lines := :)
(:    for $par in $pars:)
(:    let $par-n := replace($par/preceding-sibling::p[hi[@rend='bold']][1]/hi[@rend='bold'],'.*\[([\d\.]+)\].*','$1'):)
(:    let $languages := string-join(distinct-values($par//rs/@ref[matches(.,'keyword')]/string()),','):)
(:    return concat($par-n,',','[',$languages,']'):)
(:let $lines := :)
(:    for $bio in $bios:)
(:    let $chapter := $bio/ancestor::div[@subtype='chapter']:)
(:    let $bio-n := concat(string($chapter/@n),'.',string($bio/@n)):)
(:    let $languages := string-join(distinct-values($bio//rs/@ref[matches(.,'keyword')]/string()),','):)
(:    return concat($bio-n,',','[',$languages,']'):)
let $csv := concat('Reference,Languages&#10;',string-join(($lines),'&#10;'))

return $csv
(:    xmldb:store('/db/apps/scholarnet/data/texts/tei','languages.csv',($csv)):)
    