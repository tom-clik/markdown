<!---

# Wipper test

Test Wripper Word HTML to markdown conversion

## Usage

1. Install [ColdSoup](https://github.com/tom-clik/coldsoup) and ensure you have a modern version of [JSOUP](https://jsoup.org/download) ready to use
1. Configure hard wired paths
2. Preview in browser.

--->

<cfscript>
/********************************************
 * Config 
 * ******************************************/
// Path to JSOUP jar
jsoupJarPath = server.system.environment.javalib & "\jsoup-1.20.1.jar";
// Input file 
fileIn  = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\wripper_test_doc2.htm";
// output file
fileOut   = ExpandPath("_out/") & Replace(ListLast(fileIn,"\/"),ListLast(fileIn,"."),"md");
/*********************************************/

dirOut    = getDirectoryFromPath(fileOut);

if (! DirectoryExists(dirOut)) {
	try {
		DirectoryCreate(dirOut);
	}
	catch (any e) {
		throw(
			message      = "Unable to create output directory data #dirOut#:" & e.message, 
			detail       = e.detail,
			errorcode    = "wripper_test.1"		
		);
	}
}

try {
	wripperObj = new markdown.tools.wripper(jsoupJarPath);
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

try {
	wripperObj.loggerObj = new logger.logger(debug=true);
	showLog = 1;
}
catch (any e) {
	showLog = 0;
}

try {  
	mytest = FileRead(fileIn,"utf-8");
}
catch (any e) {
	throw(
		message      = "Unable to read input file #fileIn#:" & e.message, 
		detail       = e.detail,
		errorcode    = "wripper_test.3"		
	);
}

doc = wripperObj.wrip(mytest);

try {
	FileWrite(fileOut, doc, "utf-8");
}
catch (any e) {
	throw(
		message      = "Unable to save file to #fileOut#:" & e.message, 
		detail       = e.detail,
		errorcode    = "wripper_test.4"		
	);
}

writeOutput("File written to #fileOut#");
WriteOutput("<pre>#doc#</pre>");

if (showLog) {
	wripperObj.loggerObj.viewLog();
}


</cfscript>
