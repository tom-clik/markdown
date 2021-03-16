/**

@hint Process markdown with Flexmark and generate meta data 

If you just want to parse markdown, you don't need this component. Just use the flexmark
java class e.g. 
	
    variables.markdown = createObject( "java", "Flexmark" ).init();
	variables.markdown.parse(text);
	
*/

component name="flexmark" {

	public function init() {
	
		this.cr = chr(10);
		
		this.coldsoup = createObject( "component", "coldsoup.coldSoup" ).init();

		variables.markdown = createObject( "java", "Flexmark" ).init();
		
		return this;
	
	}

	/**
	 *
	 * @Text  Test to process
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
		
		doc.html = variables.markdown.render(arguments.text);

		addmeta(doc);
		
		return doc;

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
			
			// generate id from header text NB flexmark places th id in to the <a> child tag
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