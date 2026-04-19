package scripting;

@:unreflective class ScriptConfig
{
    public static final CLASSES:Array<Class<Dynamic>> = [
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

        api.DesktopAPI,
        api.MobileAPI,
        
        core.config.Discord,
        core.config.ClientPrefs,
        
        sys.FileSystem,
        sys.io.Process,
        sys.io.File,

        haxe.ds.StringMap,
        haxe.ds.IntMap,
        haxe.ds.EnumValueMap,

        utils.Conductor,
        utils.CoolUtil,
        utils.CoolVars,
        utils.Controls,
        utils.Json,
        utils.TweenUtil,

        core.backend.MusicBeatState,
        core.backend.MusicBeatSubState,

        funkin.states.PlayState,
        funkin.states.CustomState,
        funkin.substates.CustomSubState,

        funkin.visuals.Camera,

        core.assets.Paths
    ];

    public static final ABSTRACTS:Array<String> = [
        'flixel.util.FlxColor',
        'flixel.tweens.FlxTween.FlxTweenType'
    ];

    public static final TYPEDEFS:Map<String, Class<Dynamic>> = [
        'Reflect' => rulescript.types.ScriptedReflect
    ];

    public static final VARIABLES:Map<String, Dynamic> = [
        'debugTrace' => debugTrace,
        'Function_Stop' => CoolVars.Function_Stop,
        'Function_Continue' => CoolVars.Function_Continue
    ];
}