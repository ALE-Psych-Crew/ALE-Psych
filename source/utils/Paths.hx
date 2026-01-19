package utils;

import core.structures.CacheArray;

import core.enums.ReadDirectoryType;

import core.backend.Mods;

import openfl.utils.Assets as OpenFLAssets;
import openfl.display3D.textures.RectangleTexture;
import openfl.display.BitmapData;
import openfl.media.Sound;

import lime.media.AudioBuffer;
import lime.utils.Bytes;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

import utils.ALEAssetLibrary;

import haxe.ds.StringMap;

import sys.FileStat;
import sys.FileSystem;

import yaml.Yaml;

class Paths
{
    public static inline final IMAGE_EXT = 'png';
	public static inline final SOUND_EXT = #if web 'mp3' #else 'ogg' #end;
	public static inline final VIDEO_EXT = 'mp4';

    public static var cachedBytes:StringMap<Bytes> = new StringMap();
    public static var permanentBytes:Array<String> = [];

    public static var cachedContents:StringMap<String> = new StringMap();
    public static var permanentContents:Array<String> = [];

	public static var cachedGraphics:StringMap<FlxGraphic> = new StringMap();
	public static var permanentGraphics:Array<String> = [];

    public static var cachedSounds:StringMap<Sound> = new StringMap();
    public static var permanentSounds:Array<String> = [];

    public static var cachedAtlas:StringMap<FlxAtlasFrames> = new StringMap();
    public static var permanentAtlas:Array<String> = [];

    public static var cachedJson:StringMap<Dynamic> = new StringMap();
    public static var permanentJson:Array<String> = [];

    public static var cachedYaml:StringMap<Dynamic> = new StringMap();
    public static var permanentYaml:Array<String> = [];

    public static var cachedMultiAtlas:StringMap<FlxAtlasFrames> = new StringMap();
    public static var permanentMultiAtlas:Array<String> = [];

    public static var library(get, never):ALEAssetLibrary;
    static function get_library():ALEAssetLibrary
        return cast OpenFLAssets.getLibrary('default');

    // UTILS

    public static inline function getPath(file:String, missingPrint:Bool = true):String
    {
        final path:String = OpenFLAssets.getPath(file);

        if (path == null && missingPrint)
            debugTrace(file, MISSING_FILE);

        return path;
    }

    public static function modFolder():String
        return 'mods/' + Mods.folder;
    
    public static function clearEngineCache(?clearPermanent:Bool = false)
    {
        var cachedObjects:Array<CacheArray> = [
            {cache: cachedBytes, permanent: permanentBytes},
            {cache: cachedContents, permanent: permanentContents},
            {cache: cachedGraphics, permanent: permanentGraphics},
            {cache: cachedSounds, permanent: permanentSounds},
            {cache: cachedAtlas, permanent: permanentAtlas},
            {cache: cachedMultiAtlas, permanent: permanentMultiAtlas},
            {cache: cachedJson, permanent: permanentJson},
            {cache: cachedYaml, permanent: permanentYaml}
        ];
        
        if (clearPermanent)
        {
            @:privateAccess
            for (key in FlxG.bitmap._cache.keys())
            {
                var obj = FlxG.bitmap._cache.get(key);

                if (obj != null && !cachedGraphics.exists(key))
                {
                    FlxG.bitmap._cache.remove(key);

                    obj.destroy();
                }
            }

            for (array in cachedObjects)
                array.permanent.resize(0);
        }

        for (array in cachedObjects)
            for (key in array.cache.keys())
                if (!array.permanent.contains(key))
                    array.cache.remove(key);
    }

    // FILE SYSTEM
    
    public static inline function exists(path:String):Bool
        return OpenFLAssets.exists(path);

    public static function isDirectory(path:String):Bool
    {
        if (exists(path))
            if (FileSystem.isDirectory(getPath(path)))
                return true;

        return false;
    }

    public static function readDirectory(path:String, type:ReadDirectoryType = UNIQUE, missingPrint:Bool = true):Array<String>
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

    public static function stat(path:String, missingPrint:Bool = true):FileStat
    {
        if (exists(path))
            return FileSystem.stat(getPath(path));

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }

    // FILE

    public static function getBytes(path:String, missingPrint:Bool = true):Bytes
    {
        if (cachedBytes.exists(path))
            return cachedBytes.get(path);
        
        if (exists(path))
            return OpenFLAssets.getBytes(path);

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }

    public static function getContent(path:String, missingPrint:Bool = true):String
    {
        if (cachedContents.exists(path))
            return cachedContents.get(path);
        
        if (exists(path))
            return OpenFLAssets.getText(path);

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }

    // IMAGE

