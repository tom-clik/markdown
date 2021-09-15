<!---

# Wipper test

Test Wripper Word HTML to markdown markdown

## Usage

1. Configure hard wired paths
2. Preview in browser.


--->

<cfscript>
testPath  = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
fileIn    = "wripper_test_doc2.htm";
fileOut   = Replace(ListLast(fileIn,"\/"),ListLast(fileIn,"."),"md");
dirOut    = ExpandPath("_out/");

if (! DirectoryExists(dirOut)) {
	try {
		DirectoryCreate(dirOut);
	}
	catch (any e) {
		WriteOutput("Unable to create output directory #dirOut#");
		writeDump(e);
		abort;
	}
}

wripperObj = new markdown.wripper();
wripperObj.debugtype = "text";

mytest = FileRead(testpath & fileIn,"utf-8");
doc = wripperObj.wrip(mytest);

filePathOut = dirOut & fileOut;

try {
	FileWrite(dirOut & fileOut, doc, "utf-8");
}
Catch (any e) {
	WriteOutput("Unable to save file to #filePathOut#");
	writeDump(e);
	abort;	
}
writeOutput("File written to #filePathOut#");

</cfscript>
