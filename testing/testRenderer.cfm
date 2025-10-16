<cfscript>
/** 

Scratchpad for testing Flexmark parser

## Configuration

Each plugin has an equivalent testing file and expected result in the markdown folder.

## Usage

Define the tests to run, ensure there is a markdown source and expected result file and then preview.

*/

tests = ['definition','attributes','footnote','abbreviation','admonition','autolink','admonition'];

// we run all html through jsoup parse so we get a better comparison

jsoup = createObject( "java", "org.jsoup.Jsoup" );
flexmark = new markdown.flexmark(attributes="true",typographic=true);
sources = ExpandPath("sources/rendertests/");

for (test in tests) {
	
	mytext = FileRead(sources & "#test#.md","utf-8");
	myresult = jsoup.parse(trim(FileRead(sources & "/#test#.html","utf-8"))).body().html();
	start = getTickCount();
	
	outhtml = flexmark.toHtml(mytext);
	writeOutput("<div class='test'><h2>#test#</h2>");
	writeOutput("<pre>#htmlEditFormat(outhtml)#</pre>");
	writeOutput("<p>Should be</p>");
	writeOutput("<pre>#htmlEditFormat(myresult)#</pre>");
	writeOutput("</div>");
}
</cfscript>