    public static function image(file:String, permanent:Bool = false, missingPrint:Bool = true):FlxGraphic
    {
        var path = 'images/' + file + '.' + IMAGE_EXT;

        var bitmap:BitmapData = null;

        if (cachedGraphics.exists(path))
            return cachedGraphics.get(path);
        else if (exists(path))
            bitmap = BitmapData.fromBytes(getBytes(path));

        if (bitmap != null)
        {
            var returnValue = cacheBitmap(path, bitmap, permanent);

            if (returnValue != null)
                return returnValue;
        }

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }

    public static function getAtlas(file:String, permanent:Bool = false, missingPrint:Bool = true):FlxAtlasFrames
        return getSparrowAtlas(file, permanent, false) ?? getPackerAtlas(file, permanent, false) ?? getAsepriteAtlas(file, permanent, missingPrint);

    public static function getSparrowAtlas(file:String, permanent:Bool = false, missingPrint:Bool = true):FlxAtlasFrames
    {
        if (cachedAtlas.exists(file))
            return cachedAtlas.get(file);

        var graphic = image(file, permanent, missingPrint);
        var xmlContent = xml(file, missingPrint);

        if (graphic == null || xmlContent == null)
            return null;

        var frames:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(graphic, xmlContent);

        cachedAtlas.set(file, frames);

        if (permanent)
            permanentAtlas.push(file);

        return frames;
    }
    
    public static function getPackerAtlas(file:String, permanent:Bool = false, missingPrint:Bool = true):FlxAtlasFrames
    {
        if (cachedAtlas.exists(file))
            return cachedAtlas.get(file);

        var graphic = image(file, permanent, missingPrint);
        var txtContent = imageTxt(file, missingPrint);

        if (graphic == null || txtContent == null)
            return null;

        var frames:FlxAtlasFrames = FlxAtlasFrames.fromSpriteSheetPacker(graphic, txtContent);

        cachedAtlas.set(file, frames);

        if (permanent)
            permanentAtlas.push(file);

        return frames;
    }

    public static function getAsepriteAtlas(file:String, permanent:Bool = false, missingPrint:Bool = true):FlxAtlasFrames
    {
        if (cachedAtlas.exists(file))
            return cachedAtlas.get(file);

        var graphic = image(file, permanent, missingPrint);
        var jsonContent = imageJson(file, missingPrint);

        if (graphic == null || jsonContent == null)
            return null;

        var frames:FlxAtlasFrames = FlxAtlasFrames.fromTexturePackerJson(graphic, jsonContent);

        cachedAtlas.set(file, frames);

        if (permanent)
            permanentAtlas.push(file);

        return frames;
    }
    
    @:unreflective private static function getMultiAtlasBase(atlasFunc:String -> Bool -> Bool -> FlxAtlasFrames, files:Array<String>, permanent:Bool = false, missingPrint:Bool = true):FlxAtlasFrames
    {
        if (cachedMultiAtlas.exists(files.join('::')))
            return cachedMultiAtlas.get(files.join('::'));

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

        cachedMultiAtlas.set(files.join('::'), parentFrames);

        if (permanent)
            permanentMultiAtlas.push(files.join('::'));

		return parentFrames;
    }

    public static function getMultiAtlas(files:Array<String>, permanent:Bool = false, missingPrint:Bool = true):FlxAtlasFrames
        return getMultiAtlasBase(Paths.getAtlas, files, permanent, missingPrint);

    public static function getMultiSparrowAtlas(files:Array<String>, permanent:Bool = false, missingPrint:Bool = true):FlxAtlasFrames
        return getMultiAtlasBase(Paths.getSparrowAtlas, files, permanent, missingPrint);

    public static function getMultiPackerAtlas(files:Array<String>, permanent:Bool = false, missingPrint:Bool = true):FlxAtlasFrames
        return getMultiAtlasBase(Paths.getPackerAtlas, files, permanent, missingPrint);

    public static function getMultiAsepriteAtlas(files:Array<String>, permanent:Bool = false, missingPrint:Bool = true):FlxAtlasFrames
        return getMultiAtlasBase(Paths.getAsepriteAtlas, files, permanent, missingPrint);

    // SOUND

	inline static public function voices(route:String, postfix:String = null, permanent:Bool = false, missingPrint:Bool = true)
		return returnSound(route + '/song/Voices' + (postfix ?? ''), permanent, missingPrint);

	inline static public function inst(route:String, permanent:Bool = false, missingPrint:Bool = true)
		return returnSound(route + '/song/Inst', permanent, missingPrint);

    public static function music(file:String, permanent:Bool = false, missingPrint:Bool = true):Sound
        return returnSound('music/' + file, permanent, missingPrint);

