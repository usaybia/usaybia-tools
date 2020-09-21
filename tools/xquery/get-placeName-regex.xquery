xquery version "3.0";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $placeName-docs := collection("../../../usaybia-data/data/places/tei/?select=*.xml")
let $placeNames := 
    for $placeName in $placeName-docs/TEI/text/body/listPlace/place/placeName
    let $idno := $placeName/../idno[@type='URI' and starts-with(.,'https://usaybia.net')]
    return element placeName {attribute ref {$idno}, $placeName/text()}

return $placeNames