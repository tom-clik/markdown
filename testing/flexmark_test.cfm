<!---

# flexmark test

Sample Flexmark markdown parsing using the simple toHTML method

## Usage

Configure and run Preview in browser

--->

<cfscript>
testPath = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
variables.inputFile  = testPath & "markdown_test_doc.md";
variables.template  = testPath & "template_test.html";

flexmark = new markdown.flexmark(jarpath="C:\dev\java\flexmark-all-0.64.0-lib.jar",attributes="true",typographic=true);

mytest = FileRead(variables.inputFile,"utf-8");
mytemplate = FileRead(variables.template,"utf-8");

meta = {};

timer type="inline" {
	html = flexmark.toHtml(mytest,meta);
}

// Hack for admonition styling -- needed to hide the SVGs (it uses the `use` mechanism)
writeOutput("<style>.adm-hidden {display:none}</style>");

meta.body = html;
meta.toc = "<p>TOC goes here in full version</p>";

html = flexmark.replaceVars(html, meta);

writeOutput(html);

writeDump(var=meta,label="Meta data");

</cfscript>
