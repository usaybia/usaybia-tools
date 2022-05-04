declare namespace dc = "http://purl.org/dc/elements/1.1/"; 
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace bib = "http://purl.org/net/biblio#";
declare namespace foaf = "http://xmlns.com/foaf/0.1/";

for $tag in distinct-values(//dc:subject[matches(.,'!(Author|Person|Translator): ')]/normalize-space(replace(.,'!(Author|Person|Translator): (.*)','$2')))
let $bibl := /rdf:RDF/bib:*[descendant::dc:subject[matches(., concat('!(Author|Person|Translator): ',$tag))]][1]
let $author := $bibl/bib:*[1]/rdf:Seq/rdf:li[1]/foaf:Person/foaf:surname
let $title := $bibl/dc:title
let $ref := concat($author,', ',$title)

order by $tag

return concat($tag,'|',$ref, '
')