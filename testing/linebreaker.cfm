<!--- 

test linebreaker method of Wripper

--->

<cfscript>
// Path to JSOUP jar
jsoupJarPath = server.system.environment.javalib & "\jsoup-1.20.1.jar";
fileIn  = ExpandPath("sources/checkov_plays.md");
fileOut =  ExpandPath("_out/") & Replace(ListLast(fileIn,"\/"),".md","_out.md");

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

FileWrite( fileOut, mytest, "utf-8");

WriteOutput("File converted to " & fileOut);

</cfscript>
