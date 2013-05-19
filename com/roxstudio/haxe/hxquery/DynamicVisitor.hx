package com.roxstudio.haxe.hxquery;

class DynamicVisitor extends AbstractVisitor<Wrapper> {

    public function new() {
        super();
    }

    override public function parent(n: Wrapper) : Wrapper {
        return n.parent;
    }

    override public function children(n: Wrapper) : Array<Wrapper> {
        if (n.children == null) {
            var ret: Array<Wrapper> = n.children = [];
            if (n.isLeaf) return n.children;
            var obj = n.value;
            if (n.type == "Array") {
                var arr: Array<Dynamic> = cast obj;
                for (i in 0...arr.length) {
                    ret.push(wrapper(arr[i], n, "" + i));
                }
            } else {
                for (f in Reflect.fields(obj)) {
                    ret.push(wrapper(Reflect.field(obj, f), n, f));
                }
            }
        }
        return n.children;
    }

    override public function typeOf(n: Wrapper) : String {
        return n.type;
    }

    override public function idOf(n: Wrapper) : String {
        return n.name;
    }

    override public function hasAttribute(n: Wrapper, name: String) {
        return Reflect.hasField(n.value, name);
    }

    override public function attribute(n: Wrapper, name: String) : Dynamic {
        return name == "__value__" ? n.value : Reflect.getProperty(n.value, name);
    }

    override public function setAttribute(n: Wrapper, name: String, value: Dynamic) : Void {
        Reflect.setProperty(n.value, name, value);
    }

    public static inline function wrapper(d: Dynamic, ?parent: Wrapper = null, ?name: String = "") : Wrapper {
        return new Wrapper(d, parent, name);
    }

}

class Wrapper {
    public var parent: Wrapper;
    public var children: Array<Wrapper> = null;
    public var type: String;
    public var name: String;
    public var value: Dynamic;
    public var isLeaf = true;

    public function new(value: Dynamic, ?parent: Wrapper = null, ?name: String = "") {
        this.parent = parent;
        this.value = value;
        this.name = name;
        this.type = switch (Type.typeof(value)) {
            case TInt: "Int";
            case TBool: "Bool";
            case TFloat: "Float";
            case TFunction: "Function";
            case TNull: "Null";
            case TUnknown: "Unknown";
            case TEnum(e): StringTools.replace(Type.getEnumName(e), ".", "_");
            case TClass(clz): isLeaf = false; StringTools.replace(Type.getClassName(clz), ".", "_");
            case TObject: isLeaf = false; "Dynamic";
        }
    }

    private function toString() : String {
        return value.toString();
    }
}
