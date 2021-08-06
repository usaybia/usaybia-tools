xquery version "3.1";
declare default element namespace 'http://www.tei-c.org/ns/1.0';

(: To prevent crashes from this large operation, memory on the eXist instance should be set to at least 1024m :)

let $coll := collection("/db/apps/usaybia-data/data/persons/tei")
let $persons := $coll/TEI/text/body/listPerson/person
for $bibl in $persons/bibl[ptr/@target='https://usaybia.net/bibl/WVSJMDSV']
    let $citedRanges := $bibl/citedRange[@unit='section']
    let $old-citedRanges-entry := if (count($citedRanges)>1) then $citedRanges[last()] else ()
    let $new-citedRanges-entry := 
        if ($old-citedRanges-entry) 
        then 
        let $link-entry := concat('https://dh.brill.com/scholarlyeditions/reader/urn:cts:arabicLit:0668IbnAbiUsaibia.Tabaqatalatibba.lhom-ed-ara1:',$old-citedRanges-entry/text())
        return <citedRange ana='entry' unit='section' target='{$link-entry}'>{$old-citedRanges-entry/text()}</citedRange> else ()

    let $new-citedRanges-index := 
        let $tokenized-citedRanges := tokenize($citedRanges,'\s*;\s')
        for $citedRange in distinct-values($tokenized-citedRanges) 
        return 
            if ($citedRange = $old-citedRanges-entry/text()) 
            then  () 
            (: Need to add link to this using regex replace get only 1st decimal  :)
            else <citedRange unit='section'>{$citedRange}</citedRange>
    let $new-citedRanges := ($new-citedRanges-entry,$new-citedRanges-index)

return $new-citedRanges
(: (update insert $new-citedRanges following $citedRanges, update delete citedRanges) :)
