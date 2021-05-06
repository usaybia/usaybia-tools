xquery version "3.0";

declare default element namespace "http://www.tei-c.org/ns/1.0";

(:let $collection := doc("../../../usaybia-data/data/persons/tei/1.xml"):)
let $collection := collection("../../../usaybia-data/data/persons/tei/")

for $person in $collection
return $person/TEI/teiHeader/fileDesc/publicationStmt/idno