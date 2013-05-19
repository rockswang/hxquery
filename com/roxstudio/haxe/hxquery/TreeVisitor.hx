package com.roxstudio.haxe.hxquery;

interface TreeVisitor<T> {

    public function parent(n: T) : T;

    public function childAt(n: T, index: Int) : T;

    public function childForId(n: T, id: String) : T;

    public function length(n: T) : Int;

    public function indexOf(n: T, child: T) : Int;

    public function typeOf(n: T) : String;

    public function idOf(n: T) : String;

    public function hasClass(n: T, className: String) : Bool;

    public function hasAttribute(n: T, name: String) : Bool;

    public function attribute(n: T, name: String) : Dynamic;

    public function setAttribute(n: T, name: String, value: Dynamic) : Void;

}
