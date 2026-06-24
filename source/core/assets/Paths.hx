package core.assets;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

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

import funkin.config.SaveFile;

/**
 * It is responsible for resolving, locating, and caching game resources
 * 
 * It also reimplements part of FileSystem to integrate it into the Engine's ecosystem
 */
class Paths
{
    @:dox(hide)
    public static var SEPARATOR(get, never):String;
    @:dox(hide)
    public static function get_SEPARATOR()
        return '::';

    /**
     * Shortcut to access the (modified) OpenFL asset library
     */
    public static var library(get, never):RootsLibrary;
    @:dox(hide)
    public static function get_library():RootsLibrary
        return cast Assets.getLibrary('default');

    /**
     * Location of the assets folder
     */
    public static var assets(get, never):String;
    @:dox(hide)
    public static function get_assets()
        return 'assets';

    /**
     * Location of the mods folder
     */
    public static var mods(get, never):String;
    @:dox(hide)
    public static function get_mods()
        return 'mods';

    /**
     * Location of the folder containing additional assets
     */
    public static var content(get, never):String;
    @:dox(hide)
    public static function get_content()
        return 'content';

    /**
     * Current mod
     */
    public static var mod:Null<String>;

    @:dox(hide)
    public static var modSave(get, never):String;
    @:dox(hide)
    public static function get_modSave()
        return 'ALEPsychData';

    /**
     * The map showing how each file type is handled
     */
    public static var config:Map<String, PathConfig>;

