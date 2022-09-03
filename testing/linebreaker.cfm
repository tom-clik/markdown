<!--- 

test linebreaker method of Wripper

--->

<cfscript>

fileIn  = ExpandPath("sources/checkov_plays.md");
fileOut = Replace(ListLast(fileIn,"\/"),".md","_out.md");
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

mytest = wripperObj.lineBreaker(mytest);

FileWrite(dirOut & fileOut, mytest, "utf-8");

WriteOutput("File converted to " & dirOut & fileOut);

</cfscript>
