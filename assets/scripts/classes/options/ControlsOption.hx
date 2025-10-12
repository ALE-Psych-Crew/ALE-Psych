package options;

import scripting.haxe.ScriptSpriteGroup;

import funkin.visuals.objects.Alphabet;

import flixel.input.keyboard.FlxKey;
import flixel.effects.FlxFlicker;

class ControlsOption extends ScriptSpriteGroup
{
    public var group:String;
    public var variable:String;

    public var bg:FlxSprite;
    public var sel:FlxSprite;

    public var isFirst(default, set):Bool;
    function set_isFirst(value:Bool):Bool
    {
        isFirst = value;

        if (sel != null && bg != null)
            sel.x = this.x + bg.width / 3 * (isFirst ? 1 : 2);

        return isFirst;
    }

    public var isSelected(default, set):Bool = false;
    function set_isSelected(value:Bool):Bool
    {
        isSelected = value;

        if (sel != null)
            sel.visible = isSelected;

        return isSelected;
    }

    public var firstOption:FlxText;
    public var secondOption:FlxText;

    public var groupIndex:Int;

    public var keys:Array<FlxKey>;

    public var configCallback:Void -> Void;

    public function new(group:String, variable:String, groupIndex:Int)
    {
        super();

        this.group = group;
        this.variable = variable;
        this.groupIndex = groupIndex;

        keys = Reflect.field(Reflect.field(ClientPrefs.controls, group), variable);

        bg = new FlxSprite().makeGraphic(FlxG.width * 0.8, 50, FlxColor.fromRGB(35, 35, 50));
        add(bg);

        var titleBG:FlxSprite = new FlxSprite().makeGraphic(bg.width / 3, bg.height, FlxColor.BLACK);
        add(titleBG);
        titleBG.alpha = 0.25;

        sel = new FlxSprite().makeGraphic(bg.width / 3, 50);
        add(sel);
        sel.alpha = 0.2;

        var title:Alphabet = new Alphabet(10, -35, [for (str in variable.split('_')) CoolUtil.capitalize(str)].join(' '), false);

        firstOption = new Alphabet(0, 0, [null, 0].contains(keys[0]) ? '---' : FlxKey.toStringMap.get(keys[0]), false);

        secondOption = new Alphabet(0, 0, [null, 0].contains(keys[1]) ? '---' : FlxKey.toStringMap.get(keys[1]), false);

        for (index => text in [title, firstOption, secondOption])
        {
            text.scaleX = text.scaleY = 0.6;

            text.x = bg.width / 3 * index + bg.width / 6 - text.width / 2;
            text.y = -22;

            for (let in text)
                let.colorTransform.redOffset = let.colorTransform.greenOffset = let.colorTransform.blueOffset = 255;

            add(text);
        }

        isFirst = false;
        isSelected = false;
    }

    public var onConfig:Bool = false;

    public function initConfig()
    {
        clearConfig();

        FlxFlicker.flicker(sel, 0, 0.5);

        sel.alpha = 0.1;

        onConfig = true;
    }

    public function endConfig(key:Int)
    {
        keys[isFirst ? 0 : 1] = key;

        FlxFlicker.stopFlickering(sel);

        sel.alpha = 0.2;

        updateText();

        onConfig = false;
    }

    public function clearConfig()
    {
        keys[isFirst ? 0 : 1] = 0;

        updateText();
    }

    function updateText()
    {
        var text:Alphabet = isFirst ? firstOption : secondOption;

        text.text = [null, 0].contains(keys[isFirst ? 0 : 1]) ? '---' : FlxKey.toStringMap.get(keys[isFirst ? 0 : 1]);

        for (let in text)
            let.colorTransform.redOffset = let.colorTransform.greenOffset = let.colorTransform.blueOffset = 255;

        text.x = this.x + bg.width / 3 * (isFirst ? 1 : 2) + bg.width / 6 - text.width / 2;
    }
}