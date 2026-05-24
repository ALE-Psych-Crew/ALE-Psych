package core.assets;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSave;

import core.assets.RootsLibrary;

import openfl.display.BitmapData;
import openfl.utils.Assets;
import openfl.media.Sound;

import sys.FileSystem;
import sys.FileStat;
import sys.io.File;

import animate.FlxAnimateFrames;

import core.structures.PathConfigCache;
import core.structures.PathConfig;

import core.enums.ReadDirectoryType;
import core.enums.AtlasType;
import core.enums.FileType;

import utils.cool.FileUtil;

import lime.utils.Bytes;

import lime.system.CFFI;

class Paths
{
    public static var SEPARATOR(get, never):String;
    public static function get_SEPARATOR()
        return '::';

    public static var library(get, never):RootsLibrary;
    public static function get_library():RootsLibrary
        return cast Assets.getLibrary('default');

    public static var assets(get, never):String;
    public static function get_assets()
        return 'assets';

    public static var mods(get, never):String;
    public static function get_mods()
        return 'mods';

    public static var content(get, never):String;
    public static function get_content()
        return 'content';

    public static var mod:Null<String>;

    public static var modSave(get, never):String;
    public static function get_modSave()
        return 'ALEPsychData';

    public static var config:Map<String, PathConfig>;

    public static function loadMod()
    {
        mod = null;
        
        final modCheckSteps:Array<Void -> Void> = [
            () -> {
                if (Defines.CONTENT_MOD != null)
                    mod = File.getContent(Defines.CONTENT_MOD).split('\n')[0].trim();
            },
            () -> {
                final save:FlxSave = new FlxSave();

                save.bind(Paths.modSave, FileUtil.getSavePath(false));

                if (save != null)
                    mod = save.data.currentMod;
            }
        ];

        var i:Int = 0;

        while (mod == null && i < modCheckSteps.length)
        {
            modCheckSteps[i]();
                
            if (!FileSystem.exists(mods + '/' + mod))
                mod = null;

            i++;
        }
    }

