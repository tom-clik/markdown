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
		throw(
			message      = "Unable to create outpur directory data #dirOut#:" & e.message, 
			detail       = e.detail,
			errorcode    = "wripper_test.1"		
		);
	}
}

try {
	wripperObj = new markdown.wripper();
}
catch (any e) {
	local.extendedinfo = {"tagcontext"=e.tagcontext};
	throw(
		extendedinfo = SerializeJSON(local.extendedinfo),
		message      = "Unable to create wripper opject:" & e.message, 
		detail       = e.detail,
		errorcode    = "wripper_test.2"		
	);
}

wripperObj.debugtype = "text";

try {  
	mytest = FileRead(testpath & fileIn,"utf-8");
}
catch (any e) {
	throw(
		message      = "Unable to read input file #testpath#:" & e.message, 
		detail       = e.detail,
		errorcode    = "wripper_test.3"		
	);
}

doc = wripperObj.wrip(mytest);

filePathOut = dirOut & fileOut;

try {
	FileWrite(dirOut & fileOut, doc, "utf-8");
}
catch (any e) {
	throw(
		message      = "Unable to save file to #filePathOut#:" & e.message, 
		detail       = e.detail,
		errorcode    = "wripper_test.4"		
	);
}

writeOutput("File written to #filePathOut#");

</cfscript>
