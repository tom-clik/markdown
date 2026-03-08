# CF Markdown

CF Markdown provides a convenient wrapper for the Flexmark Java library. It provides simple HTML conversion or more complex document manipulation using Jsoup (optional).

## Installation

### 1. Flexmark JAR

To load the library you need to pass in the path to the actual JAR. I have tried using the new Maven dependency but for some reason it just doesn't work.

### 2. CF Markdown

Download this repository to a component path and test your install by trying to create a new flexmark component.

```
flexmark = new markdown.flexmark(jarpath=path_to_jar);
```

You should now be able to use the `toHtml()` method to convert markdown to HTML.


### 3. JSoup JAR

To use the more advance functions such as TOC creation, you can install [Jsoup](https://mvnrepository.com/artifact/org.jsoup/jsoup) in the same way as the Flexmark library and ensure it loads.

```
jSoupClass = createObject( "java", "org.jsoup.Jsoup", pathtojar );
```

### 4. ColdSoup

If you install JSoup you will also need [ColdSoup](https://github.com/tom-clik/coldsoup). Install to a [component path](https://docs.lucee.org/guides/cookbooks/application-context-set-mapping.html#component-and-custom-tag-mappings).

Test your install by trying to create a new coldsoup component.

```
coldsoup = new coldsoup.coldsoup(jarpath=path_to_jar);
```

## Usage

Initiate as a singleton pattern component in a persistent scope and then call the toHTML method.

```
application.flexmark = new markdown.flexmark(jarpath=path_to_jar);

data = {};
html = application.flexmark.toHTML(markdown,data);
```

`data` will contain any YAML data you have added.

## Options

Each of the major extensions can be loaded by supplying arguments to the init function. Most are loaded by default and you'll need to turn them off if you don't want them.

| Extension             | Default
|-----------------------|---------
| abbreviation          | true
| admonition            | true
| anchorlink            | true
| anchorlinks_wrap_text | true
| attributes            | false
| autolink              | true
| definition            | true
| emoji                 | true
| escapedcharacter      | true
| footnote              | true
| strikethrough         | true
| softbreaks            | false
| macros                | true
| typographic           | false
| tasklist              | true
| yaml                  | true

An additional option `unwrapAnchors`  copes with a bug with the anchorlink extension. Leave this on.

## Meta data

Yaml meta data is on by default. It is returned in the `data` struct passed as an argument.

For more advanced meta data, you can use the `markdown()` method which examines the IDs of elements and constructs a TOC and other meta data.
