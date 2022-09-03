<!---

# flexmark test

Sample Flexmark markdown parsing

## Usage

Configure and run Preview in browser

--->

<cfscript>
testPath = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
variables.inputFile  = "markdown_test_doc.md";

flexmark = new markdown.flexmark();

mytest = FileRead(testpath & variables.inputFile,"utf-8");

doc = flexmark.markdown(mytest,{},testpath);

writeDump(doc.meta);

writeOutput("
<html>
<head>
  <meta charset=""UTF-8"">
</head>
<body>
");

WriteOutput(doc.html);

writeOutput("</body></html>");

</cfscript>
