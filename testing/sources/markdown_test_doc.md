# Title { #title}

# Legacy heading {.class}
<div>

<p>_Any_ <span> old html</span> in here</p>

</div>

    <div>
    <p>This should be code</p>
    </div>

<noscript>
What is this 1987?
</noscript>
<script>
alert("Hello world");
</script>

## Some code

`**<b>list 2</b>**`

## Numeric list

1. Numeric list
2. Numeric 

Some text with a footnote[^footnote]

[^footnote]: This is a footnote

## Any old list

* Any old list
* Any old list 

	This item should continue in the above list

	So should this actually

*   Simple list

	1. This list should also belong to the above
	2. And this

		1. Theoretically we could keep recursing

			### This should go in ok

		    FOR
		        CODE HERE
		        
		    AND MORE CODE

	3. Should be another item

:Deflist 1	
    Defintiion here
:Deflist 2	
    Defintiion here
:Deflist 3
	Defintiion here

More text with a footnote[^footnote2]

[^footnote2]: This is another footnote

`{{#mustache_test}}{{{mustache_var}}}{{/mustache_test}}`

heading 3 { #h3ed .whatever}

> QUote

!!! Note

!!! Alert

[Any old link](http://news.bbc.co.uk 'Hello')

![](sources/wripper_test_doc_files/image001.jpg){: style="right" width="122mm"}

| table  | table 1    | table 2 |
|:------:|------------|--------:|
| cell1  | cell 2            ||
|| cell 4  | cell 5 
{: .info}

# Table of contents {: #contents .notoc}

{$toc}

<div class="endmatter">

#### Title: _{$meta.title}_

#### Author: _{$meta.author}_

</div>

