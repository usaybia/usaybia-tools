declare default element namespace 'http://www.tei-c.org/ns/1.0';
declare namespace usy = "https://usaybia.net";

declare function usy:remove-notes ($node as node()) as xs:string* {
    for $item in $node/node()
                return 
                    if ($item/name()!='note') then replace($item,'[\n\t]+',' ')
                    else ()
};
(: 
let $doc-list := (
'../../../usaybia-data/data/texts/tei/lhom-ar-p.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-01.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-02.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-03.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-04.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-05.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-06.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-07.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-08.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-09.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-10.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-11.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-12.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-13.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-14.xml',
'../../../usaybia-data/data/texts/tei/lhom-ar-15.xml'
)
:)
(: let $works-all-docs := 
    for $doc-item in $doc-list :)
        let $doc := doc('../../../usaybia-data/data/texts/tei/lhom-ar-14.xml')
        let $works := $doc//div//title

        let $rows := 
            for $work in $works
                let $uri := string($work/@ref)
                let $title := usy:remove-notes($work)
                let $n := string($work/@n)
                let $author := $work/ancestor::div[@subtype='biography'][1]/p[1]/hi[@rend='bold'][1]
                let $author-string := usy:remove-notes($author)
                let $author-string-no-brackets := replace(string-join($author-string),'\s*\[[0-9\.]+\]\s*','')
                return ($uri,'&#9;',$title,'&#9;',$n,'&#9;',$author-string-no-brackets,'
')
    (: return $rows :)
        
let $header := ('URI','&#9;','Title','&#9;','Number','&#9;','Author
')

return ($header,$rows)

