package options;

import scripting.haxe.ScriptSpriteGroup;

import funkin.visuals.objects.Alphabet;

import openfl.display.Shape;
import openfl.display.BitmapData;

typedef OptionsOption =
{
    var name:String;

    var description:String;

    var type:String;

    @:optional var variable:String;

    @:optional var initialValue:Dynamic;

    @:optional var min:Float;
    @:optional var max:Float;
    @:optional var change:Float;
    @:optional var decimals:Int;

    @:optional var strings:Array<String>;

    @:optional var path:String;
    @:optional var scripted:Bool;
}

class BaseOption extends ScriptSpriteGroup
{
    public var bg:FlxSprite;

    public var mainText:Alphabet;

    public var cover:FlxSprite;

    public var groupIndex:Int = 0;

    public var selected(default, set):Bool = false;
    function set_selected(value:Bool):Bool
    {
        selected = value;

        if (cover != null)
            cover.alpha = selected ? 0 : 0.5;

        return selected;
    }

    public final data:OptionsOption;

    public function new(data:OptionsOption)
    {
        super();

        this.data = data;

        bg = roundSprite(FlxG.width * 0.85, 100, FlxColor.fromRGB(20, 20, 30));
        add(bg);

        mainText = new Alphabet(30, 0, data.name, false);
        add(mainText);
        mainText.scaleX = mainText.scaleY = 0.8;
        mainText.y = bg.y + bg.height / 2 - mainText.height / 2 - 45;

        for (let in mainText)
            let.colorTransform.redOffset = let.colorTransform.greenOffset = let.colorTransform.blueOffset = 255;

        cover = roundSprite(bg.width, bg.height, FlxColor.BLACK);
        add(cover);
        cover.alpha = 0;

        selected = false;
    }

    public function roundSprite(?w:Float, ?h:Float, ?color:FlxColor, ?ratio:Int):FlxSprite
    {
        var spr:FlxSprite = new FlxSprite();

        color ??= FlxColor.WHITE;
        ratio ??= 50;

        var shape:Shape = new Shape();
        shape.graphics.beginFill(FlxColor.WHITE);
        shape.graphics.drawRoundRect(0, 0, w, h, ratio, ratio);
        shape.graphics.endFill();

        var bpm:BitmapData = new BitmapData(w, h, true, FlxColor.TRANSPARENT);
        bpm.draw(shape);

        spr.pixels = bpm;
        spr.dirty = true;

        spr.color = color;

        return spr;
    }

    public function getVarVal():Dynamic
    {
        return Reflect.field(ClientPrefs.data, data.variable) ?? (Reflect.field(ClientPrefs.custom, data.variable) ?? data.initialValue);
    }

    public function setVarVal(value:Dynamic):Dynamic
    {
        Reflect.setField(Reflect.field(ClientPrefs.data, data.variable) == null ? ClientPrefs.custom : ClientPrefs.data, data.variable, value);

        return value;
    }
}