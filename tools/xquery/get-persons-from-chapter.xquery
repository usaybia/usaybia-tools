xquery version "3.1";

declare default element namespace 'http://www.tei-c.org/ns/1.0';
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function local:get-uris($text as node()) as xs:string* {
    distinct-values($text//(persName|rs)/@ref)
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

(: All persons occuring in given text  :)
for $person in local:get-uris($chapter)
    let $record := local:get-person($person,$person-records,$uri-index)
    let $affiliation := $record/state[@type='religious-affiliation']/label
    return
        if (matches(string-join($affiliation),'[Cc]hristian')) then
            string-join(($person,$record/persName[1],$affiliation,local:occurrences($chapter, $person))," , ")
        else ()

(: People who don't appear to have bio entries:
"https://usaybia.net/person/1252 , ʿĪsā ibn Usayd al-Naṣrānī , Christian , 3"
"https://usaybia.net/person/51 , ʿAbd Yashūʿ al-Jāthalīq , Christian, East Syriac , 1"
"https://usaybia.net/person/103 , Abū ʿAlī ibn al-Samḥ , Christian , 1"
"https://usaybia.net/person/2322 , Yūḥannā ibn ʿAbd al-Masīḥ, Abū ʿAlī , Christian , Christian , 1"
"https://usaybia.net/person/179 , Abū l-Ghiṭrīf al-Biṭrīq , Christian , 3"
"https://usaybia.net/person/733 , Elias of Nisibis , Christian , 1"
"https://usaybia.net/person/1219 , Iliyyāʾ al-Qass , Christian , Christian , 2"
"https://usaybia.net/person/2004 , al-Sanī al-Baʿlabakkī , Christian , 2" :)