    public static function init()
    {
        Assets.registerLibrary('default', new RootsLibrary([for (root in [mod == null ? null : mods + '/' + mod, content, #if switch 'romfs:/' + #end assets]) if (root != null) root]));

        config = [
            FileType.CONTENT => {
                get: (id, _, _, _) -> Assets.getText(id)
            },
            FileType.BYTES => {
                get: (id, _, _, _) -> Assets.getBytes(id)
            },
            FileType.IMAGE => {
                prefix: 'images/',
                postfix: '.png',
                get: (id, _, _, _) -> {
                    final bitmap:BitmapData = BitmapData.fromImage(library.getImage(id));

                    final graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, id);
                    graphic.persist = true;
                    graphic.destroyOnNoUse = false;

                    return graphic;
                }
            },
            FileType.AUDIO => {
                postfix: '.ogg',
                get: (id, _, _, _) -> Sound.fromAudioBuffer(library.getAudioBuffer(id))
            },
            FileType.ATLAS => {
                get: (id, arg, permanent, missingPrint) -> {
                    final graphic:FlxGraphic = image(id, permanent, missingPrint);

                    if (graphic == null)
                        return null;

                    var data:String = null;

                    var method:FlxGraphic -> String -> FlxAtlasFrames = null;

                    final pathPrefix:String = config[FileType.IMAGE].prefix + id;

                    switch (cast(arg, AtlasType))
                    {
                        case AtlasType.SPARROW:
                            data = getContent(pathPrefix + '.xml', permanent, missingPrint);

                            method = (graphic, data) -> FlxAtlasFrames.fromSparrow(graphic, data);

                        case AtlasType.PACKER:
                            data = getContent(pathPrefix + '.txt', permanent, missingPrint);

                            method = (graphic, data) -> FlxAtlasFrames.fromSpriteSheetPacker(graphic, data);

                        case AtlasType.ASEPRITE:
                            data = getContent(pathPrefix + '.json', permanent, missingPrint);

                            method = (graphic, data) -> FlxAtlasFrames.fromTexturePackerJson(graphic, data);

                        default:
                    }

                    return data == null ? null : method(graphic, data);
                },
                checkExistence: false
            },
            FileType.MULTI_ATLAS => {
                get: (ids, arg, permanent, missingPrint) -> {
                    final atlasFunc:String -> Bool -> Bool -> FlxAtlasFrames = switch (cast(arg, AtlasType))
                    {
                        case AtlasType.SPARROW:
                            getSparrowAtlas;
                        case AtlasType.PACKER:
                            getPackerAtlas;
                        case AtlasType.ASEPRITE:
                            getAsepriteAtlas;
                        default:
                            getAtlas;
                    };

                    final files:Array<String> = ids.split(SEPARATOR);

                    var parentFrames:FlxAtlasFrames = atlasFunc(files[0], permanent, missingPrint);

                    if (files.length > 1)
                    {
                        final og:FlxAtlasFrames = parentFrames;

                        parentFrames = new FlxAtlasFrames(parentFrames.parent);
                        parentFrames.addAtlas(og, true);
                        
                        for (i in 1...files.length)
                        {
                            final extraFrames:FlxAtlasFrames = atlasFunc(files[i], permanent, missingPrint);

                            if (extraFrames != null)
                                parentFrames.addAtlas(extraFrames, true);
                        }
                    }

                    return parentFrames;
                },
                checkExistence: false
            },
            FileType.JSON => {
                postfix: '.json',
                get: (id, _, permanent, missingPrint) -> Json.parse(getContent(id, permanent, missingPrint)),
                forceCleaning: true
            }
        ];
    }

    public static function clear(cleanAll:Bool, ?permanent:Bool = false)
    {
        if (config != null)
            for (obj in config)
                if (obj != null)
                    if ((cleanAll || obj.forceCleaning) && obj.cache != null)
                        for (id in obj.cache.keys())
                        {
                            var result:Dynamic = obj.cache[id];

                            if (!result.permanent || permanent)
                            {
                                if (result.content is IFlxDestroyable)
                                {
                                    @:privateAccess
                                    FlxG.bitmap._cache.remove(id);

                                    FlxDestroyUtil.destroy(result.content);
                                }

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
    
    // File

    public static function getBytes(file:String, ?permanent:Bool, ?missingPrint:Bool):Bytes
        return get(file, FileType.BYTES, permanent, missingPrint, null, false);

    public static function getContent(file:String, ?permanent:Bool, ?missingPrint:Bool):String
        return get(file, FileType.CONTENT, permanent, missingPrint, null, false);

    // Graphics

    public static function image(file:String, ?permanent:Bool, ?missingPrint:Bool):FlxGraphic
        return get(file, FileType.IMAGE, permanent, missingPrint);

    public static function getSparrowAtlas(file:String, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(file, FileType.ATLAS, permanent, missingPrint, AtlasType.SPARROW);

    public static function getPackerAtlas(file:String, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(file, FileType.ATLAS, permanent, missingPrint, AtlasType.PACKER);

    public static function getAsepriteAtlas(file:String, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(file, FileType.ATLAS, permanent, missingPrint, AtlasType.ASEPRITE);

    public static function getAtlas(file:String, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return getSparrowAtlas(file, permanent, false) ?? getPackerAtlas(file, permanent, false) ?? getAsepriteAtlas(file, permanent, false) ?? getAnimateAtlas(file, permanent, missingPrint);

    public static function getAnimateAtlas(folder:String, ?permanent:Bool, ?missingPrint:Bool):FlxAnimateFrames
    {
        final path:String = config[FileType.IMAGE].prefix + folder;

        if (!isDirectory(path) && missingPrint)
        {
            if (missingPrint)
                debugTrace(path, MISSING_FOLDER);

            return null;
        }

        return FlxAnimateFrames.fromAnimate(getPath(path));
    }

    public static function getMultiSparrowAtlas(files:Array<String>, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(files.join(SEPARATOR), FileType.MULTI_ATLAS, permanent, missingPrint, AtlasType.SPARROW);

    public static function getMultiPackerAtlas(files:Array<String>, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(files.join(SEPARATOR), FileType.MULTI_ATLAS, permanent, missingPrint, AtlasType.PACKER);

    public static function getMultiAsepriteAtlas(files:Array<String>, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(files.join(SEPARATOR), FileType.MULTI_ATLAS, permanent, missingPrint, AtlasType.ASEPRITE);

    public static function getMultiAtlas(files:Array<String>, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(files.join(SEPARATOR), FileType.MULTI_ATLAS, permanent, missingPrint);

    // Audio

    public static function audio(file:String, ?permanent:Bool, ?missingPrint:Bool):Sound
        return get(file, FileType.AUDIO, permanent, missingPrint);

    public static function music(file:String, ?permanent:Bool, ?missingPrint:Bool):Sound
        return audio('music/' + file, permanent, missingPrint);

    public static function sound(file:String, ?permanent:Bool, ?missingPrint:Bool):Sound
        return audio('sounds/' + file, permanent, missingPrint);

	public static function inst(route:String, ?permanent:Bool, ?missingPrint:Bool):Sound
		return audio(route + '/audios/Inst', permanent, missingPrint);

	public static function voices(route:String, ?postfix:String = null, ?permanent:Bool, ?missingPrint:Bool):Sound
		return audio(route + '/audios/Voices' + (postfix ?? ''), permanent, missingPrint);

    // Data

    public static function json(file:String, ?permanent:Bool, ?missingPrint:Bool):Dynamic
        return Json.copy(get(file, FileType.JSON, permanent, missingPrint));

    public static function ndll(fileName:String, funcName:String, ?args:Int = 0, ?missingPrint:Bool = true):Dynamic
    {
        final path:String = getPath('ndlls/' + fileName + '-' + CoolVars.BUILD_TARGET + '.ndll', missingPrint);

        return path == null ? Reflect.makeVarArgs((arr:Array<Dynamic>) -> {}) : CFFI.load(path, funcName, args ?? 0);
    }

    // Path

    public static function addCwd(path:String):String
        return path == null ? null : #if android Sys.getCwd() + '/' + #end path;
    
    public static function model(file:String, ?missingPrint:Bool = true):String
        return getPath('models/' + file + '.obj', missingPrint);

    public static function video(file:String, ?missingPrint:Bool = true):String
        return getPath('videos/' + file + '.mp4', missingPrint);

    public static function font(file:String, ?missingPrint:Bool = true):String
        return addCwd(getPath('fonts/' + file, missingPrint));

    // Utils

    public static function get(file:String, configID:String, ?permanent:Bool = false, ?missingPrint:Bool = true, ?arg:Dynamic, ?cache:Bool = true):Dynamic
    {
        final data:PathConfig = config[configID];

        if (data == null)
            return null;

        final path:String = data.prefix + file + data.postfix;

        if (data.cache.exists(path))
            return data.cache[path].content;

        if (!exists(path) && data.checkExistence)
        {
            if (missingPrint)
                debugTrace(path, 'missing_file');

            return null;
        }

        final result:Dynamic = data.get(path, arg, permanent, missingPrint);

        if (cache && result != null)
            data.cache[path] = {content: result, permanent: permanent};

        return result;
    }

    public static function getPath(file:String, ?missingPrint:Bool):String
    {
        final path:String = library.getPath(file);

        if (path == null && missingPrint)
            debugTrace(file, MISSING_FILE);

        return path;
    }

    // File System

    public static function exists(path:String):Bool
        return Assets.exists(path);

    public static function isDirectory(path:String):Bool
    {
        final fullPath:String = getPath(path, false);

        return fullPath == null ? false : FileSystem.isDirectory(fullPath);
    }

    public static function readDirectory(path:String, ?type:ReadDirectoryType = 'unique', ?missingPrint:Bool):Array<String>
    {
        var result:Array<String> = [];

        for (folder in library.roots)
        {
            var finalPath:String = folder + '/' + path;

            if (FileSystem.exists(finalPath) && FileSystem.isDirectory(finalPath))
            {
                result = result.concat(FileSystem.readDirectory(finalPath));

                if (type == 'unique')
                    break;
            }
        }
        
        result.sort((a, b) -> return Reflect.compare(a, b));

        return result;
    }

    public static function stat(path:String, ?missingPrint:Bool):FileStat
    {
        if (exists(path))
            return FileSystem.stat(getPath(path));

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }
}