# CF Markdown

Helper component for using Flexmark with CFML

## Background

Simpler helper component to make working with Flexmark easy.

## Installation

### 1. Flexmark JAR

Ensure Flexmark the flexmark jar is in your server's Java classpath. You may want to install Jsoup at the same time (see following)

### 2. JSoup JAR

The helper component requires Jsoup and a CF wrapper, ColdSoup. First install JSoup into your Java classpath and ensure it loads.

```
jSoupClass = createObject( "java", "org.jsoup.Jsoup" );
```

## 2. Helper components

Now install the helper components to a component path. Best is to have a common library folder set as an additional resource to look for components in that folder and sub folders.

### 2.1 ColdSoup

The Flexmark CFC requires [ColdSoup](https://github.com/tom-clik/coldsoup), a helper component for [JSoup](https://www.jsoup.org).

Test your install by trying to create a new flexmark component.

```
coldsoup = new coldsoup.coldsoup();
```

### 2.2 Flexmark

Install flexmark.cfc to a component path.

Test your install by trying to create a new flexmark component.

```
flexmark = new markdown.flexmark();
```

## Usage

Initiate as a singleton pattern component and then call the markdown method.

```
application.flexmark = new markdown.flexmark();

doc = application.flexmark.markdown(mytest,{"baseurl"="https://www.somepathon.web/"});
```

doc will contain two keys, "`html`" and "`data`""

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

An additional option `unwrapAnchors`  copes with a bug with the anchorlink extension. Leave this on.

## Meta data

