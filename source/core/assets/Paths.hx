package core.assets;

import haxe.Constraints.Function;
import haxe.ds.StringMap;

import core.assets.ALEAssetLibrary;

import core.structures.CacheConfig;

import core.enums.ReadDirectoryType;
import core.enums.AtlasType;
import core.enums.FileType;

import openfl.utils.Assets as OpenFLAssets;
import openfl.display3D.textures.RectangleTexture;
import openfl.display.BitmapData;
import openfl.media.Sound;

import lime.media.AudioBuffer;
import lime.utils.Bytes;
import lime.system.CFFI;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSave;

import animate.FlxAnimateFrames;

import sys.FileSystem;
import sys.FileStat;
import sys.io.File;

class Paths
{
    @:unreflective public static var UNIQUE_MOD:Null<String> = null;

    public static final assets:String = 'assets';
    public static final mods:String = 'mods';
    public static var mod:Null<String> = UNIQUE_MOD;

    @:unreflective public static function initMod()
    {
        if (FileSystem.exists('mods/UNIQUE_MOD.txt'))
        {
            UNIQUE_MOD = mod = File.getContent('mods/UNIQUE_MOD.txt').split('\n')[0].trim();
        } else {
            UNIQUE_MOD = null;

            var save:FlxSave = new FlxSave();

            save.bind('ALEEngineData', utils.cool.FileUtil.getSavePath(false));

            if (save != null)
                mod = save.data.currentMod;

            if (!FileSystem.exists(mods + '/' + mod))
                mod = null;
        }
    }
    
    public static final SEPARATOR:String = '::';

    public static var library(get, never):ALEAssetLibrary;
    static function get_library():ALEAssetLibrary
        return cast OpenFLAssets.getLibrary('default');

    public static var config:StringMap<CacheConfig> = new StringMap();

    public static function init()
    {
        final roots:Array<String> = [];

        if (mod != null)
            roots.push(mods + '/' + mod);

        roots.push(#if switch 'romfs:/' + #end assets);

        OpenFLAssets.registerLibrary('default', new ALEAssetLibrary(roots));

        config = [
            FileType.CONTENT => {
                method: (id, permanent, missingPrint) -> {
                    return OpenFLAssets.getText(id);
                }
            },
            FileType.BYTES => {
                method: (id, permanent, missingPrint) -> {
                    return OpenFLAssets.getBytes(id);
                }
            },
            FileType.IMAGE => {
                prefix: 'images/',
                postfix: '.png',
                method: (id, permanent, missingPrint) -> {
                    var bitmap:BitmapData = BitmapData.fromBytes(OpenFLAssets.getBytes(id));
                    
                    if (ClientPrefs.data.cacheOnGPU)
                    {
                        var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(
                            bitmap.width, bitmap.height, BGRA, true
                        );
                        texture.uploadFromBitmapData(bitmap);
                        
                        bitmap.image.data = null;
                        bitmap.dispose();
                        bitmap.disposeImage();
                        
                        bitmap = BitmapData.fromTexture(texture);
                    }
                    
                    var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, id);
                    graphic.persist = true;
                    graphic.destroyOnNoUse = false;
                    
                    return graphic;
                }
            },
            FileType.AUDIO => {
                postfix: '.ogg',
                method: (id, permanent, missingPrint) -> {
                    return Sound.fromAudioBuffer(AudioBuffer.fromBytes(OpenFLAssets.getBytes(id)));
                }
            },
            FileType.ATLAS => {
                method: (idType, permanent, missingPrint) -> {
                    final split:Array<String> = idType.split(SEPARATOR);

                    final graphic:FlxGraphic = image(split[0], permanent, missingPrint);

                    var data:String = null;
                    
                    var method:FlxGraphic -> String -> FlxAtlasFrames = null;

                    switch (cast split[1])
                    {
                        case AtlasType.SPARROW:
                            data = getContent('images/' + split[0] + '.xml', permanent, missingPrint);

                            method = (graphic, data) -> FlxAtlasFrames.fromSparrow(graphic, data);

                        case AtlasType.PACKER:
                            data = getContent('images/' + split[0] + '.txt', permanent, missingPrint);

                            method = (graphic, data) -> FlxAtlasFrames.fromSpriteSheetPacker(graphic, data);

                        case AtlasType.ASEPRITE:
                            data = getContent('images/' + split[0] + '.json', permanent, missingPrint);

                            method = (graphic, data) -> FlxAtlasFrames.fromTexturePackerJson(graphic, data);

                        default:
                    }

                    if (graphic == null || data == null)
                        return null;

                    return method(graphic, data);
                },
                verifyExistence: false
            },
            FileType.MULTI_ATLAS => {
                method: (idType, permanent, missingPrint) -> {
                    final splitData:Array<String> = idType.split(SEPARATOR + SEPARATOR);

                    final files:Array<String> = splitData[0].split(SEPARATOR);

                    final atlasFunc:String -> Bool -> Bool -> FlxAtlasFrames = switch(cast splitData[1])
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

                    var parentFrames:FlxAtlasFrames = atlasFunc(files[0], permanent, missingPrint);

                    if (files.length > 1)
                    {
                        var original:FlxAtlasFrames = parentFrames;

                        parentFrames = new FlxAtlasFrames(parentFrames.parent);
                        parentFrames.addAtlas(original, true);

                        for (i in 1...files.length)
                        {
                            var extraFrames:FlxAtlasFrames = atlasFunc(files[i], permanent, missingPrint);

                            if (extraFrames != null)
                                parentFrames.addAtlas(extraFrames, true);
                        }
                    }

                    return parentFrames;
                },
                verifyExistence: false
            }
        ];
    }

