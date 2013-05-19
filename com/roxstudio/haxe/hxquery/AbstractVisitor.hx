package com.roxstudio.haxe.hxquery;

class AbstractVisitor<T> implements TreeVisitor<T> {

    private function new() {}

/*********************** The default implementation **************************/

    public function parent(n: T) : T {
        return null;
    }

    public function childAt(n: T, index: Int) : T {
        return children(n)[index];
    }

    public function childForId(n: T, id: String) : T {
        for (c in children(n)) if (idOf(c) == id) return c;
        return null;
    }

    public function length(n: T) : Int {
        return children(n).length;
    }

    public function indexOf(n: T, child: T) : Int {
        for (i in 0...length(n)) {
            if (childAt(n, i) == child) return i;
        }
        return -1;
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

    public function hasAttribute(n: T, name: String) : Bool {
        var all = attributes(n);
        return all != null && all.exists(name);
    }

    public function attribute(n: T, name: String) : Dynamic {
        var all = attributes(n);
        return if (all != null) all.get(name);
    }

    public function setAttribute(n: T, name: String, value: Dynamic) : Void {
        throw "Abstract method";
    }

/*********************** Routines for default implementation **************************/

    public function children(n: T) : Array<T> {
        throw "Abstract method";
        return [];
    }

    public function attributes(n: T) : Hash<Dynamic> {
        throw "Abstract method";
        return null;
    }

}
