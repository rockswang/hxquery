package com.roxstudio.haxe.hxquery;

import nme.display.DisplayObject;

class DisplayListQuery {

    public static var query = new HxQuery(new DisplayListVisitor());

    public static inline function find(selectors: String, ?target: DisplayObject) : Array<DisplayObject> {
        if (target == null) target = nme.Lib.current.stage;
        return query.find(target, selectors);
    }

    public static inline function move(elements: Array<DisplayObject>, x: Float, y: Float) : Array<DisplayObject> {
        for (e in elements) {
            e.x = x;
            e.y = y;
        }
        return elements;
    }

    public static inline function translate(elements: Array<DisplayObject>, dx: Float, dy: Float) : Array<DisplayObject> {
        for (e in elements) {
            e.x += dx;
            e.y += dy;
        }
        return elements;
    }

    public static inline function scale(elements: Array<DisplayObject>, scaleX: Float, ?scaleY: Null<Float>) : Array<DisplayObject> {
        if (scaleY == null) scaleY = scaleX;
        for (e in elements) {
            e.scaleX = scaleX;
            e.scaleY = scaleY;
        }
        return elements;
    }

    public static inline function rotate(elements: Array<DisplayObject>, angle: Float) : Array<DisplayObject> {
        for (e in elements) {
            e.rotation = angle;
        }
        return elements;
    }

    public static inline function alpha(elements: Array<DisplayObject>, alpha: Float) : Array<DisplayObject> {
        for (e in elements) {
            e.alpha = alpha;
        }
        return elements;
    }

}
