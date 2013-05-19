HxQuery
=======

A JQuery-like CSS Selectors engine written in Haxe, for quick visit any tree data structure.

HxQuery provides an abstract TreeVisitor interface for developers to implement so that the custom tree struction can be operated with HxQuery engine.
Currently the engine has already included: 
* An Xml visitor
* A flash/nme display list visitor
* A plain Haxe object visitor (very useful for parsed Json objects)

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
        
Haxe object example:

        var input: Wrapper = DynamicVisitor.wrapper({ name: [ "rocks", "wang" ], age: 35, mobiles: [{ type: "xiaomi", no: "1111" }, { type: "c8500" }] });
        var v: TreeVisitor<Wrapper> = new DynamicVisitor();
        var query = new HxQuery(v);
        query.print(input);
        var found: Array<Wrapper> = query.find(input, "Array#mobiles > :not([no])");

