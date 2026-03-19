package scripting;

import haxe.ds.StringMap;

@:unreflective class ScriptConfig
{
    public static final CLASSES:Array<Class<Dynamic>> = [
        core.config.Discord,

        flixel.FlxG,
        flixel.sound.FlxSound,
        flixel.FlxState,
        flixel.FlxSprite,
        flixel.FlxCamera,
        flixel.math.FlxMath,
        flixel.util.FlxTimer,
        flixel.text.FlxText,
        flixel.tweens.FlxEase,
        flixel.tweens.FlxTween,
        flixel.group.FlxSpriteGroup,
        flixel.group.FlxGroup.FlxTypedGroup,

        Array,
        String,
        StringTools,
        Std,
        Math,
        Type,
        Reflect,
        Date,
        DateTools,
        Xml,
        EReg,
        Lambda,
        IntIterator,

        sys.io.Process,
        haxe.ds.StringMap,
        haxe.ds.IntMap,
        haxe.ds.EnumValueMap,

        sys.io.File,
        sys.FileSystem,
        Sys,

        utils.Conductor,

        core.backend.MusicBeatState,
        core.backend.MusicBeatSubState,

        core.config.ClientPrefs,

        utils.CoolUtil,
        utils.CoolVars,

        funkin.states.PlayState,
        funkin.states.CustomState,
        funkin.substates.CustomSubState,

        funkin.visuals.ALECamera,
        
        Controls,

        Paths,

        api.DesktopAPI,
        api.MobileAPI
    ];

    public static final ABSTRACTS:Array<String> = [
        'flixel.util.FlxColor',
        'flixel.tweens.FlxTween.FlxTweenType'
    ];

    public static final TYPEDEFS:StringMap<Class<Dynamic>> = [
        'Json' => utils.ALEJson
    ];
}