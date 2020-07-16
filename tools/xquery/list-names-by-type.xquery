declare default element namespace "http://www.tei-c.org/ns/1.0";
for $persName-shuhra in //persName[addName/@type='shuhra']
order by $persName-shuhra/addName[@type='shuhra'][1] ascending
return concat($persName-shuhra/addName[@type='shuhra'][1],': ',$persName-shuhra/string(),'
')
,

for $persName-forename in //persName[forename and not(addName[@type='shuhra'])]
order by $persName-forename/forename[1] ascending
return concat($persName-forename/string(),'
')
,
for $persName in //persName[not(forename) and not(addName[@type='shuhra'])]
order by $persName/string() ascending
return concat($persName/string(),'
')