    public static function clear(?perm:Bool = false)
    {
        if (perm)
        {
            @:privateAccess
            for (key in FlxG.bitmap._cache.keys())
            {
                var obj = FlxG.bitmap._cache.get(key);

                if (obj != null && !config.get(FileType.IMAGE).cache.exists(key))
                {
                    FlxG.bitmap._cache.remove(key);

                    obj.destroy();
                }
            }
        }
        
        for (obj in config)
            if (obj.cache != null)
                for (cacheID in obj.cache.keys())
                    if (!obj.cache.get(cacheID).permanent || perm)
                        obj.cache.remove(cacheID);
    }

    // Utils

    public static function get(file:String, configID:String, permanent:Bool, missingPrint:Bool, ?cache:Bool = true):Dynamic
    {
        final data:CacheConfig = config.get(configID);

        if (data == null)
            return null;

        final path:String = data.prefix + file + data.postfix;

        if (data.cache.exists(path))
            return data.cache.get(path).content;

        if (!exists(path) && data.verifyExistence)
        {
            if (missingPrint)
                debugTrace(path, 'missing_file');

            return null;
        }

        final result:Dynamic = data.method(path, permanent, missingPrint);

        if (result == null)
            return null;

        if (cache)
            data.cache.set(path, {content: result, permanent: permanent});

        return result;
    }

    public static function getPath(file:String, ?missingPrint:Bool = true):String
    {
        final path:String = OpenFLAssets.getPath(file);

        if (path == null && missingPrint)
            debugTrace(file, MISSING_FILE);

        return path;
    }

    // File System

    public static function exists(path:String):Bool
        return OpenFLAssets.exists(path);

    public static function isDirectory(path:String):Bool
    {
        if (exists(path))
            if (FileSystem.isDirectory(getPath(path)))
                return true;

        return false;
    }

