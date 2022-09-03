# CF Markdown

Helper component for using Flexmark with CFML

## Background

Project containers a Java class (Flexmark.jar) and a CF component (flexmark.cfc) to aid working with [Flexmark](https://github.com/vsch/flexmark-java)

The Java class takes a string of options and creates a Flexmark parser with the necessary extensions.

The CF component providers some eaily accessible methods and an array of additional functionality for producing documents. It isn't necessary if all you want to do is parase markdown, you can just use the Java Class.

## Installation

### 1. Flexmark JAR

Ensure Flexmark.jar is in your server's Java classpath. You may want to install Jsoup at the same time (see following)

If all you want to do is parse Markdown, you can do it with just this component.

Test your installation with `markdown = createObject( "java", "Flexmark" ).init();`

### 2. JSoup JAR

The helper component requires Jsoup and a CF wrapper, ColdSoup. First install JSoup into your Java classpath and ensure it loads.

```
jSoupClass = createObject( "java", "org.jsoup.Jsoup" );
```

## 2. Helper components

Now install the helper components to a component path. Best is to have a common library folder set as an additional resource to look for components. Alternatively set up a mapping for coldsoup and .

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



