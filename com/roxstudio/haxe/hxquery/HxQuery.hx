package com.roxstudio.haxe.hxquery;

import com.roxstudio.haxe.hxquery.Selectors;

using StringTools;

class HxQuery<T> {

    private var visitor: TreeVisitor<T>;

    public function new(treeAccess: TreeVisitor<T>) {
        this.visitor = treeAccess;
    }

    public inline function find(n: T, selectors: String) : Array<T> {
        return findBySelectors(n, new Selectors(selectors));
    }

    public function findBySelectors(n: T, selectors: Selectors) : Array<T> {
        var found: Array<T> = [];
        for (selector in selectors.group) {
            found = found.concat(selectorFind(n, selector));
        }
        return found;
    }

    public function print(n: T) {
        var buf = new StringBuf();
        trace(dump(n, buf, 0));
    }

    private function dump(n: T, buf: StringBuf, indent: Int = 0) {
        for (i in 0...indent) buf.add("  ");
        var nstr: String = "" + n;
        if (nstr.length > 20) nstr = nstr.substr(0, 17) + "...";
        buf.add(visitor.typeOf(n) + "(#" + visitor.idOf(n) + ")-{" + nstr + "}\n");
        for (i in 0...visitor.length(n)) {
            var c = visitor.childAt(n, i);
            if (c == null) continue;
            dump(c, buf, indent + 1);
        }
        return buf;
    }

    private function selectorFind(n: T, selector: Selector) {
        var found: Array<T> = [ n ];
        for (pair in selector) {
            var comb = pair.combinator == null ? Descendent : pair.combinator;
            var seq = pair.simpleSeq;
            found = pairFind(found, comb, seq);
        }
        return found;
    }

    private function pairFind(input: Array<T>, comb: Combinator, seq: Sequence) {
        var output: Array<T> = [];
        var recursive = comb == Descendent, immediate = comb == Adjacent;
        for (n in input) {
            var target = n, fromIdx = 0;
            if (comb == Adjacent || comb == Sibling) {
                if (visitor.parent(n) == null) continue;
                target = visitor.parent(n);
                fromIdx = visitor.indexOf(target, n) + 1;
            }
            output = output.concat(sequenceFind(target, fromIdx, immediate, recursive, seq));
        }
        return output;
    }

    private function sequenceFind(n: T, fromIdx: Int, immediate: Bool, recursive: Bool, seq: Sequence) {
        var found: Array<T> = [];
        switch (seq[0]) {
            case Id(id):
                var c = findById(n, id, recursive);
                if (c != null && (seq.length == 1 || sequenceMatch(c, 0, seq, 1))) found.push(c);
            default:
                for (i in fromIdx...(immediate ? fromIdx + 1 : visitor.length(n))) {
                    var c = visitor.childAt(n, i);
                    if (c == null) continue;
                    if (sequenceMatch(c, i, seq, 0)) found.push(c);
                    if (recursive) found = found.concat(sequenceFind(c, 0, false, true, seq));
                }
        }
        return found;
    }

    private inline function sequenceMatch(n: T, idx: Int, seq: Sequence, fromIdx: Int) {
        var match = true;
        for (i in fromIdx...seq.length) if (!simpleMatch(n, idx, seq[i])) { match = false; break; }
        return match;
    }

    private function findById(n: T, id: String, recursive: Bool) : T {
        var result = visitor.childForId(n, id);
        if (result == null && recursive) {
            for (i in 0...visitor.length(n)) {
                var c = visitor.childAt(n, i);
                result = findById(c, id, true);
                if (result != null) break;
            }
        }
        return result;
    }

    private function simpleMatch(n: T, idx: Int, simple: Simple) : Bool {
        return switch (simple) {
            case Id(id): false; // should not happen
            case Universal: true;
            case Type(type): visitor.typeOf(n) == type;
            case Class(clz): visitor.hasClass(n, clz);
            case Attrib(name, op, value):
                switch (op) {
                    case Exists: visitor.hasAttribute(n, name);
                    case Equals: attrStr(n, name) == value;
                    case Includes: inArray(value, attrStr(n, name).split(" "));
                    case DashMatch: inArray(value, attrStr(n, name).split("-"));
                    case PrefixMatch: attrStr(n, name).startsWith(value);
                    case SuffixMatch: attrStr(n, name).endsWith(value);
                    case SubstrMatch: attrStr(n, name).indexOf(value) >= 0;
                }
            case Pseudo(name, arg):
                switch (name) {
                    case "odd": idx % 2 == 1;
                    case "even": idx % 2 == 0;
                    case "only-child": var p: T; idx == 0 && (p = visitor.parent(n)) != null && visitor.length(p) == 1;
                    case "empty": visitor.length(n) == 0;
                    case "eq": idx == Std.parseInt(arg);
                    case "gt": idx > Std.parseInt(arg);
                    case "lt": idx < Std.parseInt(arg);
                    default: false;
                }
            case Nth(name, a, b):
                (idx - b) % a == 0;
            case Not(arg): !simpleMatch(n, idx, arg);
        }
    }

    private inline function attrStr(n: T, name: String) : String {
        var val = visitor.attribute(n, name);
        return val != null ? val.toString() : "";
    }

    public static inline function inArray(str: String, arr: Array<String>) {
        var found = false;
        for (s in arr) {
            if (s == str) { found = true; break; }
        }
        return found;
    }

/********************************** Routines *************************************/

    public static inline function each<T>(elements: Array<T>, func: T -> Void) : Array<T> {
        for (e in elements) func(e);
        return elements;
    }

    public static inline function map<T, S>(elements: Array<T>, func: T -> S) : Array<S> {
        var ret: Array<S> = [];
        for (e in elements) ret.push(func(e));
        return ret;
    }

    // nth-child(a * n + b)
    public static inline function nth<T>(elements: Array<T>, a: Int, b: Int) : Array<T> {
        var ret: Array<T> = [], len = elements.length;
        if (a == 0) {
            if (b >= 0 && b < len) ret.push(elements[b]);
        } else {
            var n = 0, idx = 0;
            while ((idx = b + a * n++) < len) if (idx >= 0) ret.push(elements[idx]);
        }
        return ret;
    }

    public static inline function first<T>(elements: Array<T>) : Array<T> {
        return nth(elements, 0, 0);
    }

    public static inline function last<T>(elements: Array<T>) : Array<T> {
        return nth(elements, 0, elements.length - 1);
    }

    public static inline function even<T>(elements: Array<T>) : Array<T> {
        return nth(elements, 2, 0);
    }

    public static inline function odd<T>(elements: Array<T>) : Array<T> {
        return nth(elements, 2, 1);
    }

    public static inline function attr<T>(elements: Array<T>, name: String, visitor: TreeVisitor<T>) : Dynamic {
        return elements.length > 0 ? visitor.attribute(elements[0], name) : null;
    }

    public static inline function setAttr<T>(elements: Array<T>, name: String, value: Dynamic, visitor: TreeVisitor<T>) : Array<T> {
        for (e in elements) visitor.setAttribute(e, name, value);
        return elements;
    }

}
