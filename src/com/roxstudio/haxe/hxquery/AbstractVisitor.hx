package com.roxstudio.haxe.hxquery;

import StringTools;
import StringTools;
using StringTools;

class AbstractVisitor<T> implements TreeVisitor<T> {

    private function new() {}

/*********************** The default implementation **************************/

    public function ordered() : Bool {
        throw "Abstract method";
        return false;
    }

    public function parent(n: T) : T {
        throw "Abstract method";
        return null;
    }

    public function children(n: T) : Iterable<T> {
        throw "Abstract method";
        return [];
    }

    public function childForId(n: T, id: String) : T {
        for (c in children(n)) if (idOf(c) == id) return c;
        return null;
    }

    public function addChild(n: T, child: T, beforeChild: T) : Bool {
        throw "Abstract method";
        return false;
    }

    public function removeChild(n: T, child: T) : T {
        throw "Abstract method";
        return null;
    }

    public function empty(n: T) : Bool {
        throw "Abstract method";
        return false;
    }

    public function equals(n1: T, n2: T) : Bool {
        return n1 == n2;
    }

    public function size(n: T) : Int {
        return Lambda.count(children(n));
    }

    public function create(strArg: String, objArg: Dynamic) : T {
        throw "Abstract method";
        return null;
    }

    public function parse(text: String) : T {
        throw "Abstract method";
        return null;
    }

    public function toString(n: T) : String {
        var buf = new StringBuf();
        buf.add(this.typeOf(n) + " ");
        for (a in this.attributes(n)) {
            buf.add(a + "='" + attrStr(this.getAttr(n, a)) + "' ");
        }
        return buf.toString();
    }

    public function typeOf(n: T) : String {
        throw "Abstract method";
        return "";
    }

    public function idOf(n: T) : String {
        throw "Abstract method";
        return "";
    }

    public function hasClass(n: T, className: String) : Bool {
        return false;
    }

    public function attributes(n: T) : Iterable<String> {
        return [];
    }

    public function hasAttr(n: T, name: String) : Bool {
        return Lambda.has(attributes(n), name);
    }

    public function getAttr(n: T, name: String) : Dynamic {
        return null;
    }

    public function setAttr(n: T, name: String, value: Dynamic) : Void {
    }

    public function removeAttr(n: T, name: String) : Void {
    }

    public function createQuery(elements: Array<T>) : HxQuery<T> {
        return new HxQuery(elements, this);
    }

    private inline function indexOf(n: T, child: T) : Int {
        var idx = -1, i = 0;
        for (c in this.children(n)) {
            if (c == child) { idx = i; break; }
            i++;
        }
        return idx;
    }

    private inline function attrStr(d: Dynamic) : String {
        var s: String = d == null ? "" : StringTools.replace(StringTools.replace("" + d, "\n", "\\n"), "\r", "");
        return s.length > 30 ? s.substr(0, 27) + "..." : s;
    }

}
