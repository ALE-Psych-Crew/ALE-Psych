package utils.cool;

import sys.FileSystem;
import sys.io.File;

import haxe.io.Path;

import Type;

class FileUtil
{
    public static function readDirectory(path:String):Array<String>
    {
        final result:Array<String> = FileSystem.readDirectory(path);
        
        result.sort((a, b) -> return Reflect.compare(a, b));

        return result;
    }

    public static function resolvePath(uPath:String, ?keepRoot:Bool = true):String
    {
        final route:Array<String> = Path.normalize(uPath).split('/').filter(s -> s.length > 0);

        if (route.length == 0)
            return null;

        for (root in Paths.library.roots)
        {
            if (!FileSystem.exists(root))
                continue;

            var currentPath:String = root;

            var matchFound:Bool = true;

            for (index => dir in route)
            {
                if (!FileSystem.isDirectory(currentPath))
                {
                    matchFound = false;
                    
                    break;
                }

                final targetSanitized:String = StringUtil.formatString(dir);

                var nextSegment:String = null;

                for (entry in FileSystem.readDirectory(currentPath))
                    if (StringUtil.formatString(entry) == targetSanitized)
                    {
                        nextSegment = entry;

                        break;
                    }

                if (nextSegment == null)
                {
                    matchFound = false;

                    break;
                }

                currentPath = Path.join([currentPath, nextSegment]);
            }

            if (matchFound && FileSystem.exists(currentPath))
                return keepRoot ? currentPath : Path.join(route);
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