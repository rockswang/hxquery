package com.roxstudio.haxe.hxquery;

import #if openfl flash #else nme #end.display.DisplayObject;
import #if openfl flash #else nme #end.Lib;

class DisplayListQuery extends HxQuery<DisplayObject> {

    public function new(?elements: Array<DisplayObject>, visitor: TreeVisitor<DisplayObject>) {
        super(elements != null ? elements : [ cast Lib.current.stage ], visitor);
    }

    public function move(x: Float, y: Float) : DisplayListQuery {
        for (e in elements) {
            e.x = x;
            e.y = y;
        }
        return this;
    }

    public function translate(dx: Float, dy: Float) : DisplayListQuery {
        for (e in elements) {
            e.x += dx;
            e.y += dy;
        }
        return this;
    }

    public function scale(scaleX: Float, ?scaleY: Null<Float>) : DisplayListQuery {
        if (scaleY == null) scaleY = scaleX;
        for (e in elements) {
            e.scaleX = scaleX;
            e.scaleY = scaleY;
        }
        return this;
    }

    public function rotate(angle: Float) : DisplayListQuery {
        for (e in elements) {
            e.rotation = angle;
        }
        return this;
    }

    public function alpha(alpha: Float) : DisplayListQuery {
        for (e in elements) {
            e.alpha = alpha;
        }
        return this;
    }

}
