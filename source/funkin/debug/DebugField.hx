package funkin.debug;

import core.structures.DebugFieldText;
import core.structures.DebugFieldTextLine;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import openfl.text.TextFormat;

import flixel.util.FlxColor;

class DebugField extends Sprite
{
    public var labels:Array<DebugText> = [];

    public var bg:Bitmap;

    public function new(infos:Array<DebugFieldText>)
    {
        super();

        bg = new Bitmap(new BitmapData(1, 1, FlxColor.BLACK));
        addChild(bg);
        bg.alpha = 0.5;

        for (field in infos)
            createLabel(getText(field.lines), field.size, field.color is String ? FlxColor.fromString(field.color) : field.color, field.offset);
        
        updateBG();
    }

    function getText(data:Array<DebugFieldTextLine>):Void -> String
    {
        var funcs:Array<Void -> String> = [];

        for (field in data)
        {
            switch (field.type)
            {
                case TEXT:
                    final val = field.value;
                    
                    funcs.push(() -> val);
                case VARIABLE:
                    funcs.push(getFunction(field.path, field.variable));
            }
        }

        return () -> {
            var str:String = '';

            for (func in funcs)
                str += func();

            return str;
        };
    }

    function getFunction(daClass:String, daVar:String):Void -> String
    {
        if (daClass.length <= 0)
            return () -> '';

        var obj:Dynamic = Type.resolveClass(daClass);

        if (obj == null)
            return function() return daClass + '.' + daVar;
        
        return () -> getRecursiveProperty(obj, daVar.split('.'));
    }

    function getRecursiveProperty(instance:Dynamic, split:Array<String>):Dynamic
    {
        var result:Dynamic = instance;

        for (part in split)
        {
            result = Reflect.getProperty(result, part);

            if (result == null)
                return null;
        }

        return result;
    }

    @:unreflective private var offset:Float = 2.5;

    function createLabel(func:Void -> String, ?size:Int = 15, ?color:FlxColor = FlxColor.WHITE, ?off:Float = 0)
    {
        var label:DebugText = new DebugText(func);
        label.defaultTextFormat = new TextFormat(Paths.font('jetbrains.ttf'), size, color);
        label.x = 10;
        label.y = offset + off;

        addChild(label);

        labels.push(label);

        offset += label.height + off;
    }

    public function updateBG()
    {
        var scaleX:Float = 0;

        for (label in labels)
            if (label.width > scaleX)
                scaleX = label.width;

        scaleX += 20;

        var scaleY:Float = offset + 10;

        bg.scaleX = scaleX;
        bg.scaleY = scaleY;
    }

    override function __enterFrame(time:Int)
    {   
        if (!visible)
            return;

        super.__enterFrame(time);

        updateBG();
    }
}