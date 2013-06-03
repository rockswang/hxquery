package com.roxstudio.haxe.hxquery;

import com.roxstudio.haxe.hxquery.HxQuery;
import com.roxstudio.haxe.hxquery.Selectors;

using StringTools;

class HxQuery<T> {

    public var elements(default, null): Array<T>;

    public var visitor(default, null): TreeVisitor<T>;

    public function new(elements: Array<T>, visitor: TreeVisitor<T>) {
        this.elements = elements;
        this.visitor = visitor;
    }

    public function iterator() : Iterator<T> {
        return elements.iterator();
    }

    public function select(selectors: String) : HxQuery<T> {
        return find(new Selectors(selectors));
    }

    public function find(selectors: Selectors) : HxQuery<T> {
        var found: Array<T> = [];
        for (selector in selectors.group) {
            found = found.concat(selectorFind(elements, selector));
        }
        return new HxQuery(found, visitor);
    }

    public function toString() {
        return dump();
    }

    public function dump(?toString: T -> String, ?indentStr: String = "  ") : String {
        var buf = new StringBuf();
        if (toString == null) toString = visitor.toString;
        for (n in elements) {
            dumpNode(n, buf, toString, indentStr, 0);
        }
        return buf.toString();
    }

    private function dumpNode(n: T, buf: StringBuf, toString: T -> String, indentStr: String, level: Int) {
        for (i in 0...level) buf.add(indentStr);
        buf.add(toString(n) + "\n");
        for (c in visitor.children(n)) {
            dumpNode(c, buf, toString, indentStr, level + 1);
        }
    }

    public function each(func: T -> Void) : HxQuery<T> {
        for (e in elements) func(e);
        return this;
    }

    public function map<S>(func: T -> S) : Array<S> {
        var ret: Array<S> = [];
        for (e in elements) ret.push(func(e));
        return ret;
    }

    public function filter(func: Int -> T -> Bool) : HxQuery<T> {
        var ret: Array<T> = [], idx = 0;
        for (e in elements) if (func(idx++, e)) ret.push(e);
        return visitor.createQuery(ret);
    }

// nth-child(a * n + b)
    public function nthChild(a: Int, b: Int) : HxQuery<T> {
        var ret: Array<T> = [], len = elements.length;
        if (a == 0) {
            if (b >= 0 && b < len) ret.push(elements[b]);
        } else {
            var n = 0, idx = 0;
            while ((idx = b + a * n++) < len) if (idx >= 0) ret.push(elements[idx]);
        }
        return visitor.createQuery(ret);
    }

    public function first() : HxQuery<T> {
        return nthChild(0, 0);
    }

    public function last() : HxQuery<T> {
        return nthChild(0, elements.length - 1);
    }

    public function even() : HxQuery<T> {
        return nthChild(2, 0);
    }

    public function odd() : HxQuery<T> {
        return nthChild(2, 1);
    }

    public function prepend(onCreate: T -> T) : HxQuery<T> {
        for (n in elements) {
            var c = onCreate(n);
            if (c != null) visitor.addChild(n, c, nextChild(n, null));
        }
        return this;
    }

    public function append(onCreate: T -> T) : HxQuery<T> {
        for (n in elements) {
            var c = onCreate(n);
            if (c != null) visitor.addChild(n, c, null);
        }
        return this;
    }

    public function before(onCreate: T -> T) : HxQuery<T> {
        for (n in elements) {
            var p = visitor.parent(n);
            if (p == null) continue;
            var c = onCreate(n);
            if (c != null) visitor.addChild(p, c, n);
        }
        return this;
    }

    public function after(onCreate: T -> T) : HxQuery<T> {
        for (n in elements) {
            var p = visitor.parent(n);
            if (p == null) continue;
            var c = onCreate(n);
            if (c != null) visitor.addChild(p, c, nextChild(p, n));
        }
        return this;
    }

    public function replace(onReplace: T -> T) : HxQuery<T> {
        for (n in elements) {
            var p = visitor.parent(n);
            if (p == null) continue;
            var c = onReplace(n);
            if (c != null) {
                visitor.addChild(p, c, n);
                visitor.removeChild(p, n);
            }
        }
        return this;
    }

