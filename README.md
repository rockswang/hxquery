HxQuery
=======

A JQuery-like CSS Selectors engine written in Haxe, for quick visit any tree data structure.

HxQuery provides an abstract TreeVisitor interface for developers to implement so that the custom tree struction can be operated with HxQuery engine.
Currently the engine has already included: 
* An Xml visitor
* A flash/nme display list visitor
* A plain Haxe object visitor (very useful for parsed Json objects)

CSS Selectors implemention based on http://www.w3.org/TR/selectors/

Supported syntax:
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
  * Pseudo-classes. E.g. "ul li:even", "ol li:gt(3)"

Supported pseudo-classes:
* :even, :odd
* :nth-child(an+b). E.g. "ul li:nth-child(2n+1)"
* :gt(i), :lt(i), :eq(i)
* :only-child
* :empty
* :not . E.g. "dir input:not([type='submit'])"
  
Xml example:

        var input: Xml = Xml.parse(ResKeeper.loadAssetText("res/a.xml"));
        var v: TreeVisitor<Xml> = new XmlVisitor();
        var query = new HxQuery(v);
        query.print(input);
        var found: Array<Xml> = query.find(input, "div#box1 > form input[type='text']");

Flash/NME display list example:

        var input = nme.Lib.current.stage;
        var v: TreeVisitor<DisplayObject> = new DisplayListVisitor();
        var query = new HxQuery(v);
        query.print(input);
        var found: Array<DisplayObject> = query.find(input, "MySprite > TextField:nth-child(2)");
        
Notes for display list visitor:
* DisplayObject.name is treated as the ID of the node
* The Class name is treated as the Type of the node, package is not included, i.e. type of "com.example.A" is "A"
* The super classes & implemented interfaces are treated as the Class of the node, can use the full-qualified name with "." replaced by "_", or registered short name
* All fields & properties are treated as Attribute of the node

Haxe object example:

        var obj = { name: [ "rocks", "wang" ], age: 35, mobiles: [{ type: "xiaomi", no: "1111" }, { type: "c8500" }] };
        var input: Wrapper = DynamicVisitor.wrapper(obj);
        var v: TreeVisitor<Wrapper> = new DynamicVisitor();
        var query = new HxQuery(v);
        query.print(input);
        var found: Array<Wrapper> = query.find(input, "Array#mobiles > :not([no])");

