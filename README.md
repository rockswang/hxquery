HxQuery
=======

A JQuery-like CSS Selectors engine written in Haxe, for quick visit any tree data structure.

HxQuery provides an abstract TreeVisitor interface for developers to implement so that the custom tree structure can be operated with HxQuery engine.
Currently the engine has already included: 

* An Xml visitor
* A flash/nme display list visitor
* A plain Haxe object visitor (very useful for parsed Json objects)

CSS Selectors implemention based on http://www.w3.org/TR/selectors/

#### Supported Selectors syntax:

* Groups of selectors. E.g. "div,h1,h2"
* Combinators
  * Descendant combinator. E.g. "div form"
  * Child combinator. E.g. "ul > li"
  * Adjacent sibling combinator. E.g. "ul + hr"
  * General sibling combinator. E.g. "ul ~ div"
* Simple selectors
  * Type selector. E.g. "div"
  * Universal selector. E.g. "*"
  * Attribute selector. E.g. "[alt]", "[src^='http://']", "[text*='hello']", "[class~='aa']"
  * Class selectors. E.g. ".no_border"
  * ID selectors. E.g. "#input_box"
  * Pseudo-classes. E.g. "ul li:even", "ol li:gt(3)" see Supported pseudo-classes

#### Supported pseudo-classes:

* :even, :odd
* :nth-child(an+b). E.g. "ul li:nth-child(2n+1)"
* :gt(i), :lt(i), :eq(i)
* :only-child
* :empty
* :not . E.g. "div input:not([type='submit'])"
  
#### Xml example:

```haxe
    var xhtml = Xml.parse(Assets.getText("res/sample.xhtml"));
    var input = [ xhtml ];
    v = new XmlVisitor();
    v.createQuery(input).select("pcdata").filter(function(idx: Int, n: Xml) : Bool {
        return n.nodeValue.trim().length == 0;
    }).remove();
    trace(v.createQuery(input).dump());
    var found: HxQuery<Xml> = v.createQuery(input).select("body > ul > li");
```

#### Flash/NME display list example:

```haxe
    var input = [ cast (stage, DisplayObject) ];
    var v: TreeVisitor<DisplayObject> = new DisplayListVisitor();
    trace(v.createQuery(input).dump());
    var found: HxQuery<DisplayObject> = v.createQuery(input).select("Stage Circle").filter(function(_, n: DisplayObject) {
        return Std.is(n, Base);
    }).each(function(n: DisplayObject) {
        cast(n, Base).update(true);
    });
```

Notes for display list visitor:
* DisplayObject.name is treated as the ID of the node
* The Class name is treated as the Type of the node, package is not included, i.e. type of "com.example.A" is "A"
* The super classes & implemented interfaces are treated as the Class of the node, can use the full-qualified name with "." replaced by "_", or registered short name
* All fields & properties are treated as Attribute of the node

#### Haxe object example:

```haxe
    var obj = { name: [ "rocks", "wang" ], age: 35, mobiles: [{ type: "xiaomi", no: "1111" }, { type: "c8500" }] };
    var input: Wrapper = DynamicVisitor.wrapper(obj);
    var v: TreeVisitor<Wrapper> = new DynamicVisitor();
    trace(v.createQuery(input).dump());
    var found: HxQuery<Wrapper> = v.createQuery(input).select("mobiles > :not([no])");
```

###License

####The MIT License

Copyright © 2012 roxstudio / rockswang

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rightsto use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
