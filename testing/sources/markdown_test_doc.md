---
author: Tom Peer
toclevel: 2
notoc: #title, .endmatter h2
---

# Document title here {#title}

# Basics

## Heading with class {#myid .class otheratt=whatver}

**Lorem ipsum**... dolor---sit amet, _consectetur adipisicing elit_, sed do eiusmod
tempor incididunt ut labore et dolore--magna aliqua. *Ut enim* ad minim veniam,
quis nostrud exercitation ullamco 'laboris nis' ut aliquip ex <<ea commodo>>
consequat. [Duis aute][reflink] irure dolor in reprehenderit in "voluptate velit" esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

[reflink]: http://www.testlink.com "A test link"

<p>_Any_ <span> [old](html)</span> **in here**</p>

    <div>
    <p>This should be code</p>
    </div>


[Any old link](http://news.bbc.co.uk 'Hello')

![](sources/wripper_test_doc_files/image001.jpg){style="right" width="122mm"}

## Some code

`**<b>list 2</b>**`

# Lists

## Numeric list

1. Numeric list
2. Numeric

Some text with a footnote[^footnote]

[^footnote]: This is a footnote

## Any old list {#mylistid}

* Any old list
* Any old list

    This item should continue in the above list

    So should this actually

* Simple list

    1. This list should also belong to the above
    2. And this

        1. Theoretically we could keep recursing

            ### This should go in ok

            FOR
                CODE HERE

            AND MORE CODE

         {.l3list data-note="Should apply to level 3 list element"}

    3. Should be another item

{.simplelist data-note="Should apply to list element"}

## Definition list

Deflist 1
:    Defintiion here

Deflist 2
:    Defintiion here
:    Otehr Defintiion here

{.deflist}

# Footnotes

More text with a footnote[^footnote2]

[^footnote2]: This is another footnote

# Quotes

> quote

# Admonitions

!!! note "Note title"
    This is a highlight

!!! danger
    Great Danger

# To do lists

- [ ] Stuff to do 1
- [ ] Stuff to do 2
- [x] Stuff done 1
- [X] Stuff done 1

# Tables

| table  | table 1    | table 2 |
|:------:|------------|--------:|
| cell1  | cell 2            ||
|| cell 4  | cell 5
{ .info}

# Table of contents {#contents .notoc}

{$toc}


# Macros

|   Complex   |     Data     |
|-------------|--------------|
| <<<macro>>> | <<<macro2>>> |

{.table}

>>>macro
1. Item 1
2. Item 2
3. Item 3

| Column 1 | Column 2 |
|----------|----------|
| a        | b        |
| c        | d        |

> Block Quote and more

<<<

>>>macro2
- Item 1
- Item 2
- Item 3
<<<

<div class="endmatter">

## Title: _{$title}_

## Author: _{$author}_

</div>

