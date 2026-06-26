package scripting;

@:unreflective
class ScriptConfig
{
    public static final CLASSES:Array<Class<Dynamic>> = [
        core.debug.HotReloading,

        flixel.util.FlxTimer,

        flixel.util.FlxDestroyUtil,

        flixel.math.FlxMath,

        flixel.text.FlxText,

        flixel.group.FlxGroup,
        flixel.group.FlxTypedGroup,
        flixel.group.FlxSpriteGroup,
        flixel.group.FlxTypedSpriteGroup,

        flixel.tweens.FlxTween,
        flixel.tweens.FlxEase,

        flixel.sound.FlxSound,

        flixel.FlxSprite,
        flixel.FlxCamera,
        flixel.FlxG,

        utils.CoolUtil,
        utils.CoolVars,
        utils.Controls,
        utils.Defines,
        utils.Json,

        core.audio.Conductor,
        core.audio.Sound,

        core.debug.Logs,

        core.visuals.Camera,

        core.assets.Paths,

        core.states.ScriptedState,
        core.states.State,

        core.substates.ScriptedSubState,
        core.substates.SubState,

        funkin.states.CustomState,
        funkin.states.PlayState,

        funkin.substates.CustomSubState,

        funkin.config.ClientPrefs,
        funkin.config.Save
    ];

    public static final ABSTRACTS:Array<String> = [
        'flixel.tweens.FlxTween.FlxTweenType',
        'flixel.util.FlxColor'
    ];

    public static final TYPEDEFS:Map<String, Class<Dynamic>> = [
        'Reflect' => rulescript.types.ScriptedReflect
    ];

    public static final VARIABLES:Map<String, Dynamic> = [
        'Function_Continue' => CoolVars.Function_Continue,
        'Function_Stop' => CoolVars.Function_Stop,
        'debugTrace' => debugTrace,
        'benchmark' => benchmark
    ];
}