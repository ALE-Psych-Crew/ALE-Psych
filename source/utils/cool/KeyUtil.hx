package utils.cool;

import openfl.events.KeyboardEvent;

import flixel.input.keyboard.FlxKey;

class KeyUtil
{
    static final nativeCorrection:Map<String, FlxKey> = [
		'0_64' => FlxKey.INSERT,
		'0_65' => FlxKey.END,
		'0_67' => FlxKey.PAGEDOWN,
		'0_69' => FlxKey.NONE,
		'0_73' => FlxKey.PAGEUP,
		'0_266' => FlxKey.DELETE,
		'123_222' => FlxKey.LBRACKET,
		'125_187' => FlxKey.RBRACKET,
		'126_233' => FlxKey.GRAVEACCENT,
		'0_43' => FlxKey.PLUS,

		'0_80' => FlxKey.F1,
		'0_81' => FlxKey.F2,
		'0_82' => FlxKey.F3,
		'0_83' => FlxKey.F4,
		'0_84' => FlxKey.F5,
		'0_85' => FlxKey.F6,
		'0_86' => FlxKey.F7,
		'0_87' => FlxKey.F8,
		'0_88' => FlxKey.F9,
		'0_89' => FlxKey.F10,
		'0_90' => FlxKey.F11,

		'48_224' => FlxKey.ZERO,
		'49_38' => FlxKey.ONE,
		'50_233' => FlxKey.TWO,
		'51_34' => FlxKey.THREE,
		'52_222' => FlxKey.FOUR,
		'53_40' => FlxKey.FIVE,
		'54_189' => FlxKey.SIX,
		'55_232' => FlxKey.SEVEN,
		'56_95' => FlxKey.EIGHT,
		'57_231' => FlxKey.NINE,

		'48_64' => FlxKey.NUMPADZERO,
		'49_65' => FlxKey.NUMPADONE,
		'50_66' => FlxKey.NUMPADTWO,
		'51_67' => FlxKey.NUMPADTHREE,
		'52_68' => FlxKey.NUMPADFOUR,
		'53_69' => FlxKey.NUMPADFIVE,
		'54_70' => FlxKey.NUMPADSIX,
		'55_71' => FlxKey.NUMPADSEVEN,
		'56_72' => FlxKey.NUMPADEIGHT,
		'57_73' => FlxKey.NUMPADNINE,

		'43_75' => FlxKey.NUMPADPLUS,
		'45_77' => FlxKey.NUMPADMINUS,
		'47_79' => FlxKey.SLASH,
		'46_78' => FlxKey.NUMPADPERIOD,
		'42_74' => FlxKey.NUMPADMULTIPLY
    ];
    
    public static function openFLToFlixelKey(e:KeyboardEvent):Int
    {
        #if web
        return e.keyCode;
        #else
        return nativeCorrection.get(e.charCode + '_' + e.keyCode) ?? e.keyCode;
        #end
    }

	public static function toggleVolumeKeys(?turnOn:Bool = true)
	{
		FlxG.sound.muteKeys = turnOn ? [FlxKey.M] : [];
		FlxG.sound.volumeDownKeys = turnOn ? [FlxKey.MINUS, FlxKey.NUMPADMINUS] : [];
		FlxG.sound.volumeUpKeys = turnOn ? [FlxKey.PLUS, FlxKey.NUMPADPLUS] : [];
	}
}