    @:dox(hide)
    public static function loadMod()
    {
        mod = null;
        
        final modCheckSteps:Array<Void -> Void> = [
            () -> {
                if (Defines.CONTENT_MOD != null)
                    mod = Defines.CONTENT_MOD.split('\n')[0].trim();
            },
            () -> {
                mod = new SaveFile('mod', true).data.mod;
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

    @:dox(hide)
    @:access(openfl.display.BitmapData)
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

                    if (ClientPrefs.data.cacheOnGPU && bitmap.image != null && FlxG.stage.context3D != null)
                    {
                        bitmap.lock();
                        bitmap.getTexture(FlxG.stage.context3D);
                        bitmap.getSurface();
                        bitmap.disposeImage();

                        bitmap.image.data = null;
                        bitmap.image = null;
                        
                        bitmap.readable = true;
                    }

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

    /**
     * This clears the cached files and the Flixel bitmap cache
     * It's usually not necessary to use it, since the game typically deletes files that are no longer needed
     * @param cleanAll Indicate whether to delete all files or only those that must be forcibly deleted
     * @param permanent Specify whether to delete files marked as having a permanent cache
     */
    public static function clear(cleanAll:Bool, ?permanent:Bool = false)
    {
        if (config == null)
            return;

        for (obj in config)
            if (cleanAll || obj.forceCleaning)
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
    }
    
    // File

    /**
     * This retrieves the bytes from a file
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return File Bytes
     */
    public static function getBytes(file:String, ?permanent:Bool, ?missingPrint:Bool):Bytes
        return get(file, FileType.BYTES, permanent, missingPrint, null, false);

    /**
     * This retrieves the contents of a file
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return File's Content
     */
    public static function getContent(file:String, ?permanent:Bool, ?missingPrint:Bool):String
        return get(file, FileType.CONTENT, permanent, missingPrint, null, false);

    // Graphics

    /**
     * Retrieves an image and returns it as a `FlxGraphic`
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `FlxGraphic`
     */
    public static function image(file:String, ?permanent:Bool, ?missingPrint:Bool):FlxGraphic
        return get(file, FileType.IMAGE, permanent, missingPrint);

    /**
     * Retrieves a Sparrow-type sprite sheet and returns it as `FlxAtlasFrames`
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `FlxAtlasFrames`
     */
    public static function getSparrowAtlas(file:String, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(file, FileType.ATLAS, permanent, missingPrint, AtlasType.SPARROW);

    /**
     * Retrieves a Packer-type sprite sheet and returns it as `FlxAtlasFrames`
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `FlxAtlasFrames`
     */
    public static function getPackerAtlas(file:String, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(file, FileType.ATLAS, permanent, missingPrint, AtlasType.PACKER);

    /**
     * Retrieves a sprite sheet from Aseprite and returns it as `FlxAtlasFrames`
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `FlxAtlasFrames`
     */
    public static function getAsepriteAtlas(file:String, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(file, FileType.ATLAS, permanent, missingPrint, AtlasType.ASEPRITE);

    /**
     * Retrieves a sprite sheet of any type and returns it as `FlxAtlasFrames`
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `FlxAtlasFrames`
     */
    public static function getAtlas(file:String, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return getSparrowAtlas(file, permanent, false) ?? getPackerAtlas(file, permanent, false) ?? getAsepriteAtlas(file, permanent, false) ?? getAnimateAtlas(file, permanent, missingPrint);

    /**
     * Retrieves an Atlas from Adobe Animate and returns it as `FlxAnimateFrames`
     * @param folder Folder Path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `FlxAnimateFrames`
     */
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

    /**
     * This retrieves several Sparrow-type sprite sheets and combines them into a `FlxAtlasFrames`
     * @param files File paths
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `FlxAtlasFrames`
     */
    public static function getMultiSparrowAtlas(files:Array<String>, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(files.join(SEPARATOR), FileType.MULTI_ATLAS, permanent, missingPrint, AtlasType.SPARROW);

    /**
     * This retrieves several Packer-type sprite sheets and combines them into a `FlxAtlasFrames`
     * @param files File paths
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `FlxAtlasFrames`
     */
    public static function getMultiPackerAtlas(files:Array<String>, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(files.join(SEPARATOR), FileType.MULTI_ATLAS, permanent, missingPrint, AtlasType.PACKER);

    /**
     * This retrieves several sprite sheets from Aseprite and combines them into an `FlxAtlasFrames`
     * @param files File paths
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `FlxAtlasFrames`
     */
    public static function getMultiAsepriteAtlas(files:Array<String>, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(files.join(SEPARATOR), FileType.MULTI_ATLAS, permanent, missingPrint, AtlasType.ASEPRITE);

    /**
     * This retrieves multiple sprite sheets of any type and combines them into a `FlxAtlasFrames`
     * @param files File paths
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `FlxAtlasFrames`
     */
    public static function getMultiAtlas(files:Array<String>, ?permanent:Bool, ?missingPrint:Bool):FlxAtlasFrames
        return get(files.join(SEPARATOR), FileType.MULTI_ATLAS, permanent, missingPrint);

    // Audio

    /**
     * This retrieves an audio file and converts it into a `Sound`
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `Sound`
     */
    public static function audio(file:String, ?permanent:Bool, ?missingPrint:Bool):Sound
        return get(file, FileType.AUDIO, permanent, missingPrint);

    /**
     * This retrieves an audio file located in `music/` and converts it into a `Sound`
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `Sound`
     */
    public static function music(file:String, ?permanent:Bool, ?missingPrint:Bool):Sound
        return audio('music/' + file, permanent, missingPrint);

    /**
     * This retrieves an audio file located in `sounds/` and converts it into a `Sound`
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting `Sound`
     */
    public static function sound(file:String, ?permanent:Bool, ?missingPrint:Bool):Sound
        return audio('sounds/' + file, permanent, missingPrint);

	/**
	 * This retrieves the instrumental track from a song and converts it into a `Sound`
	 * @param route Location of the song
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
	 * @return Resulting `Sound`
	 */
	public static function inst(route:String, ?permanent:Bool, ?missingPrint:Bool):Sound
		return audio(route + '/audios/Inst', permanent, missingPrint);

	/**
	 * This retrieves the vocal from a song and converts it into a `Sound`
	 * @param route Location of the song
	 * @param postfix Vocal Suffix
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
	 * @return Resulting `Sound`
	 */
	public static function voices(route:String, ?postfix:String, ?permanent:Bool, ?missingPrint:Bool):Sound
		return audio(route + '/audios/Voices' + (postfix == null ? '' : '-' + postfix), permanent, missingPrint);

    // Data

    /**
     * This fetches and parses a JSON file
     * @param file File path
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Parsed JSON
     */
    public static function json(file:String, ?permanent:Bool, ?missingPrint:Bool):Dynamic
        return Json.copy(get(file, FileType.JSON, permanent, missingPrint));

    /**
     * This retrieves a function located in an *ndll*
     * @param fileName File path
     * @param funcName Function name
     * @param args Number of arguments
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return Resulting function
     */
    public static function ndll(fileName:String, funcName:String, ?args:Int = 0, ?missingPrint:Bool = true):Dynamic
    {
        final path:String = getPath('ndlls/' + fileName + '-' + CoolVars.BUILD_TARGET + '.ndll', missingPrint);

        return path == null ? Reflect.makeVarArgs((arr:Array<Dynamic>) -> {}) : CFFI.load(path, funcName, args ?? 0);
    }

    // Path

    @:dox(hide)
    public static function addCwd(path:String):String
        return path == null ? null : #if android Sys.getCwd() + '/' + #end path;
    
    /**
     * This simply helps you locate the model file
     * @param file File path
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return File path
     */
    public static function model(file:String, ?missingPrint:Bool = true):String
        return getPath('models/' + file + '.obj', missingPrint);

    /**
     * This simply helps you find where the video file is located
     * @param file File path
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return File path
     */
    public static function video(file:String, ?missingPrint:Bool = true):String
        return getPath('videos/' + file + '.mp4', missingPrint);

    /**
     * This simply helps you locate the font file
     * @param file File path
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return File path
     */
    public static function font(file:String, ?missingPrint:Bool = true):String
        return addCwd(getPath('fonts/' + file, missingPrint));

    // Utils

    /**
     * Follow the procedure described in `config`, taking into account the file name and the file format
     * @param file File path(s)
     * @param configID File type
     * @param permanent This determines whether your cache should be persistent
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @param arg Any arguments you wish to pass to the process, if required
     * @param cache This determines whether or not to cache the result of the process
     * @return Result of the process
     */
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

    /**
     * This helps you specify exactly where a file is located
     * @param file File path
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return File Path
     */
    public static function getPath(file:String, ?missingPrint:Bool):String
    {
        final path:String = library.getPath(file);

        if (path == null && missingPrint)
            debugTrace(file, MISSING_FILE);

        return path;
    }

    // File System

    /**
     * This determines whether or not a file exists
     * @param path File path
     * @return Whether or not the file exists
     */
    public static function exists(path:String):Bool
        return Assets.exists(path);

    /**
     * This determines whether or not a path refers to a folder
     * @param path Path
     * @return Whether the path refers to a folder or not
     */
    public static function isDirectory(path:String):Bool
    {
        final fullPath:String = getPath(path, false);

        return fullPath == null ? false : FileSystem.isDirectory(fullPath);
    }

    /**
     * This creates a list based on the files in the specified folder(s)
     * @param path Folder path
     * @param type This determines whether to search all available paths or just the first one found
     * @return List of files in the folder(s)
     */
    public static function readDirectory(path:String, ?type:ReadDirectoryType = 'unique'):Array<String>
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

    /**
     * This retrieves information from a file or folder
     * @param path File/folder path
     * @param missingPrint This determines whether an error message should be displayed if the file cannot be found
     * @return File/Folder Information
     */
    public static function stat(path:String, ?missingPrint:Bool):FileStat
    {
        if (exists(path))
            return FileSystem.stat(getPath(path));

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }
}