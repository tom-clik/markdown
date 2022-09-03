<!--- 

# tablemaker

Make nice markdown tables from tabbed or csv text

## Usage

Ad hoc script demonstrating table make.

## Author

Tom Peer tom@clik.com

--->

<cfscript>

fileIn  = ExpandPath("sources/tableTest.txt");
fileOut = Replace(ListLast(fileIn,"\/"),".txt","_out.md");
dirOut  = ExpandPath("_out/");

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
	mytest = FileRead(fileIn,"utf-8");
}
catch (any e) {
	throw(
		message      = "Unable to read input file #fileIn#:" & e.message, 
		detail       = e.detail,
		errorcode    = "wripper_test.3"		
	);
}

mytest = wripperObj.parseTextTable(mytest);

FileWrite(dirOut & fileOut, mytest, "utf-8");

WriteOutput("File converted to " & dirOut & fileOut);

</cfscript>
