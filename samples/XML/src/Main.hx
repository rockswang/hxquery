import StringTools;
import com.roxstudio.haxe.hxquery.TreeVisitor;
import com.roxstudio.haxe.hxquery.XmlVisitor;
import com.roxstudio.haxe.hxquery.HxQuery;
import #if openfl flash #else nme #end.events.MouseEvent;
import #if openfl openfl #else nme #end.Assets;
import #if openfl flash #else nme #end.text.TextFormat;
import #if openfl flash #else nme #end.text.TextField;
import #if openfl flash #else nme #end.text.TextFieldType;
import #if openfl flash #else nme #end.display.Sprite;
import #if openfl flash #else nme #end.Lib;

using StringTools;

#if haxe3
private typedef Hash<T> = Map<String, T>;
#end

class Main extends Sprite {

    private var selected: Array<Xml>;
    private var v: TreeVisitor<Xml>;

    public function new() {
        super();
        var stage = Lib.current.stage;
        var width = stage.stageWidth;
        var height = stage.stageHeight;
        selected = [];

        var xhtml = Xml.parse(Assets.getText("res/sample.xhtml"));
        var input = [ xhtml ];
        v = new XmlVisitor();
        v.createQuery(input).select("pcdata").filter(function(idx: Int, n: Xml) : Bool {
            return n.nodeValue.trim().length == 0;
        }).remove();

        var tf = text(0, 12, false, true, width, height - 30);
        tf.text = v.createQuery(input).dump(); //xmlToString);
//        trace(tf.text);
        stage.addChild(tf);

        var inp = text(0, 16, true, false, width - 100, 20);
        var inpWrap = new Sprite();
        inpWrap.addChild(inp);
        inpWrap.graphics.lineStyle(1, 0);
        inpWrap.graphics.drawRect(0, 0, width - 20, 20);
        inpWrap.x = 0;
        inpWrap.y = height - 22;
        inp.text = "body > ul > li";
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
            var nodes: HxQuery<Xml> = v.createQuery(input).select(inp.text);
            selected = nodes.elements.copy();
//            var title = v.createQuery(input).select("#title").elements[0];
            tf.text = v.createQuery(input).dump(xmlToString);
//            var cmp: Xml -> Xml -> Bool = Reflect.field(Xml, "compare");
//            for (x in selected) {
//                var aa: Bool = cmp(x, title);
//                trace("aa=" + aa);
//            }
//            trace("result=" + nodes);
        });
        btn.x = width - 80;
        btn.y = height - 22;
        stage.addChild(btn);

    }

    private function xmlToString(xml: Xml) : String {
        var list = Lambda.filter(selected, function(n1) {
            return v.equals(xml, n1);
        });
        var sel = list.length > 0;

//        var sel = Lambda.has(selected, xml, function(n1: Xml, n2: Xml) : Bool {
//            return v.equals(n1, n2);
//        });
        return sel ? "[ " + v.toString(xml) + " ]" : v.toString(xml);
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

    public static function main() {
        new Main();
    }

}
