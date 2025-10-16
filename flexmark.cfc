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

## Usage

Instantiate with the plugins and options you require set by the arguments. If you want to use the advanced functionality, specify a path to the Jsoup Jar as well (jsoupjar).

Call one of the conversion methods, `toHtml` or `Markdown`. The latter requires the use of Jsoup (via the herlper component ColdSoup).

## History
	
*/

component name="flexmark" {

	public function init(
			boolean tables=true,
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
			boolean yaml = true,
			boolean superscript = true,
			string  jsoupjar   // optional for full featured parsing using markdown() rather than toHtml()
			) {
	
		this.cr = newLine();
		
		variables.useJsoup = isDefined("arguments.jsoupjar");
		try {
			this.coldsoup      = new coldsoup.coldsoup(arguments.jsoupjar);
		}
		catch (any e) {
			variables.useJsoup = false;
		}

		variables.yaml = arguments.yaml;
		
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
		
		// used to preserve mustache vars. They get wrecked by Flexmark if we don't do this (don't know why)
		this.mustachepattern    = this.patternObj.compile("(\{{2,3})(\w+)(\}{2,3})",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);
		this.reversemustachepattern    = this.patternObj.compile("(\[{2,3})(\w+)(\]{2,3})",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);
		
		// variable replace syntax. Replace ${var} with variables from meta data
		// also cope with {$var}
		this.varpattern    = this.patternObj.compile("(\$\{|\{\$)([A-Za-z0-9.]*[^{}])\}",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);

		//  deprecated
		this.alphapattern  = this.patternObj.compile("(?m)^@[\w\[\]]+\.?\w*\s+.+?\s*$",this.patternObj.MULTILINE + this.patternObj.UNIX_LINES);
		
		
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
		if (optionsSet.keyExists("superscript") && optionsSet["superscript"]) {
			extensions.add(createObject( "java", "com.vladsch.flexmark.ext.superscript.SuperscriptExtension").create());
		}

		return extensions;
	}

	/**
	 * @hint Convert to html and generate meta data
	 *
	 * Returns a struct with keys 
	 *
	 * html
	 * :   The rendered html
	 * data
	 * :   A struct of information about the document keyed by element id. Contains heading text
	 * 
	 * 
	 *
	 * @Text  Text to process
	 * @options  Publishing options, see docProperties. Will override any set in YAML
	 * @replace_vars replace vars in ${var} format with values from meta data
	 * @return Struct with keys html and data (see notes)
	 *
	 */
	public struct function markdown (required string text, struct options={}, replace_vars=true) localmode=true {
		
		if (!variables.useJsoup ) {
			throw("use of markdown() function requires coldsoup. Use toHtml() instead.");
		}

		// Add processing options. Note document properties have a different mechanism see variables.docProperties
		StructAppend(arguments.options, {"meta"=1}, false);

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
		
		addContent(document=doc, meta=arguments.options.meta);
		parseFootnotes(doc);

		if (arguments.replace_vars) {
			doc.html = replaceVars(doc.html, doc.data.meta);
		}
		
		return doc;

	}

	/**
	 * Plain markdown to html conversion
	 
	 * @text          Markdown text to convert
	 * @data          Struct to update with YAML data
	 */
	public string function toHtml(required string text, struct data={}) localmode=true {
		
		arguments.text  = replaceMustacheVars(arguments.text);

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
						local.extendedinfo = {"error"=e,"keyData"=local.keyData};
						throw(
							extendedinfo = SerializeJSON(local.extendedinfo),
							message      = "Unable to parse Yaml:" & e.message, 
							detail       = e.detail
						);
					}
				}
			}
			
		}

		arguments.text = variables.renderer.render(local.document);
		arguments.text  = replaceMustacheVars(arguments.text,true);

		return arguments.text; 

	}
	/**
	 * Replace {{mustachevars}} with temporary place holders (and replace back)
	 */
	private string function replaceMustacheVars(required string text, boolean undo=false)  localmode=true {

		if (arguments.undo) {
			tagObjs = this.reversemustachepattern.matcher(arguments.text);
			matchlist = "[,]";
			replacelist = "{,}";
		}
		else {
			tagObjs = this.mustachepattern.matcher(arguments.text);
			matchlist = "{,}";
			replacelist = "[,]";
		}

		
		fixEntities = [];
		while (tagObjs.find()){
		    arrayAppend(fixEntities, local.tagObjs.group());
		}
		for (entity in fixEntities) {
			entity_r = replaceList(entity,matchlist,replacelist);
			arguments.text = replace(arguments.text, entity, entity_r);
		}
		return arguments.text;
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
	public string function replaceVars(html,data) localmode=true {
		
		//get around problem of extra p surrounding toc
		arguments.html    = REReplace(arguments.html,"\s*\<p[^>]*?\>\s*(\{\$toc\}\s*)\<\/p\>","\1");
		
		// deprecated underscore handler
		arguments.html    = REReplace(arguments.html,"%%varUndrscReplace%%","_","all");

		// find all variable names
		matcher = this.varpattern.matcher(arguments.html);

		// build cache of replacement values. Variables may be keyed e.g.
		// meta.something and there's no quick lookup
		replaceCache = {};

		// use java buffer for single pass
		buffer = createObject("java", "java.lang.StringBuffer");

		// loop over them and relpace
		while (matcher.find()){

			varname = local.matcher.group( javacast("int",2) );
			
			if (! replaceCache.keyExists( varname ) ) {
				// TODO: only works for one level (and horrible) 
				if (ListLen( varname,".") gt 1) {
					if (IsDefined("arguments.data.#varname#")) {
						replaceCache[varname] = arguments.data[ListFirst(varname,".")][ListLast(varname,".")];
					}
					else {
						replaceCache[varname] = local.matcher.group() ;
					}
				}
				else {
					if (StructKeyExists(arguments.data, varname)) {
						replaceCache[varname] = arguments.data[varname];
					}
					else {
						replaceCache[varname] = local.matcher.group() ;
					}
				}
			}
			try{
				matcher.appendReplacement(buffer, matcher.quoteReplacement( replaceCache[varname] ) ) ;
			} 
			catch (any e) {
				local.extendedinfo = {"error"=e,"replaceCache"=replaceCache,"data"=data};
				throw(
					extendedinfo = SerializeJSON(local.extendedinfo),
					message      = "Error replacing vars:" & e.message, 
					detail       = e.detail
				);
			}
			
		}

		matcher.appendTail(buffer);

		arguments.html = buffer.toString();

		return arguments.html;
		
	}

	/**
	 * DEPRECATED 
	 * Parse attributes into a struct from a single tag string 
	 * (e.g. [image id=xx]). Tag can be < or << or [ or [[ 
	 * enclosed. Attributes can be single quoted, double quote 
	 * or alpha numeric
	 * 
	 * @text The full tag string (start tag only, tag name ignored).
	 */
	public struct function parseTagAttributes(
		required string text
	) localmode=true {
		temp = {};
		stext = ReplaceList(arguments.text,"����","',',','");
		stext = ListFirst(Trim(stext),"[]<>");
		attrVals = ListRest(sText," ");

		if (NOT IsDefined("variables.attrPattern")) {
			patternObj = createObject( "java", "java.util.regex.Pattern");
			myPattern = "(\w+)(\s*=\s*(""(.*?)""|'(.*?)'|([^'"">\s]+)))";
			variables.attrPattern = patternObj.compile(myPattern);
		}

		tagObjs = variables.attrPattern.matcher(attrVals);

		while (tagObjs.find()){
		    temp[tagObjs.group(javacast("int",1))] = reReplace(tagObjs.group(javacast("int",3)), "^(""|')(.*?)(""|')$", "\2");
		}

		return temp;
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
	 * @meta Use meta attribute on divs to convert content to a meta var.
	 */
	public void function addContent(required struct document, boolean meta=true) localmode="true" {
		
		if (! arguments.document.keyExists("node") ) {
			arguments.document.node = this.coldsoup.parse(arguments.document.html);
		}
		if (NOT structKeyExists(arguments.document,"data")) {
			arguments.document["data"] = {};
		}

		if (NOT structKeyExists(arguments.document.data,"meta")) {
			arguments.document.data["meta"] = {};
		}
		
		// There is also a bug in Flexmark which removes ids if you're not using anchorlinks.
		// Therefore the only way to get the ids is to use anchor links and assign the id to the parent element
		
		headers = arguments.document.node.select("h1,h2,h3,h4");
		
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
						if (variables.unwrapAnchors) {
							this.coldsoup.copyAttributes(tag,header);
							tag.unwrap();
						}	
					}
				}
			}
		}
		
		// any divs with meta=true are meta data vars
		if (arguments.meta) {
			metadivs = arguments.document.node.select("[meta]");
			for (metadiv in metadivs) {
				id = metadiv.attr("id"); 
				if (! isDefined("id")) {
					throw("Meta attribute defined on div without an ID.");
				}
				arguments.document.data.meta["#id#"] = metadiv.html();
				metadiv.remove();
			}
		}

		// notoc is list of jsoup selectors to exclude from toc. Apply "notoc" class to nodes to do this
		if (StructKeyExists(arguments.document.data,"notoc")) {
			
			for (notocrule in ListToArray( arguments.document.data.notoc ) ) {
				
				notocnodes = arguments.document.node.select(Trim(notocrule));
				
				for (notocNode in notocnodes) {
					notocNode.addClass("notoc");
				}
			}
		}

		content = [=];
		headers = arguments.document.node.select("h1,h2,h3,h4");

		for (  header in headers) {
			
			id = header.id();
			
			// add entry to data for all cases. Boolean notoc indicates 
			// inclusion in toc
			noToc = header.hasClass("notoc");
			level = replace(header.tagName(), "h", "");
			content["#id#"] = {"id"=id,"text"=header.text(),"level"=level,"toc"= (!noToc) && level <= arguments.document.data.toclevel};
			
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

			 title = arguments.document.node.select("h1");

			 if (IsDefined("title") AND ArrayLen(title)) {
			 	arguments.document.data.meta.title = title.first().text();
			 }
		}

		// auto cross references
		links = arguments.document.node.select("a[href]");
				
		for (link in links) {
			
			id = ListLast(link.attr("href"),"##");
			
			if (StructKeyExists(arguments.document.data.content,id)) {
				text = link.text();
				if (trim(text) eq "") {
					link.html(arguments.document.data.content[id].text);
				}
			}
			
		}

		removeUnusedIDs(document=arguments.document,jsoupNode=arguments.document.node);
		fixTableCaptions(jsoupNode=arguments.document.node);

		arguments.document.html = arguments.document.node.body().html();

	}

	/**
	 * Convert caption attibutes to tags
	 */
	private void function fixTableCaptions(required any jsoupNode) {
		local.tables = arguments.jsoupNode.select( "table[caption]" );
		for (local.table in local.tables) {
			local.table.prepend(this.coldsoup.createNode(tagName="caption",text=local.table.attr("caption")));
			local.table.removeAttr("caption");
		}
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
			
			if (left(tag.tagName(),1) neq "h") continue;

			if (IsDefined("id")) {
				if (! ( targets.keyExists(id)  || ( arguments.document.data.content.keyExists(id) && arguments.document.data.content[id].toc ) ) ) {
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

		insection = false;

		for (id in arguments.data.content) {
			heading = arguments.data.content[id];
			toc = heading.toc ? : true; // toc can be set to false via notoc mechanism
			level = heading.level ? : 20; // all headings should have a level 1-6. 
			// MUSTDO: this doesn't work if toclevel=1. 
			if (toc && level lte arguments.data.toclevel) {
				if (arguments.data.toclevel gt 1 && level eq 1) {
					if (insection) { 
						html &= "</div>";
					}
					html &= "  <div class=""tocsection"">";
					insection = true;
				}
				html &= "    <p class=""toc#level#""><a href=""###heading.id#"">#heading.text#</a></p>" & newLine();
			}
			
		}
		// close tocsection tag
		if (arguments.data.toclevel gt 1) {
			html &= "</div>";
		}

		html &= "</div>";

		return html;

	}

	// Flexmark will place footnotes at the end of the HTML. 
	// We want to use them in different ways according to how we are diplsaying
	// the content. Here we put them backinto the HTML as <span class='footnote'></span> elements.
	// For Prince conversion, these are used as is. For Kindle/other html, it's easy to just redo the footnote html
	// 
	private void function parseFootnotes(required any document) {
		if (! arguments.document.keyExists("node") ) {
			arguments.document.node = this.coldsoup.parse(arguments.document.html);
		}

		local.docs = arguments.document.node.select(".footnotes");
		if (! local.docs.len()) {
			return;
		}

		// get rid of the extraneous <sup> tags
		local.markers = arguments.document.node.select("sup[id]");
		for (local.marker in local.markers) {
			local.marker.unwrap();
		}

		// find all the footnote markers
		local.footnotes = arguments.document.node.select("a.footnote-ref");

		for (local.marker in local.footnotes) {
			/* find footnote with format 
			<li id="fn-2"> <p>Look it up if you don’t already know it. And then try not to do it.</p>
			*/
			local.href = local.marker.attr("href");
			local.num = ListLast(local.href,"-");
			local.note = arguments.document.node.select(local.href & " p").first().html();
			local.marker.html("<span class='footnote'>#local.note#</span>").unwrap();
		}

		// remove the footnotes section
		arguments.document.node.select(".footnotes").first().remove();
		
		arguments.document.html = arguments.document.node.body().html();
	}

	
}