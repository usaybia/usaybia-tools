xquery version "3.1";

declare default element namespace "http://www.tei-c.org/ns/1.0";

let $filenames := ('lhom-ar-p.xml','lhom-ar-01.xml','lhom-ar-02.xml','lhom-ar-03.xml','lhom-ar-04.xml','lhom-ar-05.xml','lhom-ar-06.xml','lhom-ar-07.xml','lhom-ar-08.xml','lhom-ar-09.xml','lhom-ar-10.xml','lhom-ar-11.xml','lhom-ar-12.xml','lhom-ar-13.xml','lhom-ar-14.xml','lhom-ar-15.xml')
let $collection := for $filename in $filenames return doc(concat('/db/apps/scholarnet/data/texts/tei/',$filename))
let $chapters := $collection/TEI/text/body//div[@subtype='chapter']

let $header := string-join(('Chapter','Arabic','Greek','Syriac','Hebrew','Persian','Sanskrit','Latin'),',')

let $lines := 
    for $chapter in $chapters
    let $arabic := count($chapter//rs[matches(@ref,'https?://syriaca.org/keyword/arabic-language')])
    let $greek := count($chapter//rs[matches(@ref,'https?://syriaca.org/keyword/greek-language-ancient')])
    let $syriac := count($chapter//rs[matches(@ref,'https?://syriaca.org/keyword/classical-syriac')])
    let $hebrew := count($chapter//rs[matches(@ref,'https?://syriaca.org/keyword/hebrew-language')])
    let $persian := count($chapter//rs[matches(@ref,'https?://syriaca.org/keyword/persian-language')])
    let $sanskrit := count($chapter//rs[matches(@ref,'https?://syriaca.org/keyword/sanskrit-language')])
    let $latin := count($chapter//rs[matches(@ref,'https?://syriaca.org/keyword/latin-language')])
    return string-join(($chapter/@n/string(),$arabic,$greek,$syriac,$hebrew,$persian,$sanskrit,$latin),',')

return $lines