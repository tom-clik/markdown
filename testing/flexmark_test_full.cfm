<!---

# flexmark test

Sample Flexmark markdown parsing using the more complex markdown method

## Usage

Configure and run Preview in browser

--->

<cfscript>
jsoupJarPath = server.system.environment.javalib & "\jsoup-1.20.1.jar";

testPath = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
variables.inputFile  = testPath & "markdown_test_doc.md";
variables.template  = testPath & "template_test.html";

flexmark = new markdown.flexmark(attributes="true",typographic=true,jsoupjar=variables.jsoupJarPath);

mytest = FileRead(variables.inputFile,"utf-8");
mytemplate = FileRead(variables.template,"utf-8");

meta = {};

doc = flexmark.markdown(mytest);

html = replace(mytemplate, "{$body}", doc.html);
html = flexmark.replaceVars(html, meta);

writeOutput(doc.data.meta.toc);
writeOutput(doc.html);


</cfscript>
