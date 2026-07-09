package utils.cool;

import sys.FileSystem;
import sys.io.File;

import Type;

class FileUtil
{
    public static function readDirectory(path:String):Array<String>
    {
        final result:Array<String> = FileSystem.readDirectory(path);
        
        result.sort((a, b) -> return Reflect.compare(a, b));

        return result;
    }

    public static function searchComplexFile(path:String, missingPrint:Bool = true)
    {
        var parts = path.split('/');

        var parent = '';

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
        for (folder in Paths.library.roots)
        {
            var path:String = folder + '/' + parent;

            if (FileSystem.exists(path) && FileSystem.isDirectory(path))
                for (searchAsset in readDirectory(path))
                    if (StringUtil.formatString(searchAsset) == StringUtil.formatString(file))
                        return parent + (parent.length > 0 ? '/' : '') + searchAsset;
        }
        
        return null;
    }

	inline public static function openFolder(folder:String)
    {
        folder = folder.replace('/', '\\');

        if (folder.endsWith('/'))
            folder = folder.substr(0, folder.length - 1);

        Sys.command(#if linux '/usr/bin/xdg-open' #else 'explorer.exe' #end, [folder]);
	}
}