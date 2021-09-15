/**

@hint Process markdown with Flexmark and generate meta data 

## Background

Uses https://github.com/vsch/flexmark-java

We have created a simple class to allow for creation of a parser with common modules available.

See java/Flexmark.java for the source or just place Flexmark.jar into your app's java path.

You can then just use it directly (see notes) or use this component which wraps it into a CFML component.

## Usage

The flexmark class takes a comma separated list of options from the following (or all of these if omitted or = "all"):

tables
abbreviation
admonition
anchorlink
attributes
autolink
definition
emoji
escapedcharacter
footnote
strikethrough
softbreaks

## Notes

If you just want to parse markdown, you don't need this component. Just use the flexmark
java class e.g. 
	
    variables.markdown = createObject( "java", "Flexmark" ).init();
	variables.markdown.render(text);

## Synopsis



## History


	
*/

component name="flexmark" {

	public function init() {
	
		this.cr = chr(10);
		
		this.coldsoup = createObject( "component", "coldsoup.coldSoup" ).init();

		variables.markdown = createObject( "java", "Flexmark").init();

		this.patternObj = createObject( "java", "java.util.regex.Pattern" );
		this.alphapattern = this.patternObj.compile("(?m)^@[\w\[\]]+\.?\w*\s+.+?\s*$",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);
		this.varpattern = this.patternObj.compile("(?m)\{\$\w*\_\w*\}",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);
			
		
		return this;
	
	}

	/**
	 *
	 * @Text  Text to process
	 * @options  Options
	 * @baseurl  Deprecated, use baseurl in options
	 *
	 */
	public struct function markdown (required string text, struct options, string baseurl) {
		
		var doc = {"meta" = {},"baseurl"=""};

		if (IsDefined("arguments.options")) {
			StructAppend(doc,arguments.options);
		}

		// legacy individual option.
		if (IsDefined("arguments.baseurl")) {
			doc.baseurl = arguments.baseurl;
		}

		doc.text = arguments.text;
		doc.baseurl=Replace(doc.baseurl,"\","/","all");
		
		// add trailing slash to all baseurls
		// NB it's completely legit not to pass baseurl and to omit http:// from the path
		// this is how it used to work. It will treat all URLs as full urls.
		if (doc.baseurl neq "" AND right(doc.baseurl,1) neq "/") doc.baseurl &= "/";

		arguments.text = alphameta(arguments.text,doc.meta);
		doc.html = variables.markdown.render(arguments.text);

		addmeta(doc);

		doc.html = replaceVars(doc.html, doc.meta);
		
		return doc;

	}

	/** 
	 * @hint Add single line @var  references to meta data and remove them
	 * @text mark down text
	 * @meta doc meta data
	 
	 */
	public string function alphameta(required string text, required struct meta) {
		
		var tags = [];
		var str = false;

		local.sectionsObj = this.alphapattern.matcher(arguments.text); 
		
		while (local.sectionsObj.find()){
		    ArrayAppend(tags, local.sectionsObj.group());
		    // writeOutput("<br>" & local.sections.group() & "<br>");
		}

		local.dodgyVarsToReplace = {}; 
		local.dodgyVars = this.varpattern.matcher(arguments.text); 
		while (local.dodgyVars.find()){
			local.dodgyVarsToReplace[local.dodgyVars.group()] =1;
		}
		for (str in local.dodgyVarsToReplace) {
			local.replaceStr = Replace(str,"_","%%varUndrscReplace%%","all");
			arguments.text = Replace(arguments.text,str,local.replaceStr,"all");	
		}
		

		//writeDump(tags);
		
		for (str in tags) {
			//split on first whitespace
			local.trimStr = Trim(str);
			local.tag = ListFirst(local.trimStr," 	");
			local.data = ListRest(local.trimStr," 	");
			local.tagRoot = ListFirst(local.tag,"@.[]");
			if (ListLen(local.tag,"@.") gt 1) {
				local.tagProperty = ListRest(local.tag,"@.");
				if (NOT structKeyExists(arguments.meta,local.tagRoot)) {
					arguments.meta[local.tagRoot] = {};
				}
				if (NOT isStruct(arguments.meta[local.tagRoot])) {
					throw('You have tried to assign a property a value that is not an struct [#local.tag#]')
				}
				arguments.meta[local.tagRoot][local.tagProperty] = local.data;
			}
			else {
				if (right(local.tag,2) eq "[]") {
					if (NOT structKeyExists(arguments.meta,local.tagRoot)) {
						arguments.meta[local.tagRoot] = [];
					}
					if (NOT isArray(arguments.meta[local.tagRoot])) {
						throw('You have tried to append array data to a value that is not an array [#local.tag#]')
					}
					ArrayAppend(arguments.meta[local.tagRoot],local.data);
				}
				else {
					arguments.meta[local.tagRoot] = local.data;
				}
			}
			arguments.text = Replace(arguments.text,str,"",1);
		}

		return arguments.text;
			
	}

	public string function replaceVars(html,data) {
		
		//get around problem of extra p surrounding toc
		arguments.html = REReplace(arguments.html,"\s*\<p[^>]*?\>\s*(\{\$toc\}\s*)\<\/p\>","\1");
		
		arguments.html = REReplace(arguments.html,"%%varUndrscReplace%%","_","all");

		local.arrVarNames = REMatch("\{\$[^}]+\}",arguments.html);
		local.sVarNames = {};
		// writeDump(local.arrVarNames);
		// create lookup struct of all vars present in text. Only defined ones are replaced.
		for (local.i in local.arrVarNames) {
			local.varName = ListFirst(local.i,"{}$");
			// syntax with e.g. meta.title not brilliant to work with
			if (ListLen(local.varName,".") gt 1) {
				if (IsDefined("arguments.data.#local.varName#")) {
					local.sVarNames[local.varName] = arguments.data[ListFirst(local.varName,".")][ListLast(local.varName,".")];
				}
			}
			else {
				if (structKeyExists(arguments.data, local.varName)) {
					local.sVarNames[local.varName] = arguments.data[local.varName];
				}
			}
		}
		
		for (local.varName in local.sVarNames) {
			// possible problem with referencing complex values.
			if (isSimpleValue(local.sVarNames[local.varName])) {
				arguments.html = ReplaceNoCase(arguments.html,"{$#local.varName#}", local.sVarNames[local.varName],"all");
			}
		}

		return arguments.html;
		
	}

	
	public void function addmeta(required struct document) {
		
		local.node = this.coldsoup.parse(arguments.document.html);

		if (NOT structKeyExists(arguments.document,"meta")) {
			arguments.document.meta = {};
		}

		// meta.meta is html meta tags
		if (NOT structKeyExists(arguments.document.meta,"meta")) {
			arguments.document.meta.meta = {};
		}

		// notoc is list of jsoup selectors to apply "notoc" class
		if (StructKeyExists(arguments.document.meta,"notoc")) {
			if (NOT IsArray(arguments.document.meta.notoc)) {
				local.toc = ListToArray(arguments.document.meta.notoc);
			}
			else {
				local.toc = arguments.document.meta.notoc;
			}
			
			for (var notocrule in local.toc) {
				
				local.notocnodes = arguments.sNode.select(Trim(notocrule));
				
				for (var local.notocNode in local.notocnodes) {
					local.notocNode.addClass("notoc");
				}
			}
		}

		var headers = local.node.select("h1,h2,h3,h4");
		var idList = [];
		for (var header in headers) {
			
			// this gets overridden in flexmark if auto headers is on. See next
			local.id = header.id();
			
			// generate id from header text NB flexmark places the id in to the <a> child tag
			local.anchor = header.select("a");
			if (IsDefined("local.anchor")) {
				local.id = local.anchor.first().id();
			}

			if (NOT (IsDefined("local.id") AND local.id neq "")) {
				local.id = LCase(ReReplace(Replace(header.text()," ","-","all"), "[^\w\-]", "", "all"));
				header.attr("id",local.id);
			}
			// add entry to meta for all cases
			arguments.document.meta[local.id] = {id=local.id,text=header.text(),level=replace(header.tagName(), "h", "")};
			
			// add to toc list if not excluded
			if (NOT header.hasClass("notoc")) {
				ArrayAppend(idList,local.id);
			}
			else {
				header.removeClass("notoc");
			}
		}

		arguments.document.meta["tocList"] = idList;
		arguments.document.meta["toc"] = generateTocHTML(idlist,arguments.document.meta);
		
		// check meta data not dumped into root and assign values from default headings
		for (var field in ['title','author','description']) {
			if (StructKeyExists(arguments.document.meta,field) AND NOT StructKeyExists(arguments.document.meta.meta,field)) {
				if (IsStruct(arguments.document.meta[field])) {
					if (StructKeyExists(arguments.document.meta[field], "text")) {
						arguments.document.meta.meta[field] = arguments.document.meta[field].text;
					}
				}
				else {
					arguments.document.meta.meta[field] = arguments.document.meta[field];
				}
			}
		}

		// if not title set by id=title attribute then get first h1 tag
		if (NOT structKeyExists(arguments.document.meta.meta, "title")) {

			 local.title = local.node.select("h1");

			 if (IsDefined("local.title") AND ArrayLen(local.title)) {
			 	arguments.document.meta.meta.title = local.title.first().text();
			 }
		}


		// auto cross references
		local.links = local.node.select("a[href]");
		// if (!IsDefined(local.links)) {
			for (local.link in local.links) {
				local.id = ListLast(local.link.attr("href"),"##");
				if (StructKeyExists(arguments.document.meta,local.id)) {
					local.text = local.link.text();
					if (trim(local.text) eq "") {
						local.link.html(arguments.document.meta[local.id].text);
					}
				}
			}
		// }
		arguments.document.html = local.node.body().html();

	}

	/**
	 * Generate HTML for a table of contents.
	 * @idlist        List of IDs in order
	 * @meta          Meta data (see process(). Each heading needs an entry which is a struct with keys level,text, and id)
	 * @return  Formatted HTML
	 */
	private string function generateTocHTML(required array idlist, required struct meta) {
		
		var line = false;
		local.open = 0;
		
		// see stylesheet. Some have auto content. Manual needs possibility of numbers.
		local.toc = "<div id=""toc"" class=""manual"">";

		// default level for TOC headings
		if (NOT StructKeyExists(arguments.meta,"toclevel")) arguments.meta.toclevel = 3;

		for (var id in arguments.idlist) {
			if (StructKeyExists(arguments.meta,id)) {
				line = arguments.meta[id];
				if (line.level AND line.level lte arguments.meta.toclevel) {
					if (line.level eq 1) {
						if (local.open) local.toc &= "  </div>";
						//- bit of a legacy - styling used to be applied to the toc div which
						//surrounded the whole thing. This had to be taken out to stop it
						//creating a page break, so now we apply the toc styling to each individual div 
						local.toc &= "  <div class=""toc tocsection"">";
						local.open = 1;
					}
					local.toc &= "    <p class=""toc#line.level#""><a href=""###line.id#"">#line.text#</a></p>#chr(10)#";
				}
			}
		}
		if (local.open) {local.toc &= "  </div>";}
		local.toc &= "</div>";

		return local.toc;
	}


}