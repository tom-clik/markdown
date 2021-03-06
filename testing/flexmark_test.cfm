<!---

# flexmark test

Test Flexmark markdown parsing

## Usage

Configure and run Preview in browser

--->

<cfscript>
testPath = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
variables.inputFile  = "markdown_test_doc.md";

markdown = createObject("component","markdown.flexmark").init();

mytest = FileRead(testpath & variables.inputFile,"utf-8");
doc = markdown.markdown(mytest,{},testpath);

writeOutput("
<html>
<head>
  <meta charset=""UTF-8"">
</head>
<body>
");

// writeOutput("<pre>" & htmlEditFormat(doc.html) & "</pre>");

WriteOutput(doc.html);


writeOutput("</body></html>");

</cfscript>

<!--- <cfif IsDefined("request.log")>
<cfoutput>#request.log#</cfoutput>
</cfif> 