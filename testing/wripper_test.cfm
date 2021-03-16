<!---

# Wipper test

Test Wirpper Word HTML to markdown markdown

## Usage


--->

<cfscript>
testPath = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
fileIn  = "wripper_test_doc2.htm";
fileOut = Replace(ListLast(fileIn,"\/"),ListLast(fileIn,"."),"md");
dirOut = ExpandPath("_out/");


wripperObj = createObject("component","markdown.wripper");

mytest = FileRead(testpath & fileIn,"utf-8");
doc = wripperObj.wrip(mytest);

filePathOut = dirOut & fileOut;
FileWrite(dirOut & fileOut, doc, "utf-8");

writeOutput("File written to #filePathOut#");

</cfscript>
