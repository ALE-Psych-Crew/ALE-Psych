package utils.cool;

import sys.FileSystem;
import sys.io.File;

import Type;

class FileUtil
{
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
                for (searchAsset in FileSystem.readDirectory(path))
                    if (StringUtil.formatString(searchAsset) == StringUtil.formatString(file))
                        return parent + (parent.length > 0 ? '/' : '') + searchAsset;
        }
        
        return null;
    }

	inline public static function openFolder(folder:String, absolute:Bool = false)
    {
        if (!absolute)
            folder = Sys.getCwd() + '$folder';

        folder = folder.replace('/', '\\');

        if (folder.endsWith('/'))
            folder.substr(0, folder.length - 1);

        #if linux
        var command:String = '/usr/bin/xdg-open';
        #else
        var command:String = 'explorer.exe';
        #end

        Sys.command(command, [folder]);
	}
}