/*
# Wripper

Convert Word filtered "HTML" into Markdown.

## Usage

1. Save WORD doc as Web page (filtered)
2. Insttaniate component as singleton
3. Call wrip() method


## Synopsis

### 1. Strip rubbish

We start by stripping rubbish

1.1	Empty spans
	We have to convert &nbsp; to normal spaces for these. They are never in the right place.

1.2	Empty paras

### 2. Remove block tags

Now we convert our block tags, ensuring there's a double line at the end of them.

for each block tag (h1...6, p), strip the front, checking class. Check if there's an anchor inside it, then replace start and end, and add a double return at end.

### 3. Convert tables

Loop over each table.

Check if any row or col spans, if not, convert to tab format.

### 4. Whitespace and blocks

Firstly we remove all return chars from our document.

Then we convert the paragraphs and line endings to whitespace.

*/
component {

	public void function init() {
		
		// Jsoup helper class
		try {
			this.jsoup = new coldSoup.coldSoup();
		}
		catch (any e) {
			throw(message="Unable to create Jsoup object",detail="Wripper uses Jsoup to convert word html to markdown. Please ensure you have Jsoup included in your java class path
				and the coldSoup component in your component path.<br><br>#e.message#<br><br>#e.detail#");
		}
		
		// line endings
		this.cr = chr(13) & chr(10);

		// Class matcher
		// the classes "quote" and "blockquote" are converted to markdown quotes, overriding other classes. 
		// Classes in this set will also be matched
		this.paraClasses = {
			"msoQuote" = "quote",
			"MsoIntenseQuote" = "quote"
		};

		// debug text, trace, request (request.log) or file. 
		this.debugtype = "none";
		this.debugFile = "undefined";


	}
	/**

	Convert word html to markdown
	
	@htmlStr  		word html
	@footnotes  	attempt to parse footnotes
	@demote  		0 = none, 1 = h1->h2 etc
	@stripnums  	remove numbers from headings
	
	*/
	public function wrip(required string htmlStr, boolean footnotes=true,numeric demote=0,boolean stripnums=0) {

		var doc = this.jsoup.parse(htmlStr);

		local.formatTags = {"b" = "**", "strong" = "**", "i" = "_","em" = "_","code" = "`"};
		
		for (local.tag in local.formatTags) {
			local.nodes = doc.select(tag);
			for (local.node in local.nodes) {
				local.node.before(local.formatTags[local.tag]);
				local.node.after(local.formatTags[local.tag]);
				local.node.unwrap();
			}
		}

		local.emptyTags = ListToArray("p,span");

		for (local.tag in local.emptyTags) {
			local.nodes = doc.select(local.tag);
			for (local.node in local.nodes) {
			   local.tmptext = local.node.html();
			   local.tmptext = ReplaceNoCase(local.tmptext,"&nbsp;","","all");
			   if (trim(local.tmptext) eq "") {
				   local.node.after(" ");
				   local.node.remove();
			   }
			}
		}

		// guess footnotes from class
		if (arguments.footnotes) {
			local.footnotes = {};
			local.nodes = doc.select("p.MsoFootnoteText");
			for (local.node in local.nodes) {
				local.link = node.select("a").first();
				local.attrs = this.jsoup.getAttributes(local.link);
				local.link.remove();
				local.attrs.text = node.html();
				local.footnotes[attrs.name] = local.attrs;
				local.node.remove();
			}
		}

		// links 
		local.nodes = doc.select("a[href]");
		local.crossRefs = {};
		for (local.node in local.nodes) {
			local.attrs = this.jsoup.getAttributes(local.node);
			local.attrs.link_id = Replace(local.attrs.href,"##","");
			if (arguments.footnotes AND StructKeyExists(local.footnotes,   local.attrs.link_id)) {
				debug("Foot note # attrs.link_id# found<br>");
				local.linktext = "[^" & local.attrs.link_id & "]";
				node.parent().after("<p>[^# local.attrs.link_id#]: #local.footnotes[local.attrs.link_id].text#</p>");
			}
			else {
				debug("Foot note # attrs.link_id# not found<br>");
				local.linktext = "[" & local.node.text() & "](" & local.attrs.href & ")";
			   
				if (structKeyExists(local.attrs,"name")) {
					local.linktext &= "{: name=""#local.attrs.name#""}";
				}
				if (left(local.attrs.href ,1) eq "##") {
					local.crossRefs[ local.attrs.link_id] = 1;
				}
			}
			local.node.before(linktext);
			local.node.remove();
		   
		}


		// anchors 
		// 1. select orphans with no references (lots of them usually)
		// 2. Get parent tag and apply id to that

		local.nodes = local.doc.select("a[name]");
		for (local.node in local.nodes) {
			local.name = local.node.attr("name");
			if (structKeyExists(local.crossRefs,local.name)) {
				local.parent = local.node.parent();
				debug("Anchor outer html<br><br>" & parent.outerHtml());
				local.parent.attr("id",local.name);
			}
			
			local.node.unwrap();
		}


		// headings
		
		if (arguments.demote OR arguments.stripnums) {
			local.nodes = doc.select("h1,h2,h3,h4,h5,h6");
			for (local.node in local.nodes) {
				addAttributes(local.node,"id");
				local.level = Replace(local.node.tagName(),"h","");
				local.level = local.level + arguments.demote;
				local.class = "";
				if (local.level gt 6) {
					local.tag = "p";
					local.class = " class='h#local.level#'";
				}
				else {
					local.tag = "h#local.level#";
				}
				local.text =  Trim(local.node.html());
				if (arguments.stripnums) {
					local.text = ReReplace(local.text,"[\d\.]+\s","");
				}
				local.node.after("<#local.tag##local.class#>" & local.text & "</#local.tag#>");
				local.node.remove();
			}
		}



		// images 
		local.nodes = doc.select("img");
		for (local.node in local.nodes) {
				local.attrs = addAttributes(local.node);
				local.caption = "";
				if (structKeyExists(local.attrs,"alt")) {
					local.caption = local.attrs.alt;
				} else if (structKeyExists(local.attrs,"title")) {
					local.caption = local.attrs.title;
				}
				local.node.before("![" & local.caption & "](" & local.node.attr("src") & ")");
				local.node.remove();
		}

		// p inside tables -- can't cope with these.
		local.nodes = doc.select("td>p,th>p");
		for (local.node in local.nodes) {
			local.node.unwrap();
		}
		
		// parse tables but we can't put them back in until we' ve finished the rest of the processing
		// add placeholders {{$tableX}}
		local.nodes = doc.select("table");
		local.tablecount = 1;
		local.tables = {};
		for (local.node in local.nodes) {
			local.tables[local.tablecount] = parseTable(local.node);
			local.node.before("<p>{{$table#local.tablecount#}}</p>");
			local.tablecount += 1;
			local.node.remove();
		}


		// for lists start by making every item a list and then join them
		local.nodes = doc.select("p");
		for (local.node in local.nodes) {
			local.classname =  local.node.attr("class");
			if (FindNoCase("msolist",local.classname)) {
				if (FindNoCase("bullet",local.classname)) {
					local.listClass = "u";
				}
				else {
					local.listClass = "o";
				}
				local.emptyTags = ListToArray("p,span");
				local.spans = local.node.select("span");

				if (IsDefined("local.spans") && ArrayLen(local.spans)) {
					local.spans.first().remove();
				}

				local.node.after("<#local.listClass#l><#local.listClass#li>#local.node.html()#</#local.listClass#li></#local.listClass#l>").remove();
			}
		}

		local.nodes = doc.select("ul + ul, ol + ol");
		while (arrayLen(local.nodes)) {
			local.node = local.nodes.first();
		   
			local.previous = local.node.previousSibling();
			local.haveSibling = 0;
			while (not local.haveSibling) {
				 
				 if (NOT IsDefined("previous")) throw("wtf");

				 if (local.previous.getClass().getName() neq "org.jsoup.nodes.TextNode") {
					local.haveSibling = 1;
				 }
				 else {
					local.previous = local.previous.previousSibling();
				 }
			}
			local.content = local.previous.html();
			local.previous.html(local.content & local.node.html());
			local.node.remove();
			local.nodes = doc.select("ul + ul, ol + ol");
		}


		local.tags = doc.body();
		local.myData = parseTags(doc.body());

		// put the parsed tables back in.
		for (local.table in local.tables) {
			local.myData = Replace(local.myData,"{{$table#local.table#}}",local.tables[local.table]);
		}

		return local.myData;
			
	}

	/**
	 * Add attribute string after text in form { #id .class anything=value}
	 *
	 * Also returns the attributes as a struct.
	 * 
	 * @node jsoup Node to add attributes to  
	 * @attsToGet list of attributes to get. Blank = all
	 */
	public struct function addAttributes(required object node,string attsToGet="") {
		var attrs = this.jsoup.getAttributes(arguments.node);
		var attStr = "";
		for (var attr in attrs) {
			if (attrs[attr] neq "" AND (arguments.attsToGet eq "" OR ListFindNoCase(arguments.attsToGet,attr))) {
				switch (attr) {
					case "href":case "src":
						// ignore these
						break;
					case "id":
						attStr = ListAppend(attStr,"##" & attrs[attr], " ");
						break;
					case "class":
						attStr = ListAppend(attStr,"." & attrs[attr], " ");
						break;
					default:
						attStr = ListAppend(attStr,attr & "='" & attrs[attr] & "'", " ");
				}
			}
		}
		
		if (attStr neq "") {
			arguments.node.append(" { #attStr#}");
		}

		return attrs;
	}


	/**
	 * Parse all child nodes and convert to markdown
	 * 
	 * @param  tag   jsoup node
	 * @return markdown formatted string
	 */
	private string function parseTags(tag) {
		
		var myData = "";
		var myTag = false;

		for (myTag in arguments.tag.childnodes()) {
			
			if (myTag.getClass().getName() eq "org.jsoup.nodes.TextNode"){
				myData &= myTag.text();

			}
			else {
				
				if (isBlock(myTag.tagName())) {
					myData &= this.cr & this.cr;
				} 
				else if (isLine(myTag.tagName())) {
					myData &= this.cr;
				}
				
				local.classList = myTag.attr("class");
				local.class = "";

				for (local.i in ListToArray(local.classList," ")) {
					if (StructKeyExists(this.paraClasses ,local.i)) {
						local.class = this.paraClasses[local.i];
					}
				}

				myData &= openTag(myTag.tagName(),local.class);

				try {
					if (ArrayLen(myTag.childNodes())) {
						myData &= parseTags(myTag);
					}
				}
				catch (Exception e) {
					savecontent variable="local.temp" {
						 WriteDump(myTag);
					}
					throw(message="unable to parse tags",detail="#local.temp#");
				   
				}

				// reserved 
				//myData &= closeTag(myTag.tagName(),local.class);

			}
		}
		return myData;
	}

	/**
	 * @hint      is the tag a block element?
	 *
	 * @mytag  The tag
	 *
	 * @return     True if the specified mytag is block, False otherwise.
	 */
	private boolean function isBlock(mytag) {
		var i=0;
		switch (arguments.mytag) {
			case "p":
			case "h1":
			case "h2":
			case "h3":
			case "h4":
			case "h5":
			case "h6":
			case "table":
			i = 1;
			break;

		}
		return i;
	}

	/**
	 * @hint      is the tag a line element?
	 *
	 * @mytag  The tag
	 *
	 * @return     True if the specified mytag is a line, False otherwise.
	 */
	private boolean function isLine(mytag) {
		var i=0;
		switch (arguments.mytag) {
			case "br":
			case "tr":
			case "li":
			case "uli":
			case "oli":
			case "ul":
			case "ol":
			i = 1;
			break;
		}
		return i;
	}

	/**
	 *
	 * Add opening tag for markdown e.g. # for h1
	 *
	 * @mytag  The tag name
	 * @class  The class
	 *
	 */
	private string function openTag(mytag,class="") {
		var i="";
		switch (arguments.mytag) {
			case "h1":
				return "## ";
				break;
			case "h2":
				return "#### ";
				break;
			case "h3":
				return "###### ";
				break;
			case "h4":
				return "######## ";
				break;
			case "h5":
				return "########## ";
				break;
			case "h6":
				return "############ ";
				break;

			case "p":
				
				switch (arguments.class) {
					case "code":
						return "    ";
						break;
					case "quote":case "blockquote":
						return "> ";
						break;    
				}

				break;
						
			case "uli":
				return "* ";
				break;    

			 case "oli":
				return "1. ";
				break;
		}
		return i;
	}

	// Close a tag with attibute syntax { #id .class}
	private string function closeTag(mytag,class="") {

		var retVal = "";

		if (arguments.class != "") {
			retVal &= "{ ."	& arguments.class & "}";
		}

		return retVal;

	}
	

	/**
	* Fixes text using Microsoft Latin-1 &quot;Extentions&quot;, namely ASCII characters 128-160.
	*
	* @text      Text to be modified. (Required)
	* @return Returns a string.
	* @author Shawn Porter (sporter@rit.net)
	* @version 1, June 16, 2004
	*/
	public string function DeMoronize (textin) {
		var i = 0;
		var text = arguments.textin;
		// map incompatible non-ISO characters into plausible
		// substitutes
		text = Replace(text, Chr(128), "&euro;", "All");

		text = Replace(text, Chr(130), ",", "All");
		text = Replace(text, Chr(131), "<em>f</em>", "All");
		text = Replace(text, Chr(132), ",,", "All");
		text = Replace(text, Chr(133), "...", "All");
			
		text = Replace(text, Chr(136), "^", "All");

		text = Replace(text, Chr(139), ")", "All");
		text = Replace(text, Chr(140), "Oe", "All");

		text = Replace(text, Chr(145), "`", "All");
		text = Replace(text, Chr(146), "'", "All");
		text = Replace(text, Chr(147), """", "All");
		text = Replace(text, Chr(148), """", "All");
		text = Replace(text, Chr(149), "*", "All");
		text = Replace(text, Chr(150), "-", "All");
		text = Replace(text, Chr(151), "--", "All");
		text = Replace(text, Chr(152), "~", "All");
		text = Replace(text, Chr(153), "&trade;", "All");

		text = Replace(text, Chr(155), ")", "All");
		text = Replace(text, Chr(156), "oe", "All");

		// remove any remaining ASCII 128-159 characters
		for (i = 128; i LTE 159; i = i + 1) {
			text = Replace(text, Chr(i), "", "All");
		}

		// map Latin-1 supplemental characters into
		// their &name; encoded substitutes
		//text = Replace(text, Chr(160), "&nbsp;", "All"); see below word uses these for anything

		text = Replace(text, Chr(163), "&pound;", "All");

		text = Replace(text, Chr(169), "&copy;", "All");

		text = Replace(text, Chr(176), "&deg;", "All");

		// encode ASCII 160-255 using &#999; format
		for (i = 160; i LTE 255; i = i + 1) {
			text = REReplace(text, "(#Chr(i)#)", "&###i#;", "All");
		}
		
		// supply missing semicolon at end of numeric entities
		text = ReReplace(text, "&##([0-2][[:digit:]]{2})([^;])", "&##\1;\2", "All");
		
		// fix obscure numeric rendering of &lt; &gt; &amp;
		text = ReReplace(text, "&##038;", "&amp;", "All");
		text = ReReplace(text, "&##060;", "&lt;", "All");
		text = ReReplace(text, "&##062;", "&gt;", "All");

		// supply missing semicolon at the end of &amp; &quot;
		text = ReReplace(text, "&amp(^;)", "&amp;\1", "All");
		text = ReReplace(text, "&quot(^;)", "&quot;\1", "All");
		text = ReReplace(text, "<BR>","", "all");

		return text;
	}

	/**
	 * @hint     parse a table into a markdown format with nicely spaced rows
	 *
	 * @tableNode  Jsoup node
	 *
	 * @return    markdown table
	 */
	public string function parseTable(tableNode) {

		var rowData = ArrayNew(1);
		var rows = arguments.tableNode.select("tr");
		var text = "";
		var row = false;
		var cells = false;
		var celldata = false;
		var cell = false;
		var maxWidths = {};
		var headerRow = arguments.tableNode.select("th");
		var colnum = false;
		var rownum = 1;
		
		// parse cells in to array of arrays
		for (row in rows) {
		   
		   cells = row.select("td,th");
		   celldata = ArrayNew(1);
		   
		   for (cell in cells) {
		   	   
			   ArrayAppend(celldata,Trim(cell.text()));
			   colnum = ArrayLen(celldata);
			  	
			   // for nice formatting, caclulate max width of column
			   if (NOT structKeyExists(maxWidths, colnum) OR  maxWidths[colnum] lt Len(celldata[colnum])) {
					maxWidths[colnum] = Len(celldata[colnum]);
			   }
		   }

		   ArrayAppend(rowData,celldata);

		}
		
		// write out markdown table
		rownum = 1;
		for (row in rowData) {

			// write out divider
			if (rownum eq 2) {
				for (colnum = 1; colnum <= ArrayLen(row); colnum++) {
					text &= "|" & repeatString("-",maxWidths[colnum]);
				}
				text &= this.cr;
			}
			
			for (colnum = 1; colnum <= ArrayLen(row); colnum++) {
				text &= "|";
				if (maxWidths[colnum] gt 0) {
					 text &= LJustify(row[colnum], maxWidths[colnum]);
				}
				else {
					text &= row[colnum];
				}
				
			}

			text &= this.cr;
			rownum += 1;
		}

		return text;
	}

	private void function debug(debugText) {
		switch (this.debugtype) {
			case "text":
				WriteOutput(arguments.debugText);
				break;
			case "request":
				param name="request.log" default="";
				request.log &= arguments.debugText;
				break;
			case "trace":
				Trace(text=arguments.debugText);
				break;
			case "file":
				try {
					fileAppend(this.debugFile, arguments.debugText);
				}
				catch(any e) {
					throw(message="unable to write to debug log",detail=e.message & e.detail);
				}
				break;

		}
	}

}


