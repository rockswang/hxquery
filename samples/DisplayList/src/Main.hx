import com.roxstudio.haxe.hxquery.DisplayListQuery;
import #if openfl flash #else nme #end.events.MouseEvent;
import com.roxstudio.haxe.hxquery.DisplayListVisitor;
import com.roxstudio.haxe.hxquery.HxQuery;
import com.roxstudio.haxe.hxquery.TreeVisitor;

import #if openfl flash #else nme #end.display.DisplayObject;
import #if openfl flash #else nme #end.text.TextFormat;
import #if openfl flash #else nme #end.text.TextField;
import #if openfl flash #else nme #end.text.TextFieldType;
import #if openfl flash #else nme #end.display.Sprite;
import #if openfl flash #else nme #end.Lib;

class Main extends Sprite {

    public function new() {
        super();
        var stage = Lib.current.stage;
        var width = stage.stageWidth;
        var height = stage.stageHeight;
        var root = new Circle(150, 0xFF0000);
        root.x = width / 2;
        root.y = height / 2;
        root.update(false);
        stage.addChild(root);
        randomAdd(root, 80, 3);

        var input = [ cast (stage, DisplayObject) ];
        var v: TreeVisitor<DisplayObject> = new DisplayListVisitor();

        var tf = text(0, 12, false, true, width, height - 30);
        tf.text = v.createQuery(input).toString();
        stage.addChild(tf);

        var inp = text(0, 16, true, false, width - 100, 20);
        var inpWrap = new Sprite();
        inpWrap.addChild(inp);
        inpWrap.graphics.lineStyle(1, 0);
        inpWrap.graphics.drawRect(0, 0, width - 20, 20);
        inpWrap.x = 0;
        inpWrap.y = height - 22;
        inp.text = "Stage Circle";
        stage.addChild(inpWrap);

        var btn = new Sprite();
        btn.mouseEnabled = true;
        btn.graphics.lineStyle(1, 0);
        btn.graphics.beginFill(0x0000FF);
        btn.graphics.drawRect(0, 0, 80, 20);
        var btnLabel = text(0, 12, false, true, 50, 20);
        btnLabel.text = "Select";
        btnLabel.x = (80 - btnLabel.textWidth) / 2;
        btnLabel.y = (20 - btnLabel.textHeight) / 2;
        btn.addChild(btnLabel);
        btn.addEventListener(MouseEvent.CLICK, function(_) {
            v.createQuery(input).select("*.Base").each(function(n: DisplayObject) {
                cast(n, Base).update(false);
            });
            var q = v.createQuery(input).select(inp.text).filter(function(_, n: DisplayObject) {
                return Std.is(n, Base);
            }).each(function(n: DisplayObject) {
                cast(n, Base).update(true);
            });
            cast(q, DisplayListQuery).wrap(function(n: DisplayObject) {
                var sp = new Sprite();
                sp.graphics.beginFill(0xFF0000, 0.5);
                sp.graphics.drawRect(n.x, n.y, 100, 100);
                return sp;
            });
        });
        btn.x = width - 80;
        btn.y = height - 22;
        stage.addChild(btn);

    }

    private static function text(color: Int, size: Float, input: Bool, multiline: Bool, width: Float, height: Float) : TextField {
        var tf = new TextField();
        tf.selectable = tf.mouseEnabled = input;
        if (input) tf.type = TextFieldType.INPUT;
        tf.defaultTextFormat = textFormat(color, size);
        tf.multiline = tf.wordWrap = multiline;
        tf.width = width;
        tf.height = height;
        tf.x = tf.y = 0;
        return tf;
    }

    private static function textFormat(color: Int, size: Float) : TextFormat {
        var format = new TextFormat();
#if android
        format.font = new nme.text.Font("/system/fonts/DroidSansFallback.ttf").fontName;
//#else
//        format.font = "Microsoft YaHei";
#end
        format.color = color;
        format.size = Std.int(size);
        return format;
    }
    private function randomAdd(n: Base, r: Float, level: Int) {
        if (level == 0) return;
        for (i in 0...level) {
            var shape = switch (Std.random(4)) {
                case 0: new Circle(r, Std.random(0xFFFFFF));
                case 1: new Square(r, Std.random(0xFFFFFF));
                case 2: new Round(r, Std.random(0xFFFFFF));
                case 3: new Triangle(r, Std.random(0xFFFFFF));
                case _: null;
            }
            n.addChild(shape);
            shape.move();
            shape.update(false);
            randomAdd(shape, r * 0.5, level - 1);
        }
    }

    public static function main() {
        new Main();
    }

}

class Base extends Sprite {
    public static var globalCnt = 0;
    public var r: Float;
    public var color: Int;
    public function new(r: Float, color: Int) {
        super();
        this.r = r;
        this.color = color;
        this.alpha = 0.9;
    }

    public function move() {
        var dist = 2.5 * r;
        var angle = Math.random() * 2 * Math.PI;
        x = dist * Math.sin(angle);
        y = dist * Math.cos(angle);
    }

    public function update(select: Bool) {
        this.alpha = 0.9;
        this.graphics.clear();
        this.graphics.beginFill(color);
        paint();
        this.graphics.endFill();
        if (Std.is(parent, Base)) {
            this.graphics.lineStyle(1, color);
            this.graphics.moveTo(0, 0);
            this.graphics.lineTo(-x, -y);
        }
        if (select) {
            this.graphics.lineStyle(1, 0);
            this.graphics.drawRect(-r - 3, -r - 3, 2 * r + 6, 2 * r + 6);
        }
    }

    private function paint() {}
}

interface ISmooth {}

class Square extends Base {
    public function new(r: Float, color: Int) {
        super(r, color);
        this.name = "square" + Base.globalCnt++;
    }
    override private function paint() {
        this.graphics.drawRect(-r, -r, 2 * r, 2 * r);
    }
}

#if haxe3
class Circle extends Base implements ISmooth {
#else
class Circle extends Base, implements ISmooth {
#end
    public function new(r: Float, color: Int) {
        super(r, color);
        this.name = "circle" + Base.globalCnt++;
    }
    override private function paint() {
        this.graphics.drawCircle(0, 0, r);
    }
}

class Triangle extends Base {
    private static var rx = Math.cos(Math.PI / 6);
    private static var ry = Math.sin(Math.PI / 6);
    public function new(r: Float, color: Int) {
        super(r, color);
        this.name = "triangle" + Base.globalCnt++;
    }
    override private function paint() {
        this.graphics.moveTo(0, -r);
        this.graphics.lineTo(r * Triangle.rx, r * Triangle.ry);
        this.graphics.lineTo(-r * Triangle.rx, r * Triangle.ry);
        this.graphics.lineTo(0, -r);
    }
}

#if haxe3
class Round extends Square implements ISmooth {
#else
class Round extends Square, implements ISmooth {
#end
    public function new(r: Float, color: Int) {
        super(r, color);
        this.name = "round" + Base.globalCnt++;
    }
    override private function paint() {
        this.graphics.drawRoundRect(-r, -r, 2 * r, 2 * r, 15, 15);
    }
}
