<!--- 

# linebreaker

read in plain text files with single line breaks in the middle of sentences and convert them to wrapped format

## Background

Flexmark can be initialised with softbreak functionality. This is often useful and my preferrred way of working.

This file will crudely convert files with wrapped lines into a soft-break compatible one.

## Synopsis

1. Match every multiple line and replace break with <p>
2. Join every remaining line break
3. Replace the <p> tags with double returns

## Usage

Ad hoc script to run when you like.

## Author

Tom Peer tom@clik.com

## License

Copy it, claim you wrote it, do what you like.

--->

<cfscript>

fileIn = ExpandPath("testing/sources/checkov_plays.md");
fileOut = Replace(ListLast(fileIn,"\/"),".md","_out.md");
dirOut = ExpandPath("testing/_out/");

patternObj = createObject( "java", "java.util.regex.Pattern" );
parapattern = patternObj.compile("(\r\n){2,}",patternObj.MULTILINE);
brpattern = patternObj.compile(" *\r\n *",patternObj.MULTILINE);
fixpattern = patternObj.compile("\<p\>",patternObj.MULTILINE);

myData = FileRead(fileIn,"utf-8");

myData = parapattern.matcher(myData).replaceAll("<p>");
myData = brpattern.matcher(myData).replaceAll(" ");
myData = fixpattern.matcher(myData).replaceAll(chr(13) & chr(10) & chr(13) & chr(10));

FileWrite(dirOut & fileOut, myData, "utf-8");

WriteOutput("File converted");

</cfscript>
