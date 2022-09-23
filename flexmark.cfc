/**

Process markdown with Flexmark and generate data 

## Background

Uses https://github.com/vsch/flexmark-java

We have created a simple class to allow for creation of a parser with common modules available.

See java/Flexmark.java for the source or just place Flexmark.jar into your app's java path.

You can then just use it directly (see notes) or use this component which wraps it into a CFML component.

## Usage

The flexmark class takes a comma separated list of options from the following (or all of these if omitted):

1. tables
1. abbreviation
1. admonition
1. anchorlink
1. attributes
1. autolink
1. definition
1. emoji
1. escapedcharacter
1. footnote
1. strikethrough
1. softbreaks

If you just want to parse markdown, you don't need this component. Just use the flexmark
java class e.g. 
	
    variables.markdown = createObject( "java", "Flexmark" ).init();
	variables.markdown.render(text);

## Notes

There is a bug with Flexmark that we cater for here.

If you don't use the Anchor links plug in, it will remove any ids specified with the # syntax (e.g. {#title}). If you do use anchorlinks, it will move ALL attributes from the heading tag onto the anchor.

We therefore have a workaround, which is an option unwrapAnchors, which will look for empty `<a>` tags where the href is the same as the id tag, copy the attributes to the parent and unwrap the a tag. This is fine as there is no real need to use anchor tags any more, a link to any ID is possible.

## History
	
*/

