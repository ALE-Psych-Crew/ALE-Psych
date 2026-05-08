package core.debug;

import haxe.PosInfos;
import haxe.Timer;

import api.DesktopAPI;

import core.structures.PrintConfig;

import winapi.WindowsAPI.MessageBoxIcon;

class Logs
{
    public static var config:Map<String, PrintConfig> = null;

    public static function debugTrace(text:Dynamic, ?type:String = PrintType.TRACE, ?allowTrace:Bool = true, ?allowPrint:Bool = true, ?pos:PosInfos)
    {
        final data:PrintConfig = config[type];

        if (data == null || (data.verbose && CoolVars.data.verbose))
            return;

        if (allowTrace && data.allowTrace)
            Sys.println(colorString(data.title, data.color) + colorString(' | ' + Date.now().toString().split(' ')[1] + ' | ', 0xFF505050) + (pos == null ? '' : colorString(pos.fileName + ':' + pos.lineNumber + ': ', 0xFF888888)) + text);
    }

    public static function colorString(text:String, color:FlxColor):String
		return '\x1b[38;2;' + color.red + ';' + color.green + ';' + color.blue + 'm' + text + '\x1b[0m';

    public static function popUp(title:String, message:String, ?icon:MessageBoxIcon = INFORMATION):Void
    {
        debugTrace(title + ' | ' + message, POP_UP);

        #if ALLOW_WINDOWS_API
        DesktopAPI.showMessageBox(message, title, icon);
        #else
        FlxG.stage.window.alert(message, title);
        #end
    }

	public static function benchmark(func:Void -> Void, ?title:String):Float
	{
		final initial:Float = Timer.stamp();

		try
		{
			func();
		} catch(e) {
			debugTrace('During Benchmark: ' + e, PrintType.ERROR);
		}

		final result:Float = Timer.stamp() - initial;

		debugTrace((title == null ? '' : title + ': ') + result, BENCHMARK);

		return result;
	}

    public static function init()
    {
        config = [
            PrintType.ERROR => {
                title: 'ERROR',
                color: 0xFFFF5555
            },
            PrintType.WARNING => {
                title: 'WARNING',
                color: 0xFFFFA500
            },
            PrintType.DEPRECATED => {
                title: 'DEPRECATED',
                color: 0xFF8000
            },
            PrintType.TRACE => {
                title: 'TRACE',
                color: 0xFFFFFFFF
            },
            PrintType.HSCRIPT => {
                title: 'HSCRIPT',
                color: 0xFF88CC44,
                verbose: true
            },
            PrintType.LUA => {
                title: 'LUA',
                color: 0xFF4466DD,
                verbose: true
            },
            PrintType.MISSING_FILE => {
                title: 'MISSING FILE',
                color: 0xFFFF7F00
            },
            PrintType.MISSING_FOLDER => {
                title: 'MISSING FOLDER',
                color: 0xFFFF7F00
            },
            PrintType.POP_UP => {
                title: 'POP UP',
                color: 0xFFFF00FF,
                verbose: true,
                allowPrint: false
            },
            PrintType.LOAD_SONG => {
                title: 'LOAD SONG',
                color: FlxColor.CYAN,
                verbose: true
            },
            PrintType.LOAD_WEEK => {
                title: 'LOAD WEEK',
                color: 0xFF00E5FF,
                verbose: true
            },
            PrintType.RESET_STATE => {
                title: 'RESET STATE',
                color: FlxColor.YELLOW,
                verbose: true
            },
            PrintType.DISCORD => {
                title: 'DISCORD',
                color: 0xFF5865F2,
                verbose: true,
                allowPrint: false
            },
            PrintType.BENCHMARK => {
                title: 'BENCHMARK',
                color: FlxColor.PINK
            }
        ];
    }
}