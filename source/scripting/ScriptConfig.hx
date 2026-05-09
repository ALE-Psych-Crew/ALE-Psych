package scripting;

@:unreflective
class ScriptConfig
{
    public static final CLASSES:Array<Class<Dynamic>> = [
        flixel.util.FlxDestroyUtil,

        flixel.math.FlxMath,

        flixel.text.FlxText,

        flixel.group.FlxGroup,

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

        core.debug.Logs,

        core.visuals.Camera,

        core.assets.Paths,

        core.states.ScriptedState,
        core.states.State,

        core.substates.ScriptedSubState,
        core.substates.SubState,

        funkin.states.CustomState,

        funkin.substates.CustomSubState,

        funkin.config.ClientPrefs
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