component name="flexmark" {

	public function init(boolean tables=true,
			boolean abbreviation=true,
			boolean admonition=true,
			boolean anchorlink=true,
			boolean anchorlinks_wrap_text=true,
			boolean attributes=false,
			boolean autolink=true,
			boolean definition=true,
			boolean emoji=true,
			boolean escapedcharacter=true,
			boolean footnote=true,
			boolean strikethrough=true,
			boolean unwrapAnchors=true
			) {
	
		this.cr            = chr(10);
		
		this.coldsoup      = new coldsoup.coldsoup();
		variables.unwrapAnchors = arguments.unwrapAnchors;

		local.optionString = "";
		for (var option in arguments) {
			local.optionString = listAppend(local.optionString, option & "=" & arguments[option]);
		}

		variables.markdown = createObject( "java", "Flexmark").init();

		this.patternObj    = createObject( "java", "java.util.regex.Pattern" );
		this.alphapattern  = this.patternObj.compile("(?m)^@[\w\[\]]+\.?\w*\s+.+?\s*$",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);
		this.varpattern    = this.patternObj.compile("(?m)\{\$\w*\_\w*\}",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);
			
		
		return this;
	
	}

	/**
	 * @hint Render markdown as html
	 *
	 * Returns a struct with keys 
	 *
	 * html
	 * :The rendered html
	 * data
	 * : A struct of information about the document keyed by element id. Contaings heading text
	 * 
	 * 
	 *
	 * @Text  Text to process
	 * @options  Options
	 * @baseurl  Deprecated, use baseurl in options
	 *
	 * @return Struct with keys html and data (see notes)
	 *
	 */
	public struct function markdown (required string text, struct options, string baseurl) {
		
		var doc = {"data" = {"meta"={}},"baseurl"=""};

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

		arguments.text = alphameta(arguments.text,doc.data.meta);

		doc.html = variables.markdown.render(arguments.text);

		addData(doc);

		doc.html = replaceVars(doc.html, doc.data.meta);
		
		return doc;

	}

	/** 
	 * @hint Add single line @var  references to meta data and remove them
	 * @text markdown text
	 * @meta doc meta data
	 *
	 * @return text with @vars removed
	 
	 */
	public string function alphameta(required string text, required struct meta) {
		
		var tags = [];
		var str = false;
		
		// handle underscores in variable names.
		local.dodgyVarsToReplace = {}; 
		local.dodgyVars = this.varpattern.matcher(arguments.text); 
		while (local.dodgyVars.find()){
			local.dodgyVar = local.dodgyVars.group();
			if (Find("_",local.dodgyVar)) {
				local.dodgyVarsToReplace[local.dodgyVar] =1;
			}
		}
		
		for (str in local.dodgyVarsToReplace) {
			local.replaceStr = Replace(str,"_","%%varUndrscReplace%%","all");
			arguments.text = Replace(arguments.text,str,local.replaceStr,"all");	
		}

		// create array of alpha vars to deal with
		local.tagMatch = this.alphapattern.matcher(arguments.text); 
		
		while (local.tagMatch.find()){
		    ArrayAppend(tags, local.tagMatch.group());
		}

		for (str in tags) {
			//split on first whitespace
			local.trimStr = Trim(str);
			local.tag = ListFirst(local.trimStr," 	");
			local.data = ListRest(local.trimStr," 	");
			local.tagRoot = ListFirst(local.tag,"@.[]");
			// struct
			if (ListLen(local.tag,"@.") gt 1) {
				local.tagProperty = ListRest(local.tag,"@.");
				if (NOT StructKeyExists(arguments.meta,local.tagRoot)) {
					arguments.meta[local.tagRoot] = {};
				}
				if (NOT IsStruct(arguments.meta[local.tagRoot])) {
					throw('You have tried to assign a property a value that is not an struct [#local.tag#]')
				}
				arguments.meta[local.tagRoot][local.tagProperty] = local.data;
			}
			else {
				// array
				if (Right(local.tag,2) eq "[]") {
					if (NOT StructKeyExists(arguments.meta,local.tagRoot)) {
						arguments.meta[local.tagRoot] = [];
					}
					if (NOT IsArray(arguments.meta[local.tagRoot])) {
						throw('You have tried to append array data to a value that is not an array [#local.tag#]')
					}
					ArrayAppend(arguments.meta[local.tagRoot],local.data);
				}
				// simple value
				else {
					arguments.meta[local.tagRoot] = local.data;
				}
			}

			// remove the line
			arguments.text = Replace(arguments.text,str,"",1);
		}

		return arguments.text;
			
	}

	/**
	 * @hint Replace mustache like variables with values form data struct
	 *
	 * Variables in form {varname} are replaced with values from a data struct
	 *
	 * Originally meant for mustache compatibility, this has extended to allow nested structs with . notation for the
	 * variables
	 *
	 */
	public string function replaceVars(html,data) {
		
		//get around problem of extra p surrounding toc
		arguments.html    = REReplace(arguments.html,"\s*\<p[^>]*?\>\s*(\{\$toc\}\s*)\<\/p\>","\1");
		
		arguments.html    = REReplace(arguments.html,"%%varUndrscReplace%%","_","all");

		local.arrVarNames = REMatch("\{\$[^}]+\}",arguments.html);
		local.sVarNames   = {};
		
		// create lookup struct of all vars present in text. Only defined ones are replaced.
		for (local.i in local.arrVarNames) {
			local.varName = ListFirst(local.i,"{}$");
			// dot syntax not recommended
			if (ListLen(local.varName,".") gt 1) {
				if (IsDefined("arguments.data.#local.varName#")) {
					local.sVarNames[local.varName] = arguments.data[ListFirst(local.varName,".")][ListLast(local.varName,".")];
				}
			}
			else {
				if (StructKeyExists(arguments.data, local.varName)) {
					local.sVarNames[local.varName] = arguments.data[local.varName];
				}
			}
		}

		for (local.varName in local.sVarNames) {
			local.val = "";
			// possible problem with referencing complex values.
			if (IsSimpleValue(local.sVarNames[local.varName])) {
				local.val = local.sVarNames[local.varName];
			}
			else if (IsStruct(local.sVarNames[local.varName]) AND StructKeyExists(local.sVarNames[local.varName],"text")) {
				local.val = local.sVarNames[local.varName].text;	
			}
			arguments.html = ReplaceNoCase(arguments.html,"{$#local.varName#}", local.val,"all");

		}

		return arguments.html;
		
	}

	/**
	 * @hint Create meta data for the document
	 *
	 * 
	 */
	public void function addData(required struct document) {
		
		local.node = this.coldsoup.parse(arguments.document.html);

		if (NOT structKeyExists(arguments.document,"data")) {
			arguments.document.data = {};
		}

		// data.meta was originally html meta tags but now generic variable thing
		if (NOT structKeyExists(arguments.document.data,"meta")) {
			arguments.document.data.meta = {};
		}

		// notoc is list of jsoup selectors to apply "notoc" class
		if (StructKeyExists(arguments.document.data,"notoc")) {
			if (NOT IsArray(arguments.document.data.notoc)) {
				local.toc = ListToArray(arguments.document.data.notoc);
			}
			else {
				local.toc = arguments.document.data.notoc;
			}
 			
			for (var notocrule in local.toc) {
				
				local.notocnodes = local.node.select(Trim(notocrule));
				
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
			
			// generate id from header text NB flexmark places the id and other attributes in to the <a> child tag
			local.anchor = header.select("a");
			if (IsDefined("local.anchor")) {
				local.tag = local.anchor.first();

				local.id = local.tag.id();

				local.href = local.anchor.attr("href");
				if (IsDefined("local.href")) {
					local.target = ListLast(local.href,"##");
				}
				
				// flexmark always adds href to anchors. If it links to itself it's an anchor not a link.
				if (local.id == local.target) {
					local.tag.removeAttr("href");
					// There is also a bug in Flexmark which removes ids if you're not using anchorlinks.
					// Therefore the only way to get the ids is to use anchor links and assign the id to the parent element
					if (variables.unwrapAnchors) {
						this.coldsoup.copyAttributes(local.tag,header);
						local.tag.unwrap();
					}
					
				}
			}

			if (NOT (IsDefined("local.id") AND local.id neq "")) {
				local.id = LCase(ReReplace(Replace(header.text()," ","-","all"), "[^\w\-]", "", "all"));
				header.attr("id",local.id);
			}
			// add entry to data for all cases
			arguments.document.data[local.id] = {id=local.id,text=header.text(),level=replace(header.tagName(), "h", ""),hasToc=yesNoFormat(header.hasClass("notoc"))};
			
			// add to toc list if not excluded
			if (NOT header.hasClass("notoc")) {
				ArrayAppend(idList,local.id);
				header.addClass("hastoc");
			}
			else {
				header.removeClass("notoc");
			}
		}

		arguments.document.data["tocList"] = idList;
		arguments.document.data["toc"] = generateTocHTML(idlist,arguments.document.data);
		
		// Assign values from default headings to meta fields
		for (var field in ['title','author','subject']) {
			if (StructKeyExists(arguments.document.data,field) AND NOT StructKeyExists(arguments.document.data.meta,field)) {
				if (IsStruct(arguments.document.data[field])) {
					if (StructKeyExists(arguments.document.data[field], "text")) {
						arguments.document.data.meta[field] = arguments.document.data[field].text;
					}
				}
				else {
					// really shoudn't be happening any more
					arguments.document.data.meta[field] = arguments.document.meta[field];
				}
			}
		}

		// if not title set by id=title attribute then get first h1 tag
		if (NOT structKeyExists(arguments.document.data.meta, "title")) {

			 local.title = local.node.select("h1");

			 if (IsDefined("local.title") AND ArrayLen(local.title)) {
			 	arguments.document.data.meta.title = local.title.first().text();
			 }
		}

		// auto cross references
		local.links = local.node.select("a[href]");
				
		for (local.link in local.links) {
			
			local.id = ListLast(local.link.attr("href"),"##");
			
			if (StructKeyExists(arguments.document.data,local.id)) {
				local.text = local.link.text();
				if (trim(local.text) eq "") {
					local.link.html(arguments.document.data[local.id].text);
				}
			}
			
		}
		
		arguments.document.html = local.node.body().html();

	}

	/**
	 * Generate HTML for a table of contents.
	 * 
	 * @idlist   List of IDs in order
	 * @data     Document data (see addData(). Each heading needs an entry which is a struct with keys level,text, and id)
	 * @return   Formatted HTML
	 */
	private string function generateTocHTML(required array idlist, required struct data) {
		
		var line = false;
		local.open = 0;
		
		// TODO: class name parameterise
		local.toc = "<div id=""toc"" class=""manual"">";

		// default level for TOC headings
		if (NOT StructKeyExists(arguments.data,"toclevel")) arguments.data.toclevel = 3;

		for (var id in arguments.idlist) {
			if (StructKeyExists(arguments.data,id)) {
				line = arguments.data[id];
				if (line.level AND line.level lte arguments.data.toclevel) {
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