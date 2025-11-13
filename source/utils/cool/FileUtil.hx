package utils.cool;

import sys.FileSystem;
import sys.io.File;

class FileUtil
{
	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		
		var formatted:Array<String> = path.split(':');

		path = formatted[formatted.length-1];

		if (FileSystem.exists(path))
			daList = File.getContent(path);

		return daList != null ? StringUtil.listFromString(daList) : [];
	}
	
    public static function searchComplexFile(path:String, missingPrint:Bool = true)
    {
        var parts = path.split('/');

        var parent = "";

        var result:String = null;

        for (part in parts)
        {
            result = searchFile(parent, part);

            if (result == null)
            {
                if (missingPrint ?? true)
                    debugTrace(parent + (parent.length > 0 ? '/' : '') + part, MISSING_FILE);

                return null;
            }

            parent = result;
        }

        return result;
    }

    public static function searchFile(parent:String, file:String)
    {
        for (folder in [Paths.modFolder(), 'assets'])
        {
            var path:String = folder + '/' + parent;

            if (FileSystem.exists(path) && FileSystem.isDirectory(path))
                for (searchAsset in FileSystem.readDirectory(path))
                    if (formatToSongPath(searchAsset) == formatToSongPath(file))
                        return parent + (parent.length > 0 ? '/' : '') + searchAsset;
        }
        
        return null;
    }

	inline public static function openFolder(folder:String, absolute:Bool = false) {
		#if sys
			if(!absolute) folder =  Sys.getCwd() + '$folder';

			folder = folder.replace('/', '\\');
			if(folder.endsWith('/')) folder.substr(0, folder.length - 1);

			#if linux
			var command:String = '/usr/bin/xdg-open';
			#else
			var command:String = 'explorer.exe';
			#end
			Sys.command(command, [folder]);
		#else
			FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}

	public static function formatToSongPath(string:String):String
		return string.trim().toLowerCase().replace(' ', '-');
    
	@:access(flixel.util.FlxSave.validate)
	public static function getSavePath(modSupport:Bool = true):String
	{
		return FlxG.stage.application.meta.get('company') + '/' + flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file')) + (modSupport ? ((Mods.folder.trim() == '' ? '' : '/' + (CoolVars.data.modID ?? Mods.folder))) : '');
	}
}