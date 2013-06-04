package com.roxstudio.haxe.hxquery;

interface TreeVisitor<T> {

    public function ordered() : Bool;

    public function parent(n: T) : T;

//    public function childAt(n: T, index: Int) : T;
    public function children(n: T) : Iterable<T>;

    public function childForId(n: T, id: String) : T;

    /*
     * add "child" node to "n", before node "beforeNode", if beforeNode is null, append "child" to "n"
     */
    public function addChild(n: T, child: T, beforeChild: T) : Bool;

    public function removeChild(n: T, child: T) : T;

    public function replaceChild(n: T, oldChild: T, newChild: T) : Bool;

    public function empty(n: T) : Bool;

    public function equals(n1: T, n2: T) : Bool;

    public function size(n: T) : Int;

    public function create(strArg: String, objArg: Dynamic) : T;

    public function parse(text: String) : T;

    public function toString(n: T) : String;

    public function typeOf(n: T) : String;

    public function idOf(n: T) : String;

    public function hasClass(n: T, className: String) : Bool;

    public function attributes(n: T) : Iterable<String>;

    public function hasAttr(n: T, name: String) : Bool;

    public function getAttr(n: T, name: String) : Dynamic;

    public function setAttr(n: T, name: String, value: Dynamic) : Void;

    public function removeAttr(n: T, name: String) : Void;

    public function createQuery(elements: Array<T>) : HxQuery<T>;

}
