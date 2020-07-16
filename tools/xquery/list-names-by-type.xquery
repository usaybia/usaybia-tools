declare default element namespace "http://www.tei-c.org/ns/1.0";

for $persName in //persName
let $shuhra := $persName/addName[@type='shuhra'][1]/string()
let $given := $persName/forename[1]/string()
let $kunya := $persName/addName[@type='kunya'][1]/string()
let $ref := string-join($persName/preceding::p[hi[matches(.,'\[\d+')]][1]/hi[matches(.,'\[\d+')][1]/string())
let $ref-replaced := replace($ref,'\n',' ')
let $row := concat($shuhra,',',$given,',',$kunya,',',$persName/string(),',',$ref-replaced)
order by $persName/string() ascending
return concat($row,'
')