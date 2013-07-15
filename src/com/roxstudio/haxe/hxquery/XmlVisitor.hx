package com.roxstudio.haxe.hxquery;

import com.roxstudio.haxe.hxquery.HxQuery;
using StringTools;

class XmlVisitor extends AbstractVisitor<Xml> {

    private static inline var VALUE = "value";
    private static var EMPTY: Array<Dynamic>;
    private static var ATTR: Array<String>;
#if flash
    private static var compare: Xml -> Xml -> Bool;
#end

    private static function __init__() {
        EMPTY = [];
        ATTR = [ VALUE ];
#if flash
        compare = Reflect.field(Xml, "compare");
#end
        var dummy = Xml.createElement("dummy");
        for (x in dummy) {} // prevent "iterator()" from being eliminated by DCE
    }

    public function new() {
        super();
    }

    override public function ordered() : Bool {
        return true;
    }

    override public function parent(n: Xml) {
        return n.parent;
    }

    override public function children(n: Xml) : Iterable<Xml> {
        return switch(n.nodeType) {
            case Xml.Element, Xml.Document: cast n;
            default: cast EMPTY;
        }
    }

    override public function addChild(n: Xml, child: Xml, beforeChild: Xml) : Bool {
        return switch (n.nodeType) {
            case Xml.Element, Xml.Document:
                var idx = beforeChild != null ? this.indexOf(n, beforeChild) : -1;
                if (idx >= 0) {
                    n.insertChild(child, idx);
                } else {
                    n.addChild(child);
                }
                true;
            default: false;
        }
    }

    override public function removeChild(n: Xml, child: Xml) : Xml {
        return switch (n.nodeType) {
            case Xml.Element, Xml.Document: n.removeChild(child) ? child : null;
            default: null;
        }
    }

    override public function empty(n: Xml) : Bool {
        return switch (n.nodeType) {
            case Xml.Element, Xml.Document:
                var first: Xml;
                while ((first = n.firstChild()) != null) n.removeChild(first);
                true;
            default: false;
        }
    }

    override public function equals(n1: Xml, n2: Xml) : Bool {
#if flash
        return compare(n1, n2);
#else
        return n1 == n2;
#end
    }

    override public function typeOf(n: Xml) : String {
        return switch (n.nodeType) {
            case Xml.Element: n.nodeName;
            default: "" + n.nodeType;
        }
    }

    override public function idOf(n: Xml) : String {
        return n.nodeType == Xml.Element ? n.get("id") : "";
    }

    override public function hasClass(n: Xml, className: String) : Bool {
        var clz = n.nodeType == Xml.Element ? n.get("class") : null;
        return clz != null ? HxQuery.inArray(className, clz.split(" ")) : false;
    }

    override public function attributes(n: Xml) : Iterable<String> {
        return switch(n.nodeType) {
            case Xml.Element: cast { iterator: n.attributes };
            case Xml.Document: cast EMPTY;
            default: cast ATTR;
        }
    }

    override public function hasAttr(n: Xml, name: String) {
        return switch (n.nodeType) {
            case Xml.Element: n.exists(name);
            case Xml.Document: false;
            default: VALUE == name;
        }
    }

    override public function getAttr(n: Xml, name: String) : Dynamic {
        return switch (n.nodeType) {
            case Xml.Element: n.get(name);
            case Xml.Document: null;
            default: VALUE == name ? n.nodeValue : null;
        }
    }

    override public function setAttr(n: Xml, name: String, value: Dynamic) : Void {
        switch (n.nodeType) {
            case Xml.Element: n.set(name, cast value);
            case Xml.Document: // no attribute
            default: if (VALUE == name) n.nodeValue = cast value;
        }
    }

    override public function removeAttr(n: Xml, name: String) : Void {
        switch (n.nodeType) {
            case Xml.Element: n.remove(name);
            default: // cannot remove nodeValue
        }
    }

}
