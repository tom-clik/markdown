<!---

# flexmark test

Sample Flexmark markdown parsing using the 

## Usage

Configure and run Preview in browser

--->

<cfscript>
testPath = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
variables.inputFile  = testPath & "markdown_test_doc.md";
variables.template  = testPath & "template_test.html";

flexmark = new markdown.flexmark(attributes="true",typographic=true);

mytest = FileRead(variables.inputFile,"utf-8");
mytemplate = FileRead(variables.template,"utf-8");

meta = {};

html = flexmark.toHtml(mytest,meta);

html = replace(mytemplate, "{$body}", html);
html = flexmark.replaceVars(html, meta);

writeOutput(html);

writeDump(var=meta,label="Meta data");

</cfscript>
