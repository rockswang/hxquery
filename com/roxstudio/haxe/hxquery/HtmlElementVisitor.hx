package com.roxstudio.haxe.hxquery;

import com.roxstudio.haxe.hxquery.HxQuery;
import js.Dom;
using StringTools;

class HtmlElementVisitor extends AbstractVisitor<HtmlDom> {

	static inline var ELEMENT_NODE:Int = 1;
	
    public function new() {
        super();
    }

    override public function parent(n: HtmlDom) {
        return n.parentNode;
    }

    override public function typeOf(n: HtmlDom) : String {
		//html is case-insensitive
        return n.nodeType == ELEMENT_NODE ? n.nodeName.toLowerCase() : "";
    }

    override public function idOf(n: HtmlDom) : String {
        return n.nodeType == ELEMENT_NODE ? n.id : "";
    }

    override public function hasClass(n: HtmlDom, className: String) : Bool {
        var clz = n.nodeType == ELEMENT_NODE ? n.className : null;
        return clz != null ? HxQuery.inArray(className, clz.split(" ")) : false;
    }

    override public function hasAttribute(n: HtmlDom, name: String) {
        return n.nodeType == ELEMENT_NODE ? n.getAttribute(name) == null : false;
    }

    override public function attribute(n: HtmlDom, name: String) : Dynamic {
        return n.nodeType == ELEMENT_NODE ? (name == "__value__" ? n.nodeValue : n.getAttribute(name)) : null;
    }

    override public function setAttribute(n: HtmlDom, name: String, value: Dynamic) : Void {
        if (n.nodeType == ELEMENT_NODE) n.setAttribute(name, value.toString());
    }

    override public function children(n: HtmlDom) : Array<HtmlDom> {
        var result: Array<HtmlDom> = [];
        for (i in 0...n.childNodes.length) result.push(n.childNodes[i]);
        return result;
    }

}
