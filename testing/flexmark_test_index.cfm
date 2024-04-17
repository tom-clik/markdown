<!---

# flexmark test


## Usage

Configure and run Preview in browser

--->

<cfscript>

flexmark = new markdown.flexmark(attributes="true",typographic=true);

doc = flexmark.readIndex("C:\git\dm\thedigitalmethod\index_test.md");

// html = replace(mytemplate, "{$body}", doc.html);
// html = flexmark.replaceVars(html, doc.data.meta);
// writeDump(doc.data);
// writeDump(html);

writeOutput("<pre>" & HTMLEditFormat( doc.html ) & "</pre>");


</cfscript>
