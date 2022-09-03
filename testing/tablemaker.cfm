<!--- 

# tablemaker

Make nice markdown tables from tabbed or csv text

## Usage

Ad hoc script demonstrating table make.

## Author

Tom Peer tom@clik.com

--->

<cfscript>

fileIn  = ExpandPath("testing/sources/checkov_plays.md");
fileOut = Replace(ListLast(fileIn,"\/"),".md","_out.md");
dirOut  = ExpandPath("testing/_out/");

patternObj   = createObject( "java", "java.util.regex.Pattern" );
parapattern  = patternObj.compile("(\r\n){2,}",patternObj.MULTILINE);
brpattern    = patternObj.compile(" *\r\n *",patternObj.MULTILINE);
fixpattern   = patternObj.compile("\<p\>",patternObj.MULTILINE);

myData = FileRead(fileIn,"utf-8");

myData = parapattern.matcher(myData).replaceAll("<p>");
myData = brpattern.matcher(myData).replaceAll(" ");
myData = fixpattern.matcher(myData).replaceAll(chr(13) & chr(10) & chr(13) & chr(10));

FileWrite(dirOut & fileOut, myData, "utf-8");

WriteOutput("File converted");

</cfscript>