    public function wrap(onWrap: T -> T) : HxQuery<T> {
        for (n in elements) {
            var p = visitor.parent(n);
            if (p == null) continue;
            var w = onWrap(n);
            if (w != null) {
                visitor.addChild(p, w, n);
                visitor.removeChild(p, n);
                visitor.addChild(w, n, null);
            }
        }
        return this;
    }

    public function remove(?onRemoved: T -> Void) : Void {
        for (n in elements) {
            var p = visitor.parent(n);
            if (p == null) continue;
            var removed = visitor.removeChild(p, n);
            if (removed != null && onRemoved != null) onRemoved(removed);
        }
    }

    public function empty() : HxQuery<T> {
        for (n in elements) visitor.empty(n);
        return this;
    }

    public function hasAttr(name: String) : Bool {
        return elements.length > 0 ? visitor.hasAttr(elements[0], name) : false;
    }

    public function getAttr(name: String) : Dynamic {
        return elements.length > 0 ? visitor.getAttr(elements[0], name) : null;
    }

    public function setAttr(name: String, value: Dynamic) : HxQuery<T> {
        for (e in elements) visitor.setAttr(e, name, value);
        return this;
    }

    public function removeAttr(name: String) : HxQuery<T> {
        for (e in elements) visitor.removeAttr(e, name);
        return this;
    }

    public static inline function inArray(str: String, arr: Array<String>) {
        var found = false;
        for (s in arr) if (s == str) { found = true; break; }
        return found;
    }

/********************************** private functions *************************************/

    private function selectorFind(input: Array<T>, selector: Selector) {
        var found = input;
        for (pair in selector) {
            var comb = pair.combinator;
            var seq = pair.simpleSeq;
            found = pairFind(found, comb, seq);
        }
        return found;
    }

    private function pairFind(input: Array<T>, comb: Combinator, seq: Sequence) {
        var output: Array<T> = [];
        if (comb == null) {
            for (c in input) if (sequenceMatch(c, 0, seq, 0)) output.push(c); // TODO
        }
        var recursive = comb == null || comb == Descendent, immediate = comb == Adjacent;
        for (n in input) {
            var target = n, fromNode: T = null;
            if (comb == Adjacent || comb == Sibling) {
                target = visitor.parent(n);
                if (target == null) continue;
                fromNode = visitor.ordered() ? n : null;
            }
            output = output.concat(sequenceFind(target, fromNode, immediate, recursive, seq));
        }
        return output;
    }

    private function sequenceFind(n: T, fromNode: T, immediate: Bool, recursive: Bool, seq: Sequence) {
        var found: Array<T> = [];
        switch (seq[0]) {
            case Id(id):
                var c = findById(n, id, recursive);
                if (c != null && (seq.length == 1 || sequenceMatch(c, 0, seq, 1))) found.push(c);
            default:
                var cnt = 0, idx = 0;
                for (c in visitor.children(n)) {
                    if (fromNode != null) {
                        if (visitor.equals(fromNode, c)) fromNode = null;
                    } else {
                        if (immediate && cnt > 0) break;
                        if (sequenceMatch(c, idx, seq, 0)) {
                            found.push(c);
                            if (immediate) break;
                        }
                        cnt++;
                        if (recursive) found = found.concat(sequenceFind(c, null, false, true, seq));
                    }
                    idx++;
                }
        }
        return found;
    }

    private inline function sequenceMatch(n: T, idx: Int, seq: Sequence, fromIdx: Int) : Bool {
        var match = true;
        for (i in fromIdx...seq.length) if (!simpleMatch(n, idx, seq[i])) { match = false; break; }
        return match;
    }

    private function findById(n: T, id: String, recursive: Bool) : T {
        var result = visitor.childForId(n, id);
        if (result == null && recursive) {
            for (c in visitor.children(n)) {
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
                    case Exists: visitor.hasAttr(n, name);
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
                    case "only-child":
                        var p = visitor.parent(n);
                        idx == 0 && p != null && visitor.size(p) == 1;
                    case "empty": visitor.size(n) == 0;
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
        var val = visitor.getAttr(n, name);
        return val != null ? "" + val : "";
    }

    private inline function nextChild(n: T, child: T) : T {
        var it = visitor.children(n);
        if (child != null) for (c in it) { if (visitor.equals(c, child)) break; }
        return it.iterator().hasNext() ? it.iterator().next() : null;
    }

}
