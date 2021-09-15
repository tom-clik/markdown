import com.vladsch.flexmark.ext.abbreviation.AbbreviationExtension;
import com.vladsch.flexmark.ext.admonition.AdmonitionExtension;
import com.vladsch.flexmark.ext.anchorlink.AnchorLinkExtension;
import com.vladsch.flexmark.ext.attributes.AttributesExtension;
import com.vladsch.flexmark.ext.autolink.AutolinkExtension;
import com.vladsch.flexmark.ext.definition.DefinitionExtension;
import com.vladsch.flexmark.ext.emoji.EmojiExtension;
import com.vladsch.flexmark.ext.escaped.character.EscapedCharacterExtension;
import com.vladsch.flexmark.ext.footnotes.FootnoteExtension;
import com.vladsch.flexmark.ext.gfm.strikethrough.StrikethroughExtension;
import com.vladsch.flexmark.ext.tables.TablesExtension;
import com.vladsch.flexmark.html.HtmlRenderer;
import com.vladsch.flexmark.parser.Parser;
import com.vladsch.flexmark.util.ast.Node;
import com.vladsch.flexmark.util.data.MutableDataSet;
import com.vladsch.flexmark.util.misc.Extension;
import com.vladsch.flexmark.html2md.converter.FlexmarkHtmlConverter;

import java.util.*;

public class Flexmark {

	MutableDataSet options = new MutableDataSet();
	Parser parser;

	HtmlRenderer renderer;
	FlexmarkHtmlConverter htmlToMarkdown;

	public Flexmark() {
		this("tables=true,abbreviation=true,admonition=true,anchorlink=true,attributes=true,autolink=true,definition=true,emoji=true,escapedcharacter=true,footnote=true,strikethrough=true");
	}

	public Flexmark(String options) {

		List<String> optionsList = new ArrayList<>(Arrays.asList(options.split(",")));
		HashMap<String,String> optionsSet = new HashMap<>();

		for (String optionpair: optionsList) {
			List<String> attrs = new ArrayList<>(Arrays.asList(optionpair.trim().split("=")));
			if (attrs.size() > 1) {
				optionsSet.put(attrs.get(0),attrs.get(1));
			}
			else {
				optionsSet.put(attrs.get(0),"true");
			}

		}
		System.out.println(optionsSet);
		boolean all = optionsSet.containsKey("all");
		System.out.println(all);

		ArrayList<Extension> extensions = new ArrayList<>();

		if (optionsSet.containsKey("tables") && Boolean.parseBoolean(optionsSet.get("tables"))) {
			extensions.add(TablesExtension.create());
		}
		if (optionsSet.containsKey("abbreviation") && Boolean.parseBoolean(optionsSet.get("abbreviation"))) {
			extensions.add(AbbreviationExtension.create());
		}
		if (optionsSet.containsKey("admonition") && Boolean.parseBoolean(optionsSet.get("admonition"))) {
			extensions.add(AdmonitionExtension.create());
		}
		if (optionsSet.containsKey("anchorlink") && Boolean.parseBoolean(optionsSet.get("anchorlink"))) {
			if (optionsSet.containsKey("anchorlinks_wrap_text")) {
				this.options.set(AnchorLinkExtension.ANCHORLINKS_WRAP_TEXT,Boolean.parseBoolean(optionsSet.get("anchorlinks_wrap_text")));
			}
			extensions.add(AnchorLinkExtension.create());
		}
		if (optionsSet.containsKey("attributes") && Boolean.parseBoolean(optionsSet.get("attributes"))) {
			extensions.add(AttributesExtension.create());
		}
		if (optionsSet.containsKey("autolink") && Boolean.parseBoolean(optionsSet.get("autolink"))) {
			extensions.add(AutolinkExtension.create());
		}
		if (optionsSet.containsKey("definition") && Boolean.parseBoolean(optionsSet.get("definition"))) {
			extensions.add(DefinitionExtension.create());
		}
		if (optionsSet.containsKey("emoji") && Boolean.parseBoolean(optionsSet.get("emoji"))) {
			extensions.add(EmojiExtension.create());
		}
		if (optionsSet.containsKey("escapedcharacter") && Boolean.parseBoolean(optionsSet.get("escapedcharacter"))) {
			extensions.add(EscapedCharacterExtension.create());
		}
		if (optionsSet.containsKey("footnote") && Boolean.parseBoolean(optionsSet.get("footnote"))) {
			extensions.add(FootnoteExtension.create());
		}
		if (optionsSet.containsKey("strikethrough") && Boolean.parseBoolean(optionsSet.get("strikethrough"))) {
			extensions.add(StrikethroughExtension.create());
		}
		
		this.options.set(Parser.EXTENSIONS,extensions);
		
		if (optionsSet.containsKey("softbreaks")) {
			this.options.set(HtmlRenderer.SOFT_BREAK, "<br />\n");
		}
		
		parser = Parser.builder(this.options).build();
		renderer = HtmlRenderer.builder(this.options).build();
		htmlToMarkdown = FlexmarkHtmlConverter.builder(this.options).build();

	}

	public String render(String s) {

		// You can re-use parser and renderer instances
		Node document = parser.parse(s);
		String html = renderer.render(document); 
		return html;
	}

	public String toMarkdown(String s) {
		return htmlToMarkdown.convert(s);
	}
}