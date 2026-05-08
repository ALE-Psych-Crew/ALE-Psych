package core.assets;

import core.structures.CacheConfig;

import core.enums.ReadDirectoryType;
import core.enums.FileType;

import openfl.utils.Assets;

import flixel.graphics.FlxGraphic;

import sys.FileSystem;
import sys.FileStat;
import sys.io.File;

class Paths
{
    public static var assets:Null<String> = null;
    public static var mods:Null<String> = null;

    public static var mod:Null<String> = null;

    public static var library(get, never):RootsLibrary;
    static function get_library():RootsLibrary
        return cast Assets.getLibrary('default');

    public static var config:Map<String, CacheConfig>;

    public static function init()
    {
        config = [
            FileType.CONTENT => {
                method: (id, _, _, _) -> Assets.getText(id)
            },
            FileType.BYTES => {
                method: (id, _, _, _) -> Assets.getBytes(id)
            }
        ];

        assets = 'assets';
        mods = 'mods';

        Assets.registerLibrary('default', new RootsLibrary([for (root in [mod == null || mods == null ? null : mods + '/' + mod, #if switch 'romfs:/' + #end assets, '']) if (root != null) root]));
    }

    public static function clear(cleanAll:Bool, ?permanent:Bool = false)
    {
        for (obj in config)
            if (obj != null)
                if ((cleanAll || obj.forceCleaning) && obj.cache != null)
                    for (id in obj.cache.keys())
                    {
                        var result:Dynamic = obj.cache[id];

                        if (!result.permanent || permanent)
                        {
                            if (result is IFlxDestroyable)
                                FlxDestroyUtil.destroy(result);

                            obj.cache.remove(id);
                        }

                        result = null;
                    }

        if (permanent)
        {
            @:privateAccess
            for (key in FlxG.bitmap._cache.keys())
            {
                var result:FlxGraphic = FlxG.bitmap._cache.get(key);

                if (result != null && !config.get(FileType.IMAGE).cache.exists(key))
                {
                    FlxG.bitmap._cache.remove(key);

                    FlxDestroyUtil.destroy(result);
                }

                result = null;
            }
        }
    }

    public static function get(file:String, configID:String, permanent:Bool, missingPrint:Bool, ?cache:Bool = true):Dynamic
    {
        final data:CacheConfig = config[configID];

        if (data == null)
            return null;

        final path:String = data.prefix + file + data.postfix;

        if (!exists(path) && data.checkExistence)
        {
            if (missingPrint)
                debugTrace(path, PrintType.MISSING_FILE);

            return null;
        }

        final result:Dynamic = data.method(path, permanent, missingPrint);

        if (result == null)
            return null;

        if (cache)
            data.cache[path] = {content: result, permanent: permanent};

        return result;
    }

    public static function getPath(file:String, ?missingPrint:Bool = true):String
    {
        final path:String = library.getPath(file);

        if (path == null && missingPrint)
            debugTrace(file, MISSING_FILE);

        return path;
    }

    public static function exists(path:String):Bool
        return Assets.exists(path);

    public static function readDirectory(path:String, ?type:ReadDirectoryType = UNIQUE, ?missingPrint:Bool = true):Array<String>
    {
        var result:Array<String> = [];

        for (folder in library.roots)
        {
            var fullPath:String = folder + '/' + path;

            if (FileSystem.exists(fullPath))
            {
                if (FileSystem.isDirectory(fullPath))
                {
                    result = result.concat(FileSystem.readDirectory(fullPath));

                    if (type == UNIQUE)
                        break;
                }
            }
        }
        
        result.sort((a, b) -> return Reflect.compare(a, b));

        return result;
    }

    public static function stat(path:String, ?missingPrint:Bool = true):FileStat
    {
        if (exists(path))
            return FileSystem.stat(getPath(path));

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }

    public static function getBytes(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):String
        return get(file, FileType.BYTES, permanent, missingPrint, false);

    public static function getContent(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):String
        return get(file, FileType.CONTENT, permanent, missingPrint, false);

    public static function addCwd(path:String):String
        return path == null ? null : #if android Sys.getCwd() + '/' + #end path;
    
    public static function font(file:String, ?missingPrint:Bool = true):String
        return addCwd(getPath('fonts/' + file, missingPrint));
}