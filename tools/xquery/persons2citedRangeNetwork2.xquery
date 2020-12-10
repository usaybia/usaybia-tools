xquery version "3.0";
(:Use commented lines for exide:)
(:xquery version "3.1";:)

declare default element namespace 'http://www.tei-c.org/ns/1.0';

(:let $collection := collection('/db/apps/usaybianet/data/persons/tei/'):)
let $collection := collection('../../../usaybia-data/data/persons/tei/')
let $persons-all := $collection//person[1]

return $persons-all