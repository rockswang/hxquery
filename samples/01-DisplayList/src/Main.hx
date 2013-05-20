import Main.Triangle;
import nme.events.MouseEvent;
import nme.display.SimpleButton;
import com.roxstudio.haxe.hxquery.DisplayListVisitor;
import com.roxstudio.haxe.hxquery.HxQuery;
import com.roxstudio.haxe.hxquery.TreeVisitor;

import nme.display.DisplayObject;
import nme.text.TextFormat;
import nme.text.TextField;
import nme.display.Sprite;

class Main extends Sprite {

    public function new() {
        super();
        var stage = nme.Lib.current.stage;
        var width = stage.stageWidth;
        var height = stage.stageHeight;
        var root = new Circle(150, 0xFF0000);
        root.x = width / 2;
        root.y = height / 2;
        root.update(false);
        stage.addChild(root);
        randomAdd(root, 80, 3);

        var input = stage;
        var v: TreeVisitor<DisplayObject> = new DisplayListVisitor();
        var query = new HxQuery(v);
//        var found: Array<DisplayObject> = query.find(input, "MySprite > TextField:nth-child(2)");
        var tf = new TextField();
        tf.selectable = false;
        tf.mouseEnabled = false;
        tf.defaultTextFormat = textFormat(0, 12);
        tf.multiline = tf.wordWrap = true;
        tf.width = width;
        tf.height = height - 20;
        tf.x = tf.y = 0;
        var buf = new StringBuf();
        tf.text = query.dump(input, buf).toString();
        stage.addChild(tf);

        var inp = new TextField();
        inp.selectable = true;
        inp.mouseEnabled = true;
        inp.type = nme.text.TextFieldType.INPUT;
        inp.defaultTextFormat = textFormat(0, 12);
        inp.multiline = inp.wordWrap = false;
        inp.width = width - 100;
        inp.height = 20;
        inp.x = 0;
        inp.y = height - 20;
        var buf = new StringBuf();
        inp.text = "Stage Circle";
        stage.addChild(inp);

        var btn = new Sprite();
        btn.mouseEnabled = true;
        btn.graphics.lineStyle(3, 0);
        btn.graphics.beginFill(0x0000FF);
        btn.graphics.drawRoundRect(0, 0, 80, 20, 6);
        btn.addEventListener(MouseEvent.CLICK, function(_) {
            var nodes: Array<DisplayObject> = query.find(stage, "*.Base");
            for (n in nodes) {
                cast(n, Base).update(false);
            }
            nodes = query.find(stage, inp.text);
            for (n in nodes) {
                if (Std.is(n, Base)) cast(n, Base).update(true);
            }
        });
        btn.x = width - 80;
        btn.y = height - 20;
        stage.addChild(btn);

    }

    public static inline function textFormat(color: Int, size: Float) : TextFormat {
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
    }

    public function move() {
        var dist = 2.5 * r;
        var angle = Math.random() * 2 * Math.PI;
        x = dist * Math.sin(angle);
        y = dist * Math.cos(angle);
    }

    public function update(select: Bool) {
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

class Square extends Base {
    public function new(r: Float, color: Int) {
        super(r, color);
        this.name = "square" + Base.globalCnt++;
    }
    override private function paint() {
        this.graphics.drawRect(-r, -r, 2 * r, 2 * r);
    }
}

class Circle extends Base {
    public function new(r: Float, color: Int) {
        super(r, color);
        this.name = "circle" + Base.globalCnt++;
    }
    override private function paint() {
        this.graphics.drawCircle(0, 0, r);
    }
}

class Triangle extends Base {
    private static inline var rx = Math.cos(Math.PI / 6);
    private static inline var ry = Math.sin(Math.PI / 6);
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

class Round extends Square {
    public function new(r: Float, color: Int) {
        super(r, color);
        this.name = "round" + Base.globalCnt++;
    }
    override private function paint() {
        this.graphics.drawRoundRect(-r, -r, 2 * r, 2 * r, 15, 15);
    }
}
