/**

Process markdown with Flexmark and generate data 

## Background

Uses [Flexmark](https://github.com/vsch/flexmark-java) to render HTML and produce Meta data.

## Usage

See README.md

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
	
		this.cr = newLine();
		
		try {
			this.coldsoup      = new coldsoup.coldsoup();
			variables.useJsoup = true;
		}
		catch (any e) {
			variables.useJsoup = false;
		}
		
		// doc properties allows us to use YAML to define 
		// publishing properties like toclevel.
		variables.docProperties = {
			"toclevel" = 3,
			"notoc" = ""
		};

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
		this.includepattern    = this.patternObj.compile("\<div\s+(href=\s*['\""](.*?)['\""]).*?\/\>",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);

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
	 * @hint Convert to html and generate meta data
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
	 * @options  Publishing options, see docProperties. Will override any set in YAML
	 *
	 * @return Struct with keys html and data (see notes)
	 *
	 */
	public struct function markdown (required string text, struct options={}) localmode=true {
		
		if (!variables.useJsoup ) {
			throw("use of markdown() function requires coldsoup. Use toHtml() instead.");
		}

		doc = {"data" = {"meta"={}}};

		doc.text = arguments.text;
		
		meta = {};

		doc.html = toHtml(text=arguments.text,data=meta); 
		
		// remove doc properties from meta and add to main struct
		// This allows us to use YAML to defined publishing properties
		// like toclevel but keeps the meta data clean

		for (prop in variables.docProperties) {
			if (StructKeyExists(arguments.options, prop) ) {
				doc.data["#prop#"] = arguments.options[prop];
			}
			else if (StructKeyExists(meta, prop) ) {
				doc.data["#prop#"] = meta[prop];
				StructDelete(meta, prop);
			}
			// else add default
			else if (variables.docProperties[prop] neq "") {
				doc.data["#prop#"] = variables.docProperties[prop];
			}
		}

		StructAppend(doc.data.meta, meta);

		addContent(doc);
			
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
	 * @hint Read an index file and run markdown() on the result
	 *
	 * An index file can include other markdown files. Include them
	 * using <div href='filename.md' />
	 *
	 * Note that the syntax is quite fussy.
	 * 
	 */
	public struct function readIndex (required string filename) localmode=true {
		
		filepath = GetDirectoryFromPath(arguments.filename);
		text = FileRead(arguments.filename);
		
		includes = this.includepattern.matcher(text);
		
		while (includes.find()) {
			includeText = FileRead(filepath & "/" & includes.group(javacast("int",2)));
			tag = Replace(includes.group(javacast("int",0)),includes.group(javacast("int",1)),"");
			tag = Replace(tag,"/>",">");
			tag = ReReplace(tag,"\s+\>",">");
			tag &= newLine() & newLine() & includeText & newLine() & "</div>";
			text = Replace(text,includes.group(javacast("int",0)), tag);
		}
		
		return markdown(text);

	}

	/**
	 * @hint Replace mustache like variables with values form data struct
	 *
	 * Variables in form {$varname} are replaced with values from a data struct
	 *
	 * Originally meant for mustache compatibility, this has extended to allow nested structs with . notation for the
	 * variables
	 *
	 **/
	public string function replaceVars(html,data) {
		
		//get around problem of extra p surrounding toc
		arguments.html    = REReplace(arguments.html,"\s*\<p[^>]*?\>\s*(\{\$toc\}\s*)\<\/p\>","\1");
		
		// deprecated underscore handler
		arguments.html    = REReplace(arguments.html,"%%varUndrscReplace%%","_","all");

		// find all variable names
		local.arrVarNames = REMatch("\{\$[^}]+\}",arguments.html);
		local.sVarNames   = {};
		
		// create lookup struct of all vars present in text.
		for (local.i in local.arrVarNames) {
			local.varName = ListFirst(local.i,"{}$");
			// TODO: only works for one level
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
	 * @hint Parse headings into a struct of structs (document.data.content)
	 *
	 * Each entry has the following keys
	 * 
	 * id    dom ID
	 * level toc level (id 1-4)
	 * text  Heading text
	 * toc   (boolean) include in toc
	 *
	 */
	public void function addContent(required struct document) localmode="true" {
		
		node = this.coldsoup.parse(arguments.document.html);

		if (NOT structKeyExists(arguments.document,"data")) {
			arguments.document["data"] = {};
		}

		if (NOT structKeyExists(arguments.document.data,"meta")) {
			arguments.document.data["meta"] = {};
		}

		// notoc is list of jsoup selectors to exclude from toc. Apply "notoc" class to nodes to do this
		if (StructKeyExists(arguments.document.data,"notoc")) {
			
			for (notocrule in ListToArray( arguments.document.data.notoc ) ) {
				
				notocnodes = node.select(Trim(notocrule));
				
				for (notocNode in notocnodes) {
					notocNode.addClass("notoc");
				}
			}
		}

		headers = node.select("h1,h2,h3,h4");
		content = [=];
		
		for (  header in headers) {
			
			// this gets overridden in flexmark if auto headers is on. See next
			id = header.id();
			
			// generate id from header text NB flexmark places the id and other attributes in to the <a> child tag
			anchor = header.select("a");
			if ( ArrayLen(anchor) ) {
				tag = anchor.first();

				id = tag.id();

				href = anchor.attr("href");
				if (IsDefined("href")) {
					target = ListLast(href,"##");
					
					// flexmark always adds href to anchors. If it links to itself it's an anchor not a link.
					if (id == target) {
						tag.removeAttr("href");
						// There is also a bug in Flexmark which removes ids if you're not using anchorlinks.
						// Therefore the only way to get the ids is to use anchor links and assign the id to the parent element
						if (variables.unwrapAnchors) {
							this.coldsoup.copyAttributes(tag,header);
							tag.unwrap();
						}
						
					}
				}
			}

			if (NOT (IsDefined("id") AND id neq "")) {
				id = LCase(ReReplace(Replace(header.text()," ","-","all"), "[^\w\-]", "", "all"));
				header.attr("id",id);
			}
			
			// add entry to data for all cases. Boolean notoc indicates 
			// inclusion in toc
			noToc = header.hasClass("notoc");
			content["#id#"] = {"id"=id,"text"=header.text(),"level"=replace(header.tagName(), "h", ""),"toc"=!(noToc)};
			
			if (noToc) {
				header.removeClass("notoc");
			}
		}

		arguments.document.data["content"] = content;
		arguments.document.data.meta["toc"] = generateTocHTML(arguments.document.data);
		
		// Assign values from default headings to meta fields
		for (field in ['title','author','subject']) {
			if (StructKeyExists(arguments.document.data.content,field) AND NOT StructKeyExists(arguments.document.data.meta,field)) {
				arguments.document.data.meta["#field#"] = arguments.document.data.content[field].text;
				
			}
		}

		// if not title set by id=title attribute then get first h1 tag
		if (! StructKeyExists(arguments.document.data.meta, "title")) {

			 title = node.select("h1");

			 if (IsDefined("title") AND ArrayLen(title)) {
			 	arguments.document.data.meta.title = title.first().text();
			 }
		}

		// auto cross references
		links = node.select("a[href]");
				
		for (link in links) {
			
			id = ListLast(link.attr("href"),"##");
			
			if (StructKeyExists(arguments.document.data,id)) {
				text = link.text();
				if (trim(text) eq "") {
					link.html(arguments.document.data[id].text);
				}
			}
			
		}

		removeUnusedIDs(document=arguments.document,jsoupNode=node);

		arguments.document.html = node.body().html();

	}

	/**
	 * @hint Remove ID tags that aren't used from headers
	 *
	 * Flexmark will add an ID to every heading. This function removes them if
	 * they are not in the TOC or not referenced anywhere
	 */
	private string function removeUnusedIDs(required struct document, required any jsoupNode) localmode=true {
		
		// get list of all links used
		targets = {};
		links = arguments.jsoupNode.select("[href]");

		if (IsDefined("links")) {
			for (link in links) {
				href = link.attr("href");
				if (IsDefined("href")) {
					if (Left(href,1) eq "##" ) {
						targets["#ListFirst(href,"##")#"] = true;
					}
				}
			}
		}

		idTags =  arguments.jsoupNode.select("[id]");
		
		for (tag in idTags) {
			id = tag.attr("id");
			if (IsDefined("id")) {
				if (! ( targets.keyExists(id)  || ( ! arguments.document.data.content.keyExists(id) || ! arguments.document.data.content[id].toc ) ) ) {
					tag.removeAttr("id");
				}
			}
		}
	}

	/**
	 * Generate HTML for a table of contents.
	 * 
	 * @data     Document data (see addContent(). Each heading needs an entry which is a struct with keys level,text, id, and toc)
	 * @return   Formatted HTML
	 */
	private string function generateTocHTML(required struct data) localmode=true {
		
		// TODO: class name parameterise
		html = "<div id=""toc"" class=""toc toc_manual"">";

		// default level for TOC headings
		if (NOT StructKeyExists(arguments.data,"toclevel")) arguments.data["toclevel"] = variables.docProperties.toclevel;

		if (! arguments.data.keyExists("content") ) {
			throw(message="No content defined in data. Cannot generate toc");
		}

		currentlevel = 0;

		for (id in arguments.data.content) {
			heading = arguments.data.content[id];
			toc = heading.toc ? : true; // toc can be set to false via notoc mechanism
			level = heading.level ? : 20; // all headings should have a level 1-6. 
			
			if (toc && level lte arguments.data.toclevel) {
				if (level neq currentlevel) {
					if (currentlevel gt level ) { 
						html &= repeatString("</div>" & newLine(), currentlevel - level);
					}
					html &= "  <div class=""tocsection tocsection#level#"">";
					currentlevel = level;
				}
				html &= "    <p class=""toc#level#""><a href=""###heading.id#"">#heading.text#</a></p>" & newLine();
			}
			
		}
		html &= repeatString("</div>", currentlevel);

		html &= "</div>";

		return html;
	}


}