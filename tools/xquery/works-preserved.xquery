
declare default element namespace 'http://www.tei-c.org/ns/1.0';

let $doc := doc('../../../usaybia-data/data/texts/tei/lhom-en-14.xml')
let $item := $doc//item
(:Change the regex expression below if you want to search for different keywords :)
let $works-preserved := $item[note[matches(., '\W(edit|translat|preserve|manuscript)')]]
let $works-preserved-w-bio-titles :=
for $work in $works-preserved
    let $bio-header := $work/ancestor::div[@subtype = 'biography']/p[1]/hi[1]/text()
    let $bio-entry-num := $bio-header/replace(.,'\s+([\d\.]+).*','$1')
    let $bio-person := $bio-header/replace(.,'\s+[\d\.]+(.*)','$1')
    let $work-title := $work/text()
    let $work-title-transliterated := $work/hi[1][@rend='italic']/text()
    let $footnote := $work//note/p/text()
return
    <bibl>
        <author>{$bio-person}</author>
        <title xml:lang="en">{$work-title}</title>
        <title xml:lang="en-x-lhom">{$work-title-transliterated}</title>
        <citedRange>{$bio-entry-num}</citedRange>
        <note>{$footnote}</note>
    </bibl>
return
    $works-preserved-w-bio-titles
