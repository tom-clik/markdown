# CF Markdown

Helper component for using Flexmark with CFML

## Background

Project containers a Java class (Flexmark.jar) and a CF component (flexmark.cfc) to aid working with [Flexmark](https://github.com/vsch/flexmark-java)

The Java class takes a string of options and creates a Flexmark parser with the necessary extensions.

The CF component providers some eaily accessible methods and an array of additional functionality for producing documents. It isn't necessary if all you want to do is parase markdown, you can just use the Java Class.

## Installation

### 1. Flexmark JAR

Ensure Flexmark.jar is in your server's Java classpath. You may want to install Jsoup at the same time (see following)

If all you want to do is pare Markdown, you can do it with just this component.

Test your installation with `markdown = createObject( "java", "Flexmark" ).init();`

### 2. JSoup JAR

The helper component requires Jsoup and a CF wrapper, ColdSoup. First install JSoup into your Java classpath


## 2. Flexmark CFC

### 2.1 Jsoup and ColdSoup

The Flexmark CFC requires [ColdSoup](https://github.com/tom-clik/coldsoup), a helper component for [JSoup](https://www.jsoup.org).

Please ensure you have Jsoup in your server class path and then add the coldsoup.cfc to a component path.

Add Flexmark.cfc to a component path for your server.

### 2.2 Flexmark

Install flexmark.cfc to a component path.

Test your install by trying to create a new flexmark component.

markdown = new flexmark();




