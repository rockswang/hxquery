package com.roxstudio.haxe.hxquery;

using StringTools;

class Selectors {

    public var group(default, null): Array<Selector>;
    public var input(default, null): String;

    private static inline var EOF = -1;

    private var pos: Int;
    private var len: Int;
    private var cur: Int;

    public function new(s: String) {
        this.input = s;
        this.group = [];
        pos = 0;
        len = s.length;
        cur = s.fastCodeAt(0);
        skipWs();
        group.push(selector());
        while (cur == ",".code) {
            next();
            skipWs();
            group.push(selector());
        }
        trace(">>" + group);
    }

    private inline function skipWs() {
        while (isWs(cur)) {
            next();
        }
    }

    private static inline function isWs(c: Int) {
        return c == " ".code || c == "\t".code || c == "\r".code || c == "\n".code;
    }

    private static inline function isIdStart(c: Int) {
        return c >= "A".code && c <= "Z".code || c >= "a".code && c <= "z".code || c == "_".code;
    }

    private inline function next() : Int {
        if (pos < len) {
            pos++;
            cur = pos < len ? input.fastCodeAt(pos) : EOF;
        } else throw "EOF";
        return cur;
    }

    private function ident() : String {
        if (!isIdStart(cur)) throw "error";
        next();
        var cnt = 1;
        while (isIdStart(cur) || cur >= "0".code && cur <= "9".code || cur == "-".code) {
            next();
            cnt++;
        }
        return input.substr(pos - cnt, cnt);
    }

    private function str() : String {
        var startc = cur;
        if (startc != "\"".code && startc != "'".code) throw "error";
        next();
        var cnt = 0;
        while (cur != startc) {
            next();
            cnt++;
        }
        next(); // skip quote
        return input.substr(pos - cnt - 1, cnt);
    }

    private function readUntil(c: Int) : String {
        var cnt = 0;
        while (cur != c) {
            next();
            cnt++;
        }
        return input.substr(pos - cnt, cnt);
    }

    private function selector() : Selector {
        var ret = new Selector();
        var first = true;
        while (cur != ",".code && cur != EOF) {
            var comb: Combinator = if (!first) {
                switch (cur) {
                    case ">".code: next(); skipWs(); Child;
                    case "+".code: next(); skipWs(); Adjacent;
                    case "~".code: next(); skipWs(); Sibling;
                    default: Descendent;
                }
            } else {
                first = false;
                null;
            }
            var seq: Sequence = simpleSeq();
            skipWs();
            ret.push({ combinator: comb, simpleSeq: seq });
        }
        return ret;
    }

    private function simpleSeq() : Sequence {
        var ret = new Sequence();
        while (!isWs(cur) && cur != ">".code && cur != "+".code && cur != "~".code
                && cur != ")".code && cur != ",".code && cur != EOF) {
            var s = simple(ret.length == 0, true);
            switch (s) {
                case Id(_): ret.insert(0, s);
                default: ret.push(s);
            }
        }
        return ret;
    }

    private function simple(first: Bool, not: Bool) : Simple {
        return switch (cur) {
            case "*".code:
                if (!first) throw "error";
                next();
                Universal;
            case "#".code:
                next();
                Id(ident());
            case ".".code:
                next();
                Class(ident());
            case "[".code:
                next();
                skipWs();
                var name = ident();
                skipWs();
                var op = switch (cur) {
                    case "]".code: Exists;
                    case "=".code: Equals;
                    case "^".code: if (next() != "=".code) throw "error"; PrefixMatch;
                    case "$".code: if (next() != "=".code) throw "error"; SuffixMatch;
                    case "*".code: if (next() != "=".code) throw "error"; SubstrMatch;
                    case "~".code: if (next() != "=".code) throw "error"; Includes;
                    case "|".code: if (next() != "=".code) throw "error"; DashMatch;
                }
                var val: String = if (op != Exists) {
                    next();
                    skipWs();
                    var str = str();
                    skipWs();
                    if (cur != "]".code) throw "error";
                    str;
                } else {
                    null;
                }
                next(); // skip ']'
                Attrib(name, op, val);
            case ":".code:
                next();
                var func = ident();
                var result: Simple = null;
                if (cur == "(".code) {
                    next();
                    skipWs();
                    switch (true) {
                        case func == "not":
                            if (!not) throw "error";
                            result = Not(simple(true, false));
                        case func.startsWith("nth-"):
                            var arg = readUntil(")".code).trim();
                            var ii = arg.indexOf("n");
                            var a = ii < 0 ? 0 : ii == 0 ? 1 : Std.parseInt(arg.substr(0, ii));
                            var b = ii < 0 ? Std.parseInt(arg) : Std.parseInt(arg.substr(ii + 1));
                            result = Nth(func, a, b);
                        default:
                            var arg = cur == "\"".code || cur == "'".code ? str() : readUntil(")".code).trim();
                            result = Pseudo(func, arg);
                    }
                    skipWs();
                    if (cur != ")".code) throw "error";
                    next(); // skip ')'
                } else {
                    result = Pseudo(func, null);
                }
                result;
            default:
                if (!first) throw "error";
                Type(ident());
        }
    }

}

enum AttribOp {
    Exists;
    Equals;
    Includes;
    PrefixMatch;
    SuffixMatch;
    SubstrMatch;
    DashMatch;
}

enum Combinator {
    Descendent;
    Child;
    Adjacent;
    Sibling;
}

enum Simple {
    Universal;
    Type(type: String);
    Id(id: String);
    Class(className: String);
    Attrib(name: String, op: AttribOp, value: String);
    Pseudo(func: String, arg: String);
    Nth(func: String, a: Int, b: Int);
    Not(selector: Simple);
}

typedef Sequence = Array<Simple>;

typedef Pair = { combinator: Combinator, simpleSeq: Sequence };

typedef Selector = Array<Pair>;


