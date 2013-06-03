package com.roxstudio.haxe.hxquery;

import com.roxstudio.haxe.hxquery.AbstractVisitor;
import nme.display.Shape;
import nme.display.DisplayObjectContainer;
import nme.display.DisplayObject;

using StringTools;

class DisplayListVisitor extends AbstractVisitor<DisplayObject> {

    private static var sysClasses = [
        "Bitmap",
        "DisplayObject",
        "DisplayObjectContainer",
        "Loader",
        "MovieClip",
        "Shape",
        "SimpleButton",
        "Sprite",
        "Stage",
        "TextField"
    ];

    private var classMap: Hash<String>;
    private static var pkgName: String;

    public function new() {
        super();
        if (pkgName == null) {
            var shapeClass = Type.getClassName(Type.getClass(new Shape()));
            pkgName = shapeClass.substr(0, shapeClass.lastIndexOf(".") + 1);
        }
        classMap = new Hash<String>();
        for (c in sysClasses) regClass(pkgName + c, c);
    }

    public inline function regClass(fullName: String, ?shortName: String) {
        if (shortName == null) {
            var idx = fullName.lastIndexOf(".");
            shortName = idx >= 0 ? fullName.substr(idx + 1) : fullName;
        }
        classMap.set(shortName, fullName);
    }

    override public function ordered() : Bool {
        return true;
    }

    override public function parent(n: DisplayObject) : DisplayObject {
        return n.parent;
    }

    override public function children(n: DisplayObject) : Iterable<DisplayObject> {
        var dc = asDc(n);
        var i = 0, len = dc != null ? dc.numChildren : 0;
        return dc == null ? cast [] : {
            iterator: function() {
                return cast {
                    hasNext: function() { return i < len; },
                    next: function() { return dc.getChildAt(i++); }
                }
            }
        }
    }

    override public function childForId(n: DisplayObject, id: String) : DisplayObject {
        var dc = asDc(n);
        return dc != null ? dc.getChildByName(id) : null;
    }

    override public function addChild(n: DisplayObject, child: DisplayObject, beforeChild: DisplayObject) : Bool {
        var dc = asDc(n);
        if (dc == null) return false;
        if (beforeChild == null) {
            dc.addChild(child);
        } else {
            var idx = dc.getChildIndex(beforeChild);
            if (idx < 0) return false;
            dc.addChildAt(child, idx);
        }
        return true;
    }

    override public function removeChild(n: DisplayObject, child: DisplayObject) : DisplayObject {
        var dc = asDc(n);
        return dc != null ? dc.removeChild(child) : null;
    }

    override public function empty(n: DisplayObject) : Bool {
        var dc = asDc(n);
        if (dc != null) while (dc.numChildren > 0) { dc.removeChildAt(0); }
        return true;
    }

    override public function size(n: DisplayObject) : Int {
        var dc = asDc(n);
        return dc != null ? dc.numChildren : 0;
    }

    override public function typeOf(n: DisplayObject) : String {
        var name = Type.getClassName(Type.getClass(n));
        var idx = name.lastIndexOf(".");
        return idx > 0 ? name.substr(idx + 1) : name;
    }

    override public function idOf(n: DisplayObject) : String {
        return n.name;
    }

    /*
     * className: as in CSS syntax, all '.' in full-qualified classname must be replaced by '_'
     */
    override public function hasClass(n: DisplayObject, className: String) : Bool {
        var fullname = classMap.get(className);
        if (fullname == null) fullname = className.replace("_", ".");
        var clz = Type.resolveClass(fullname);
        return clz != null ? Std.is(n, clz) : false;
    }

    override public function attributes(n: DisplayObject) : Iterable<String> {
        var arr = Reflect.fields(n);
        arr.insert(0, "id");
        return arr;
    }

    override public function hasAttr(n: DisplayObject, name: String) : Bool {
        return "id" == name || Reflect.hasField(n, name);
    }

    override public function getAttr(n: DisplayObject, name: String) : Dynamic {
        return "id" == name ? n.name : Reflect.getProperty(n, name);
    }

    override public function setAttr(n: DisplayObject, name: String, value: Dynamic) : Void {
        if ("id" == name) name = "name";
        Reflect.setProperty(n, name, value);
    }

    override public function removeAttr(n: DisplayObject, name: String) : Void {
        Reflect.deleteField(n, name);
    }

    override public function createQuery(elements: Array<DisplayObject>) : HxQuery<DisplayObject> {
        return new DisplayListQuery(elements, this);
    }

    private inline function asDc(n: DisplayObject) : DisplayObjectContainer {
        return Std.is(n, DisplayObjectContainer) ? cast n : null;
    }

}
