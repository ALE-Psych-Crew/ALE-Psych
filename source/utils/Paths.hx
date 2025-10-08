package utils;

import core.enums.PathType;

import haxe.ds.StringMap;

import haxe.io.Bytes;

import sys.FileStat;
import sys.FileSystem;
import sys.io.File;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

import funkin.visuals.objects.PsychFlxAnimate;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;

import lime.media.AudioBuffer;

import core.backend.Mods;

import openfl.media.Sound;

class Paths
{
    public static inline final IMAGE_EXT = 'png';
	public static inline final SOUND_EXT = #if web 'mp3' #else 'ogg' #end;
	public static inline final VIDEO_EXT = 'mp4';

    public static var cachedBytes:StringMap<Bytes> = new StringMap<Bytes>();
    public static var cachedContents:StringMap<String> = new StringMap<String>();

	public static var cachedGraphics:StringMap<FlxGraphic> = new StringMap<FlxGraphic>();
    public static var cachedSounds:StringMap<Sound> = new StringMap<Sound>();

    // UTILS

    public static inline function getPath(file:String, missingPrint:Bool = true):String
    {
        #if MODS_ALLOWED
        if (exists(file, MODS))
            return modFolder() + '/' + file;
        #end

        if (exists(file, ASSETS))
            return 'assets/' + file;

        if (missingPrint)
            debugTrace(file, MISSING_FILE);

        return null;
    }

    public static inline function modFolder():String
        return 'mods/' + Mods.folder;
    
    public static function clearEngineCache()
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

        for (key in cachedBytes.keys())
            cachedBytes.remove(key);
        
        for (key in cachedContents.keys())
            cachedContents.remove(key);
        
        for (key in cachedGraphics.keys())
            cachedGraphics.remove(key);
        
