package utils.cool;

import core.enums.PrintType;

class LogUtil
{
	public static function debugTrace(text:Dynamic, ?type:PrintType = TRACE, ?customType:String = '', ?customColor:FlxColor = FlxColor.GRAY, ?pos:haxe.PosInfos)
		if ((type.unnecessary() && CoolVars.data.verbose) || !type.unnecessary())
			Sys.println(ansiColorString(type == CUSTOM ? customType : type.toString(), type == CUSTOM ? customColor : type.toColor()) + ansiColorString(' | ' + Date.now().toString().split(' ')[1] + ' | ', 0xFF505050) + (pos == null ? '' : ansiColorString(pos.fileName + ': ', 0xFF888888)) + text);
	
	public static function ansiColorString(text:String, color:FlxColor):String
		return '\x1b[38;2;' + color.red + ';' + color.green + ';' + color.blue + 'm' + text + '\x1b[0m';

	public static function showPopUp(title:String, message:String):Void
	{
		debugTrace(title + ' | ' + message, POP_UP);

		#if (windows && cpp)
		cpp.WindowsAPI.showMessageBox(title, message, INFORMATION);
		#else
		FlxG.stage.window.alert(message, title);
		#end
	}
}