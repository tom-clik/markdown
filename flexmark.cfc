/**

Process markdown with Flexmark and generate data 

## Background

Uses https://github.com/vsch/flexmark-java

## Usage



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
			boolean unwrapAnchors=true,
			boolean softbreaks=false,
			boolean macros=true,
			boolean typographic = false,
			boolean tasklist = true,
			boolean yaml = true
			) {
	
		this.cr            = newLine();
		
		this.coldsoup      = new coldsoup.coldsoup();
		
		variables.unwrapAnchors = arguments.unwrapAnchors;

		local.optionString = "";
		for (var option in arguments) {
			local.optionString = listAppend(local.optionString, option & "=" & arguments[option]);
		}

		var HtmlRendererClass = createObject( "java", "com.vladsch.flexmark.html.HtmlRenderer" );
		var ParserClass = createObject( "java", "com.vladsch.flexmark.parser.Parser" );
		var options = createObject( "java", "com.vladsch.flexmark.util.data.MutableDataSet" ).init();
		var extensions = optionList(optionsSet=arguments);
		
		options.set(ParserClass.EXTENSIONS,extensions);
		
		if (arguments.softbreaks) {
			options.set(HtmlRendererClass.SOFT_BREAK, "<br />\n");
		}
		if (arguments.anchorlinks_wrap_text) {
			var AnchorLinkExtensionClass = createObject( "java", "com.vladsch.flexmark.ext.anchorlink.AnchorLinkExtension"); 
			options.set(AnchorLinkExtensionClass.ANCHORLINKS_WRAP_TEXT,arguments.anchorlinks_wrap_text);
		}

		// Create our parser and renderer - both using the options.
		variables.parser = ParserClass.builder( options ).build();
		variables.renderer = HtmlRendererClass.builder( options ).build();

		this.patternObj    = createObject( "java", "java.util.regex.Pattern" );
		this.alphapattern  = this.patternObj.compile("(?m)^@[\w\[\]]+\.?\w*\s+.+?\s*$",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);
		this.varpattern    = this.patternObj.compile("(?m)\{\$\w*\_\w*\}",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);
		
		variables.yaml = arguments.yaml;
		
		return this;
	
	}

	private function optionList(struct optionsSet) {

		var extensions = createObject( "java", "java.util.ArrayList" );

		if (optionsSet.keyExists("tables") && optionsSet["tables"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.tables.TablesExtension").create());
		}
		if (optionsSet.keyExists("abbreviation") && optionsSet["abbreviation"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.abbreviation.AbbreviationExtension").create());
		}
		if (optionsSet.keyExists("admonition") && optionsSet["admonition"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.admonition.AdmonitionExtension").create());
			import com.vladsch.flexmark.ext.admonition.AdmonitionExtension;
		}
		if (optionsSet.keyExists("anchorlink") && optionsSet["anchorlink"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.anchorlink.AnchorLinkExtension").create());
		}
		if (optionsSet.keyExists("attributes") && optionsSet["attributes"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.attributes.AttributesExtension").create());
		}
		if (optionsSet.keyExists("autolink") && optionsSet["autolink"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.autolink.AutolinkExtension").create());
		}
		if (optionsSet.keyExists("definition") && optionsSet["definition"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.definition.DefinitionExtension").create());
		}
		if (optionsSet.keyExists("emoji") && optionsSet["emoji"]) {
			import com.vladsch.flexmark.ext.emoji.EmojiExtension;
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.emoji.EmojiExtension").create());
		}
		if (optionsSet.keyExists("escapedcharacter") && optionsSet["escapedcharacter"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.escaped.character.EscapedCharacterExtension").create());
		}
		if (optionsSet.keyExists("footnote") && optionsSet["footnote"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.footnotes.FootnoteExtension").create());
		}
		if (optionsSet.keyExists("macros") && optionsSet["macros"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.macros.MacrosExtension").create());
		}
		if (optionsSet.keyExists("strikethrough") && optionsSet["strikethrough"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.gfm.strikethrough.StrikethroughExtension").create());
		}
		if (optionsSet.keyExists("tasklist") && optionsSet["tasklist"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.gfm.tasklist.TaskListExtension").create());
		}
		if (optionsSet.keyExists("typographic") && optionsSet["typographic"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.typographic.TypographicExtension").create());
		}
		if (optionsSet.keyExists("yaml") && optionsSet["yaml"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.yaml.front.matter.YamlFrontMatterExtension").create());
		}

		return extensions;
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

		local.meta = {};

		arguments.text = alphameta(arguments.text,doc.data.meta);

		doc.html = toHtml(text=arguments.text,data=local.meta); 
		StructAppend(doc.data.meta, local.meta);

		addData(doc);
			
		doc.html = replaceVars(doc.html, doc.data.meta);
		
		return doc;

	}

	/**
	 * Plain markdown to html conversion
	 
	 * @text          Markdown text to convert
	 * @data          Struct to update with YAML data
	 */
	public string function toHtml(required string text, struct data={}) {
		local.document = variables.parser.parse(arguments.text);
		if (variables.yaml) {
			local.yamlVisitor = createObject( "java", "com.vladsch.flexmark.ext.yaml.front.matter.AbstractYamlFrontMatterVisitor");
			local.yamlVisitor.visit(document);
			local.metadata = local.yamlVisitor.getData();
			if (local.metadata.size()) {
				for (local.key in local.metadata.keySet()) {
					local.keyData =local.metadata.get(local.key);

					try {
						if ( ! ArrayLen(local.keyData) ) {
							arguments.data[local.key] = "";
						}
						else {
							arguments.data[local.key] = Trim(local.keyData[1]);
						}
					}
					catch (any e) {
						local.extendedinfo = {"tagcontext"=e.tagcontext,"keyData"=local.keyData};
						throw(
							extendedinfo = SerializeJSON(local.extendedinfo),
							message      = "Unable to parse Yaml:" & e.message, 
							detail       = e.detail
						);
					}
				}
			}
			
		}
		return variables.renderer.render(local.document); 
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
	 **/
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

		// notoc is list of jsoup selectors to exclude from toc. Apply "notoc" class to nodes to do this
		if (StructKeyExists(arguments.document.data.meta,"notoc")) {
			if (NOT IsArray(arguments.document.data.meta.notoc)) {
				local.notocSelectors = ListToArray(arguments.document.data.meta.notoc);
			}
			else {
				local.notocSelectors = arguments.document.data.meta.notoc;
			}
 			
			for (local.notocrule in local.notocSelectors) {
				
				local.notocnodes = local.node.select(Trim(local.notocrule));
				
				for (local.notocNode in local.notocnodes) {
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
			local.noToc = header.hasClass("notoc");
			arguments.document.data[local.id] = {"id"=local.id,text=header.text(),"level"=replace(header.tagName(), "h", ""),"toc"=NOT local.noToc};
			
			// add to toc list if not excluded
			if (NOT local.noToc) {
				ArrayAppend(idList,local.id);
				header.addClass("hastoc");
			}
			else {
				header.removeClass("notoc");
			}
		}

		arguments.document.data["tocList"] = idList;
		arguments.document.data.meta["toc"] = generateTocHTML(idlist,arguments.document.data);
		
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