package com.roxstudio.haxe.hxquery;

using StringTools;

class DynamicVisitor extends AbstractVisitor<Wrapper> {

    private static inline var TYPE = "__type__";
    private static inline var VALUE = "__value__";
    private static var EMPTY: Array<Dynamic>;
    private static var ATTR: Array<String>;
    private static var compare: Wrapper -> Wrapper -> Bool;

    private static function __init__() {
        EMPTY = [];
        ATTR = [ TYPE, VALUE ];
        compare = function(n1: Wrapper, n2: Wrapper) : Bool {
            return n1.value == n2.value;
        }
    }

    public function new() {
        super();
    }

    override public function ordered() : Bool {
        return false;
    }

    override public function parent(n: Wrapper) : Wrapper {
        return n.parent;
    }

    override public function children(n: Wrapper) : Iterable<Wrapper> {
        if (n.isLeaf) return EMPTY;
        return switch (n.type) {
            case "Array":
                var arr: Array<Dynamic> = cast n.value;
                var len = arr.length, i = 0;
                cast {
                    iterator: function() {
                        return cast {
                            hasNext: function() { return i < len; },
                            next: function() { var ret = wrapper(arr[i], n, "_" + i); i++; return ret; }
                        }
                    }
                }
            case "Hash":
                var hash: Hash<Dynamic> = cast n.value;
                var keys = hash.keys();
                cast {
                    iterator: function() {
                        return cast {
                            hasNext: function() { return keys.hasNext(); },
                            next: function() { var k = keys.next(); return wrapper(hash.get(k), n, k); }
                        }
                    }
                }
            case "IntHash":
                var hash: IntHash<Dynamic> = cast n.value;
                var keys = hash.keys();
                cast {
                    iterator: function() {
                        return cast {
                            hasNext: function() { return keys.hasNext(); },
                            next: function() { var k = keys.next(); return wrapper(hash.get(k), n, "_" + k); }
                        }
                    }
                }
            default:
                var obj = n.value;
                var fields = Reflect.fields(obj);
                var len = fields.length, i = 0;
                cast {
                    iterator: function() {
                        return cast {
                            hasNext: function() { return i < len; },
                            next: function() { var f = fields[i++]; return wrapper(Reflect.field(obj, f), n, f); }
                        }
                    }
                }
        }
    }

    override public function childForId(n: Wrapper, id: String) : Wrapper {
        if (n.isLeaf) return null;
        return switch (n.type) {
            case "Array":
                var arr: Array<Dynamic> = cast n.value;
                var idx = int(id);
                idx != null ? wrapper(arr[idx], n, id) : null;
            case "Hash":
                var hash: Hash<Dynamic> = cast n.value;
                wrapper(hash.get(id), n, id);
            case "IntHash":
                var hash: IntHash<Dynamic> = cast n.value;
                var idx = int(id);
                idx != null ? wrapper(hash.get(idx), n, id) : null;
            default:
                var c = Reflect.getProperty(n.value, id);
                c != null ? wrapper(c, n, id) : null;
        }
    }

    override public function addChild(n: Wrapper, child: Wrapper, beforeChild: Wrapper) : Bool {
        if (n.isLeaf) return false;
        return switch (n.type) {
            case "Array":
                var arr: Array<Dynamic> = cast n.value;
                if (beforeChild == null) {
                    arr.push(child.value);
                } else {
                    var idx = Lambda.indexOf(arr, beforeChild.value);
                    arr.insert(idx, child.value);
                }
                true;
            case "Hash":
                var hash: Hash<Dynamic> = cast n.value;
                hash.set(child.name, child.value);
                true;
            case "IntHash":
                var hash: IntHash<Dynamic> = cast n.value;
                var idx = int(child.name);
                if (idx != null) { hash.set(idx, child.value); true; } else false;
            default: // Dynamic is not ordered, so beforeChild is ignored
                Reflect.setField(n.value, child.name, child.value);
                Reflect.hasField(n.value, child.name);
        }
    }

    override public function removeChild(n: Wrapper, child: Wrapper) : Wrapper {
        if (n.isLeaf) return null;
        return switch (n.type) {
            case "Array":
                var arr: Array<Dynamic> = cast n.value;
                arr.remove(child.value) ? child : null;
            case "Hash":
                var hash: Hash<Dynamic> = cast n.value;
                hash.remove(child.name) ? child : null;
            case "IntHash":
                var hash: IntHash<Dynamic> = cast n.value;
                var idx = int(child.name);
                idx != null && hash.remove(idx) ? child : null;
            default:
                Reflect.deleteField(n.value, child.name) ? child : null;
        }
    }

    override public function empty(n: Wrapper) : Bool {
        if (n.isLeaf || n.parent == null) return false;
        var val: Dynamic = switch (n.type) {
            case "Array": cast [];
            case "Hash": cast new Hash<Dynamic>();
            case "IntHash": cast new IntHash<Dynamic>();
            default: cast {};
        }
        Reflect.setField(n.parent.value, n.name, val);
        return true;
    }

    override public function equals(n1: Wrapper, n2: Wrapper) : Bool {
        return n1 == null ? n2 == null : n2 == null ? false
            : n1.name == n2.name && n1.value == n2.value && equals(n1.parent, n2.parent);
    }

    override public function typeOf(n: Wrapper) : String {
        return n.name;
    }

    override public function idOf(n: Wrapper) : String {
        return n.name;
    }

    override public function hasClass(n: Wrapper, className: String) : Bool {
        className = className.replace("_", ".");
        var clz = Type.resolveClass(className);
        return clz != null ? Std.is(n.value, clz) : false;
    }

    override public function attributes(n: Wrapper) : Iterable<String> {
        if (n.isLeaf) return ATTR;
        var arr = Reflect.fields(n.value);
        return ATTR.concat(arr);
    }

    override public function hasAttr(n: Wrapper, name: String) {
        return switch (name) {
            case VALUE, TYPE: true;
            default: n.isLeaf ? false : Reflect.hasField(n.value, name);
        }
    }

    override public function getAttr(n: Wrapper, name: String) : Dynamic {
        return switch (name) {
            case VALUE: n.value;
            case TYPE: n.type;
            default: n.isLeaf ? null : Reflect.getProperty(n.value, name);
        }
    }

    override public function setAttr(n: Wrapper, name: String, value: Dynamic) : Void {
        if (!n.isLeaf && VALUE != name && TYPE != name) {
            Reflect.setProperty(n.value, name, value);
        }
    }

    override public function removeAttr(n: Wrapper, name: String) : Void {
        if (!n.isLeaf && VALUE != name && TYPE != name) {
            Reflect.deleteField(n.value, name);
        }
    }

    public static inline function wrapper(d: Dynamic, ?parent: Wrapper = null, ?name: String = "") : Wrapper {
        return new Wrapper(d, parent, name);
    }

    private static inline function int(s: String) : Null<Int> {
        return s.length > 1 && s.fastCodeAt(0) == "_".code ? Std.parseInt(s.substr(1)) : null;
    }

}

class Wrapper {
    public var parent: Wrapper;
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
            case TClass(clz):
                var cn = StringTools.replace(Type.getClassName(clz), ".", "_");
                isLeaf = "String" == cn;
                cn;
            case TObject: isLeaf = false; "Dynamic";
        }
    }

    private function toString() : String {
        return value.toString();
    }
}
