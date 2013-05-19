package com.roxstudio.haxe.hxquery;

import nme.display.Shape;
import nme.display.DisplayObjectContainer;
import nme.display.DisplayObject;

using StringTools;

class DisplayListVisitor implements TreeVisitor<DisplayObject> {

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

    public function parent(n: DisplayObject) : DisplayObject {
        return n.parent;
    }

    public function childAt(n: DisplayObject, index: Int) : DisplayObject {
        var dc = asDc(n);
        return dc != null ? dc.getChildAt(index) : null;
    }

    public function childForId(n: DisplayObject, id: String) : DisplayObject {
        var dc = asDc(n);
        return dc != null ? dc.getChildByName(id) : null;
    }

    public function length(n: DisplayObject) : Int {
        var dc = asDc(n);
        return dc != null ? dc.numChildren : 0;
    }

    public function indexOf(n: DisplayObject, child: DisplayObject) : Int {
        var dc = asDc(n);
        return dc != null ? dc.getChildIndex(child) : -1;
    }

    public function typeOf(n: DisplayObject) : String {
        var name = Type.getClassName(Type.getClass(n));
        var idx = name.lastIndexOf(".");
        return idx > 0 ? name.substr(idx + 1) : name;
    }

    public function idOf(n: DisplayObject) : String {
        return n.name;
    }

    /*
     * className: as in CSS syntax, all '.' in full-qualified classname must be replaced by '_'
     */
    public function hasClass(n: DisplayObject, className: String) : Bool {
        var fullname = classMap.get(className);
        if (fullname == null) fullname = className.replace("_", ".");
        var clz = Type.resolveClass(fullname);
        return clz != null ? Std.is(n, clz) : false;
    }

    public function attribute(n: DisplayObject, name: String) : Dynamic {
        return Reflect.getProperty(n, name);
    }

    public function hasAttribute(n: DisplayObject, name: String) : Bool {
        return Reflect.hasField(n, name);
    }

    public function setAttribute(n: DisplayObject, name: String, value: Dynamic) : Void {
        Reflect.setProperty(n, name, value);
    }

    private inline function asDc(n: DisplayObject) : DisplayObjectContainer {
        return Std.is(n, DisplayObjectContainer) ? cast n : null;
    }

}
