xquery version "3.1";

declare default element namespace 'http://www.tei-c.org/ns/1.0';
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function local:get-uris($text as node()) as xs:string* {
    distinct-values($text//(persName|rs)/@ref[starts-with(., 'https://usaybia.net/person')])
};

declare function local:get-person($person-uri as xs:string, $person-records as node()*, $uri-index as node()*) as node()? {
    (: Using an index position seems to speed up the query  :)
    let $index-pos := index-of($uri-index,$person-uri)
    return 
        $person-records[$index-pos]/TEI/text/body/listPerson/person
};

declare function local:occurrences($text as node(),$person-uri as xs:string) as xs:integer {
    count($text//persName[@ref=$person-uri]) + count($text//rs[@ref=$person-uri])
};

let $chapter := doc('/db/apps/usaybia-data/data/texts/tei/lhom-ar-10.xml')
let $person-records := collection('/db/apps/usaybia-data/data/persons/tei')
let $uri-index := $person-records/TEI/text/body/listPerson/person/idno[starts-with(.,'https://usaybia.net')]/text()

let $header := "URI;Name;Affiliations;Occurrences;Entry"

(: All persons occuring in given text  :)
let $rows := 
    for $person in local:get-uris($chapter)
        let $record := local:get-person($person,$person-records,$uri-index)
        let $affiliation1 := $record/state[@type='religious-affiliation'][1]/label
        let $affiliation2 := $record/state[@type='religious-affiliation'][2]/label 
        let $occurrences := local:occurrences($chapter, $person)
        let $entry := $record/bibl/citedRange[@ana='entry'][1]
        order by $occurrences descending
        return concat($person,";",$record/persName[1],";",$affiliation1,"/ ",$affiliation2,";",$occurrences,";",$entry)
return concat($header,"&#10;",string-join($rows,"&#10;"))

(: People who don't appear to have bio entries:
"https://usaybia.net/person/1252 , ʿĪsā ibn Usayd al-Naṣrānī , Christian , 3"
"https://usaybia.net/person/51 , ʿAbd Yashūʿ al-Jāthalīq , Christian, East Syriac , 1"
"https://usaybia.net/person/103 , Abū ʿAlī ibn al-Samḥ , Christian , 1"
"https://usaybia.net/person/2322 , Yūḥannā ibn ʿAbd al-Masīḥ, Abū ʿAlī , Christian , Christian , 1"
"https://usaybia.net/person/179 , Abū l-Ghiṭrīf al-Biṭrīq , Christian , 3"
"https://usaybia.net/person/733 , Elias of Nisibis , Christian , 1"
"https://usaybia.net/person/1219 , Iliyyāʾ al-Qass , Christian , Christian , 2"
"https://usaybia.net/person/2004 , al-Sanī al-Baʿlabakkī , Christian , 2" :)