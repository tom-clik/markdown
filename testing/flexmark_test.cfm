<!---

# flexmark test

Sample Flexmark markdown parsing

## Usage

Configure and run Preview in browser

--->

<cfscript>

testPath = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
variables.inputFile  = "markdown_test_doc.md";
variables.template  = "template_test.html";

flexmark = new markdown.flexmark();

mytest = FileRead(testpath & variables.inputFile,"utf-8");
mytemplate = FileRead(testpath & variables.template,"utf-8");

doc = flexmark.markdown(mytest,{},testpath);


html = replace(mytemplate, "{$body}", doc.html);
html = flexmark.replaceVars(html, doc.meta);
// writeDump(doc.meta);

writeOutput(html);

</cfscript>
