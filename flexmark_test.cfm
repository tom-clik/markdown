<!---

# flexmark test

Test Flexmark markdown parsing

## Usage

Preview in browser

http://localhost/customtags/markdown/flexmark_test.cfm

--->

<cfscript>
testpath = "";

variables.inputFile  = "D:\clik\dm\ClikWriter\PrinceXML\PrinceXMLCheatsheet.md";

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

WriteOutput("<pre>" & htmlEditFormat(doc.html) & "</pre>");

WriteOutput("</body></html>");

</cfscript>

<!--- <cfif IsDefined("request.log")>
<cfoutput>#request.log#</cfoutput>
</cfif> 