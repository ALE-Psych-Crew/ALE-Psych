package utils.cool;

import flixel.tweens.FlxEase.EaseFunction;

class StringUtil
{
	public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

    public static function easeFromString(?ease:String = ''):EaseFunction
    {
        return switch(ease.toLowerCase().trim())
        {
            case 'backin':
                FlxEase.backIn;
            case 'backinout':
                FlxEase.backInOut;
            case 'backout':
                FlxEase.backOut;
            case 'bouncein':
                FlxEase.bounceIn;
            case 'bounceinout':
                FlxEase.bounceInOut;
            case 'bounceout':
                FlxEase.bounceOut;
            case 'circin':
                FlxEase.circIn;
            case 'circinout':
                FlxEase.circInOut;
            case 'circout':
                FlxEase.circOut;
            case 'cubein':
                FlxEase.cubeIn;
            case 'cubeinout':
                FlxEase.cubeInOut;
            case 'cubeout':
                FlxEase.cubeOut;
            case 'elasticin':
                FlxEase.elasticIn;
            case 'elasticinout':
                FlxEase.elasticInOut;
            case 'elasticout':
                FlxEase.elasticOut;
            case 'expoin':
                FlxEase.expoIn;
            case 'expoinout':
                FlxEase.expoInOut;
            case 'expoout':
                FlxEase.expoOut;
            case 'quadin':
                FlxEase.quadIn;
            case 'quadinout':
                FlxEase.quadInOut;
            case 'quadout':
                FlxEase.quadOut;
            case 'quartin':
                FlxEase.quartIn;
            case 'quartinout':
                FlxEase.quartInOut;
            case 'quartout':
                FlxEase.quartOut;
            case 'quintin':
                FlxEase.quintIn;
            case 'quintinout':
                FlxEase.quintInOut;
            case 'quintout':
                FlxEase.quintOut;
            case 'sinein':
                FlxEase.sineIn;
            case 'sineinout':
                FlxEase.sineInOut;
            case 'sineout':
                FlxEase.sineOut;
            case 'smoothstepin':
                FlxEase.smoothStepIn;
            case 'smoothstepinout':
                FlxEase.smoothStepInOut;
            case 'smoothstepout':
                FlxEase.smoothStepOut;
            case 'smootherstepin':
                FlxEase.smootherStepIn;
            case 'smootherstepinout':
                FlxEase.smootherStepInOut;
            case 'smootherstepout':
                FlxEase.smootherStepOut;
            default:
                FlxEase.linear;
        }
    }

    public static function intToHex(value:Int):String
    {
        #if !neko
        return StringTools.hex(value);
        #end

        var hex = '';
        var digits = '0123456789ABCDEF';
        var n = value;

        for (i in 0...8)
        {
            var remainder = n % 16;

            if (remainder < 0)
                remainder += 16;

            hex = digits.charAt(remainder) + hex;

            n = Std.int(n / 16);
        }
        
        return hex;
    }

	public static function fromCharCode(code:Int):String
		return String.fromCharCode(code);
}