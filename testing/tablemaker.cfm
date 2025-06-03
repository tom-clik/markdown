<!--- 

# tablemaker

Make nice markdown tables from tabbed or csv text

## Usage

Ad hoc script demonstrating table make.

## Author

Tom Peer tom@clik.com

--->

<cfscript>
// Path to JSOUP jar
jsoupJarPath = server.system.environment.javalib & "\jsoup-1.20.1.jar";
fileIn  = ExpandPath("sources/tableTest.txt");
fileOut = ExpandPath("_out/") & Replace(ListLast(fileIn,"\/"),".txt","_out.md");

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

wripperObj.debugtype = "text";
try {  
	txt = FileRead(fileIn,"utf-8");
}
catch (any e) {
	throw(
		message      = "Unable to read input file #fileIn#:" & e.message, 
		detail       = e.detail,
		errorcode    = "wripper_test.3"		
	);
}

md = wripperObj.parseTextTable(txt);

FileWrite( fileOut, md, "utf-8");

WriteOutput("File converted to " & fileOut);
WriteOutput("<pre>#md#</pre>");

</cfscript>
