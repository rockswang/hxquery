package com.roxstudio.haxe.hxquery;

import com.roxstudio.haxe.hxquery.HxQuery;
using StringTools;

class XmlVisitor extends AbstractVisitor<Xml> {

    public function new() {
        super();
    }

    override public function parent(n: Xml) {
        return n.parent;
    }

    override public function typeOf(n: Xml) : String {
        return n.nodeType == Xml.Element ? n.nodeName : "";
    }

    override public function idOf(n: Xml) : String {
        return n.nodeType == Xml.Element ? n.get("id") : "";
    }

    override public function hasClass(n: Xml, className: String) : Bool {
        var clz = n.nodeType == Xml.Element ? n.get("class") : null;
        return clz != null ? HxQuery.inArray(className, clz.split(" ")) : false;
    }

    override public function hasAttribute(n: Xml, name: String) {
        return n.nodeType == Xml.Element ? n.exists(name) : false;
    }

    override public function attribute(n: Xml, name: String) : Dynamic {
        return n.nodeType == Xml.Element ? (name == "__value__" ? n.nodeValue : n.get(name)) : null;
    }

    override public function setAttribute(n: Xml, name: String, value: Dynamic) : Void {
        if (n.nodeType == Xml.Element) n.set(name, value.toString());
    }

    override public function children(n: Xml) : Array<Xml> {
        var result: Array<Xml> = [];
        for (e in n.elements()) result.push(e);
        return result;
    }

}
