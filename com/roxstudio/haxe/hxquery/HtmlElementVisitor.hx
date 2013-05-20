package com.roxstudio.haxe.hxquery;

import com.roxstudio.haxe.hxquery.HxQuery;
import js.html.HtmlElement;
import js.html.Node;
using StringTools;

class HtmlElementVisitor extends AbstractVisitor<HtmlElement> {

    public function new() {
        super();
    }

    override public function parent(n: HtmlElement) {
        return cast n.parentNode;
    }

    override public function typeOf(n: HtmlElement) : String {
		//html is case-insensitive
        return n.nodeType == Node.ELEMENT_NODE ? n.nodeName.toLowerCase() : "";
    }

    override public function idOf(n: HtmlElement) : String {
        return n.nodeType == Node.ELEMENT_NODE ? n.id : "";
    }

    override public function hasClass(n: HtmlElement, className: String) : Bool {
        var clz = n.nodeType == Node.ELEMENT_NODE ? n.className : null;
        return clz != null ? HxQuery.inArray(className, clz.split(" ")) : false;
    }

    override public function hasAttribute(n: HtmlElement, name: String) {
        return n.nodeType == Node.ELEMENT_NODE ? n.getAttribute(name) == null : false;
    }

    override public function attribute(n: HtmlElement, name: String) : Dynamic {
        return n.nodeType == Node.ELEMENT_NODE ? (name == "__value__" ? n.nodeValue : n.getAttribute(name)) : null;
    }

    override public function setAttribute(n: HtmlElement, name: String, value: Dynamic) : Void {
        if (n.nodeType == Node.ELEMENT_NODE) n.setAttribute(name, value.toString());
    }

    override public function children(n: HtmlElement) : Array<HtmlElement> {
        var result: Array<HtmlElement> = [];
		//cast as childNodes are of type Node
        for (e in n.childNodes) result.push(cast e);
        return result;
    }

}