        for (key in cachedSounds.keys())
            cachedSounds.remove(key);
    }

    // FILE SYSTEM
    
    public static inline function exists(path:String, ?pathMode:PathType = BOTH):Bool
    {
        #if MODS_ALLOWED
        if (FileSystem.exists(modFolder() + '/' + path) && (pathMode == MODS || pathMode == BOTH) && Mods.folder != '' && Mods.folder != null)
            return true;
        #end

        if (FileSystem.exists('assets/' + path) && (pathMode == ASSETS || pathMode == BOTH))
            return true;
        
        return false;
    }

    public static function isDirectory(path:String):Bool
    {
        if (exists(path))
            if (FileSystem.isDirectory(getPath(path)))
                return true;

        return false;
    }

    public static function readDirectory(path:String, ?missingPrint:Bool = true):Array<String>
    {
        if (isDirectory(path))
            return FileSystem.readDirectory(getPath(path));

        if (missingPrint)
            debugTrace(path, MISSING_FOLDER);

        return null;
    }

    public static function stat(path:String, ?missingPrint:Bool = true):FileStat
    {
        if (exists(path))
            return FileSystem.stat(getPath(path));

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }

    // FILE

    public static function getBytes(path:String, ?missingPrint:Bool = true):Bytes
    {
        if (cachedBytes.exists(path))
            return cachedBytes.get(path);
        
        if (exists(path))
            return File.getBytes(getPath(path));

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }

    public static function getContent(path:String, ?missingPrint:Bool = true):String
    {
        if (cachedContents.exists(path))
            return cachedContents.get(path);
        
        if (exists(path))
            return File.getContent(getPath(path));

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }

    // IMAGE

    public static function image(file:String, missingPrint:Bool = true):FlxGraphic
    {
        var path = 'images/' + file + '.' + IMAGE_EXT;

        var bitmap:BitmapData = null;

        if (cachedGraphics.exists(path))
            return cachedGraphics.get(path);
        else if (exists(path))
            bitmap = BitmapData.fromBytes(getBytes(path));

        if (bitmap != null)
        {
            var returnValue = cacheBitmap(path, bitmap);

            if (returnValue != null)
                return returnValue;
        }

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }

    public static function getAtlas(file:String, missingPrint:Bool = true):FlxAtlasFrames
        return getSparrowAtlas(file, false) ?? getPackerAtlas(file, false) ?? getAsepriteAtlas(file, missingPrint);

    public static function getSparrowAtlas(file:String, missingPrint:Bool = true):FlxAtlasFrames
    {
        var graphic = image(file, missingPrint);
        var xmlContent = xml(file, missingPrint);

        if (graphic == null || xmlContent == null)
            return null;

        return FlxAtlasFrames.fromSparrow(graphic, xmlContent);
    }
    
    public static function getPackerAtlas(file:String, missingPrint:Bool = true):FlxAtlasFrames
    {
        var graphic = image(file, missingPrint);
        var txtContent = imageTxt(file, missingPrint);

        if (graphic == null || txtContent == null)
            return null;

        return FlxAtlasFrames.fromSpriteSheetPacker(graphic, txtContent);
    }

    public static function getAsepriteAtlas(file:String, missingPrint:Bool = true):FlxAtlasFrames
    {
        var graphic = image(file, missingPrint);
        var jsonContent = imageJson(file, missingPrint);

        if (graphic == null || jsonContent == null)
            return null;

        return FlxAtlasFrames.fromTexturePackerJson(graphic, jsonContent);
    }

	public static function loadAnimateAtlas(spr:PsychFlxAnimate, folderOrImg:Dynamic, spriteJson:Dynamic = null, animationJson:Dynamic = null)
	{
		var changedAnimJson = false;
		var changedAtlasJson = false;
		var changedImage = false;
		
		if (spriteJson != null)
		{
			changedAtlasJson = true;

			spriteJson = getContent(spriteJson);
		}

		if(animationJson != null) 
		{
			changedAnimJson = true;

			animationJson = getContent(animationJson);
		}

		if (Std.isOfType(folderOrImg, String))
		{
			var originalPath:String = folderOrImg;

			for (i in 0...10)
			{
				var st:String = '$i';

				if (i == 0)
                    st = '';

				if (!changedAtlasJson)
				{
					spriteJson = getContent('images/$originalPath/spritemap$st.json');

					if (spriteJson != null)
					{
						changedImage = true;

						changedAtlasJson = true;

						folderOrImg = image('$originalPath/spritemap$st');
                        
						break;
					}
				} else if (exists('images/$originalPath/spritemap$st.png')) {
					changedImage = true;

					folderOrImg = image('$originalPath/spritemap$st');

					break;
				}
			}

			if (!changedImage)
			{
				changedImage = true;

				folderOrImg = image(originalPath);
			}

			if (!changedAnimJson)
			{
				changedAnimJson = true;

				animationJson = getContent('images/$originalPath/Animation.json');
			}
		}

		spr.loadAtlasEx(folderOrImg, spriteJson, animationJson);
	}
    
    @:unreflective private static function getMultiAtlasBase(atlasFunc:String -> Bool -> FlxAtlasFrames, files:Array<String>, missingPrint:Bool = true):FlxAtlasFrames
    {
		var parentFrames:FlxAtlasFrames = atlasFunc(files[0], missingPrint);

		if (files.length > 1)
		{
			var original:FlxAtlasFrames = parentFrames;

			parentFrames = new FlxAtlasFrames(parentFrames.parent);
			parentFrames.addAtlas(original, true);

			for (i in 1...files.length)
			{
				var extraFrames:FlxAtlasFrames = atlasFunc(files[i], missingPrint);

				if (extraFrames != null)
					parentFrames.addAtlas(extraFrames, true);
			}
		}

		return parentFrames;
    }

    public static function getMultiAtlas(files:Array<String>, missingPrint:Bool = true):FlxAtlasFrames
        return getMultiAtlasBase(Paths.getAtlas, files, missingPrint);

    public static function getMultiSparrowAtlas(files:Array<String>, missingPrint:Bool = true):FlxAtlasFrames
        return getMultiAtlasBase(Paths.getSparrowAtlas, files, missingPrint);

    public static function getMultiPackerAtlas(files:Array<String>, missingPrint:Bool = true):FlxAtlasFrames
        return getMultiAtlasBase(Paths.getPackerAtlas, files, missingPrint);

    public static function getMultiAsepriteAtlas(files:Array<String>, missingPrint:Bool = true):FlxAtlasFrames
        return getMultiAtlasBase(Paths.getAsepriteAtlas, files, missingPrint);

    // SOUND

	inline static public function voices(route:String, postfix:String = null, missingPrint:Bool = true)
		return returnSound(route + '/song/Voices' + (postfix ?? ''), missingPrint);

	inline static public function inst(route:String, missingPrint:Bool = true)
		return returnSound(route + '/song/Inst', missingPrint);

    public static function music(file:String, missingPrint:Bool = true):Sound
        return returnSound('music/' + file, missingPrint);

    public static function sound(file:String, missingPrint:Bool = true):Sound
        return returnSound('sounds/' + file, missingPrint);

    // JSON

    public static function json(file:String, ?missingPrint:Bool = true):Dynamic
    {
        var path:String = file + '.json';

        if (!exists(path))
        {
            if (missingPrint)
                debugTrace(path, MISSING_FILE);

            return null;
        }

        return Json.parse(getContent(path));
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
    
	public static function cacheBitmap(file:String, ?bitmap:BitmapData = null):FlxGraphic
	{
		if (bitmap == null)
		{
			if (FileSystem.exists(file))
				bitmap = BitmapData.fromBytes(File.getBytes(file));
            
			if (bitmap == null)
                return null;
		}

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

		return newGraphic;
	}

    public static function cacheSound(file:String, ?sound:Sound = null):Sound
    {
        if (sound == null)
        {
            if (FileSystem.exists(file))
                sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(File.getBytes(file)));

            if (sound == null)
                return null;
        }

        cachedSounds.set(file, sound);

        return sound;
    }

    private static function returnSound(file:String, missingPrint:Bool = true):Sound
    {
        var path = file + '.' + SOUND_EXT;

        var sound:Sound = null;

        if (cachedSounds.exists(path))
            return cachedSounds.get(path);
        else if (exists(path))
            sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(getBytes(path)));

        if (sound != null)
        {
            var returnValue = cacheSound(path, sound);

            if (returnValue != null)
                return returnValue;
        }

        if (missingPrint)
            debugTrace(path, MISSING_FILE);

        return null;
    }
}