    public static function sound(file:String, permanent:Bool = false, missingPrint:Bool = true):Sound
        return returnSound('sounds/' + file, permanent, missingPrint);

    // DATA LANGUAGES

    public static function json(file:String, permanent:Bool = false, missingPrint:Bool = true):Dynamic
    {
        var path:String = file + '.json';

        if (cachedJson.exists(path))
            return cachedJson.get(path);

        if (!exists(path))
        {
            if (missingPrint)
                debugTrace(path, MISSING_FILE);

            return null;
        }

        var json:Dynamic = Json.parse(getContent(path));

        if (permanent)
            permanentJson.push(path);

        return json;
    }

    public static function yaml(file:String, permanent:Bool = false, missingPrint:Bool = true):Dynamic
    {
        var path:String = file + '.yaml';

        if (cachedYaml.exists(path))
            return cachedYaml.get(path);

        if (!exists(path))
        {
            if (missingPrint)
                debugTrace(path, MISSING_FILE);

            return null;
        }

        var yaml:Dynamic = Yaml.parse(getContent(path));

        if (permanent)
            permanentYaml.push(path);

        return yaml;
    }

    public static function ndll(fileName:String, funcName:String, ?args:Int = 0, missingPrint:Bool = true):Dynamic
    {
        var path = 'ndlls/' + fileName + '-' + CoolVars.BUILD_TARGET + '.ndll';

        if (!exists(path))
        {
            if (missingPrint)
                debugTrace(path, MISSING_FILE);

            return Reflect.makeVarArgs((arr:Array<Dynamic>) -> {});
        }

        return lime.system.CFFI.load(getPath(path), funcName, args);
    }

    // CONTENT

    public static function xml(file:String, missingPrint:Bool = true):String
    {
        var path = 'images/' + file + '.xml';

        if (!exists(path))
        {
            if (missingPrint)
                debugTrace(path, MISSING_FILE);

            return null;
        }

        return getContent(path);
    }

    public static function imageTxt(file:String, missingPrint:Bool = true):String
    {
        var path = 'images/' + file + '.txt';

        if (!exists(path))
        {
            if (missingPrint)
                debugTrace(path, MISSING_FILE);

            return null;
        }

        return getContent(path);
    }
    
    public static function imageJson(file:String, missingPrint:Bool = true):String
    {
        var path = 'images/' + file + '.json';

        if (!exists(file))
        {
            if (missingPrint)
                debugTrace(path, MISSING_FILE);
            
            return null;
        }

        return getContent(path);
    }

    // PATH

    public static function model(file:String, missingPrint:Bool = true):String
    {
        var path:String = 'models/' + file + '.obj';

        if (!exists(path))
        {
            if (missingPrint)
                debugTrace(path, MISSING_FILE);

            return null;
        }

        return getPath(path);
    }

    public static function video(file:String, missingPrint:Bool = true):String
    {
        var path = 'videos/' + file + '.' + VIDEO_EXT;

        if (!exists(path))
        {
            if (missingPrint)
                debugTrace(path, MISSING_FILE);

            return null;
        }

        return getPath(path);
    }

    public static function font(file:String, missingPrint:Bool = true):String
    {
        var path = 'fonts/' + file;

        if (!exists(path))
        {
            if (missingPrint)
                debugTrace(path, MISSING_FILE);

            return null;
        }

        return getPath(path);
    }

    // PRECACHE
    
	public static function cacheBitmap(file:String, bitmap:BitmapData, permanent:Bool = false):FlxGraphic
	{
		if (ClientPrefs.data.cacheOnGPU)
		{
			var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
			texture.uploadFromBitmapData(bitmap);

			bitmap.image.data = null;
			bitmap.dispose();
			bitmap.disposeImage();
            
			bitmap = BitmapData.fromTexture(texture);
		}

		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
        newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
        
		cachedGraphics.set(file, newGraphic);

        if (permanent)
            permanentGraphics.push(file);

		return newGraphic;
	}

    public static function cacheSound(file:String, sound:Sound, permanent:Bool = false):Sound
    {
        cachedSounds.set(file, sound);

        if (permanent)
            permanentSounds.push(file);

        return sound;
    }

    private static function returnSound(file:String, permanent:Bool = false, missingPrint:Bool = true):Sound
    {
        var path = file + '.' + SOUND_EXT;

        var sound:Sound = null;

        if (cachedSounds.exists(path))
            return cachedSounds.get(path);
        else if (exists(path))
            sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(getBytes(path)));

        if (sound != null)
        {
            var returnValue = cacheSound(path, sound, permanent);

            if (returnValue != null)
                return returnValue;
        }

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }
}