    public static function readDirectory(path:String, ?type:ReadDirectoryType = UNIQUE, ?missingPrint:Bool = true):Array<String>
    {
        var result:Array<String> = [];

        for (folder in library.roots)
        {
            var finalPath:String = folder + '/' + path;

            if (FileSystem.exists(finalPath))
            {
                if (FileSystem.isDirectory(finalPath))
                {
                    result = result.concat(FileSystem.readDirectory(finalPath));

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

    // File

    public static function getBytes(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):String
        return get(file, FileType.BYTES, permanent, missingPrint, false);

    public static function getContent(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):String
        return get(file, FileType.CONTENT, permanent, missingPrint, false);

    // Graphics

    public static function image(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):FlxGraphic
        return get(file, FileType.IMAGE, permanent, missingPrint);

    public static function getSparrowAtlas(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):FlxAtlasFrames
        return get(file + SEPARATOR + AtlasType.SPARROW, FileType.ATLAS, permanent, missingPrint);

    public static function getPackerAtlas(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):FlxAtlasFrames
        return get(file + SEPARATOR + AtlasType.PACKER, FileType.ATLAS, permanent, missingPrint);

    public static function getAsepriteAtlas(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):FlxAtlasFrames
        return get(file + SEPARATOR + AtlasType.ASEPRITE, FileType.ATLAS, permanent, missingPrint);

    public static function getAtlas(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):FlxAtlasFrames
        return getSparrowAtlas(file, permanent, false) ?? getPackerAtlas(file, permanent, false) ?? getAsepriteAtlas(file, permanent, missingPrint);

    public static function getAnimateAtlas(folder:String, ?permanent:Bool = false, ?missingPrint:Bool = true):FlxAnimateFrames
    {
        final path:String = 'images/' + folder;

        if (!exists(path) && missingPrint)
        {
            if (missingPrint)
                debugTrace(path, MISSING_FOLDER);

            return null;
        }

        return FlxAnimateFrames.fromAnimate(getPath(path));
    }

    public static function getMultiSparrowAtlas(files:Array<String>, ?permanent:Bool = false, ?missingPrint:Bool = true):FlxAtlasFrames
        return get(files.join(SEPARATOR) + SEPARATOR + SEPARATOR + AtlasType.SPARROW, FileType.MULTI_ATLAS, permanent, missingPrint);

    public static function getMultiPackerAtlas(files:Array<String>, ?permanent:Bool = false, ?missingPrint:Bool = true):FlxAtlasFrames
        return get(files.join(SEPARATOR) + SEPARATOR + SEPARATOR + AtlasType.PACKER, FileType.MULTI_ATLAS, permanent, missingPrint);

    public static function getMultiAsepriteAtlas(files:Array<String>, ?permanent:Bool = false, ?missingPrint:Bool = true):FlxAtlasFrames
        return get(files.join(SEPARATOR) + SEPARATOR + SEPARATOR + AtlasType.ASEPRITE, FileType.MULTI_ATLAS, permanent, missingPrint);

    public static function getMultiAtlas(files:Array<String>, ?permanent:Bool = false, ?missingPrint:Bool = true):FlxAtlasFrames
        return get(files.join(SEPARATOR) + SEPARATOR + SEPARATOR, FileType.MULTI_ATLAS, permanent, missingPrint);

    // Sound

    public static function audio(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):Sound
        return get(file, FileType.AUDIO, permanent, missingPrint);

    public static function music(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):Sound
        return audio('music/' + file, permanent, missingPrint);

    public static function sound(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):Sound
        return audio('sounds/' + file, permanent, missingPrint);

	public static function inst(route:String, ?permanent:Bool = false, ?missingPrint:Bool = true):Sound
		return audio(route + '/song/Inst', permanent, missingPrint);

	public static function voices(route:String, ?postfix:String = null, ?permanent:Bool = false, ?missingPrint:Bool = true):Sound
		return audio(route + '/song/Voices' + (postfix ?? ''), permanent, missingPrint);

    // Data

    public static function json(file:String, ?permanent:Bool = false, ?missingPrint:Bool = true):Dynamic
    {
        final content:Dynamic = getContent(file + '.json', permanent, missingPrint);

        return content == null ? null : Json.parse(content);
    }

    public static function ndll(fileName:String, funcName:String, ?args:Int = 0, ?missingPrint:Bool = true):Dynamic
    {
        final path:String = getPath('ndlls/' + fileName + '-' + CoolVars.BUILD_TARGET + '.ndll', missingPrint);

        return path == null ? Reflect.makeVarArgs((arr:Array<Dynamic>) -> {}) : CFFI.load(path, funcName, args ?? 0);
    }

    // Path
    
    public static function model(file:String, ?missingPrint:Bool = true):String
        return getPath('models/' + file + '.obj', missingPrint);

    public static function video(file:String, ?missingPrint:Bool = true):String
        return getPath('videos/' + file + '.mp4', missingPrint);

    public static function font(file:String, ?missingPrint:Bool = true):String
        return addCwd(getPath('fonts/' + file, missingPrint));

    public static function addCwd(path:String):String
        return path == null ? null : #if android Sys.getCwd() + '/' + #end path;
}