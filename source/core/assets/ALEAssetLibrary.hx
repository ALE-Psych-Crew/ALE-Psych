package core.assets;

import lime.utils.Bytes;

import openfl.display.BitmapData;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetType;
import openfl.media.Sound;
import openfl.text.Font as OpenFLFont;

import lime.media.AudioBuffer;
import lime.graphics.Image;
import lime.text.Font;

import sys.io.File;
import sys.FileSystem;

class ALEAssetLibrary extends AssetLibrary
{
    public final roots:Array<String>;

    public function new(roots:Array<String>)
    {
        this.roots = roots;

        super();

        __fromManifest(AssetManifest.fromFile('manifest/default.json'));
    }

    public function assetExists(id:String):Bool
        return getPath(id) != null;

    override public function exists(id:String, type:String):Bool
        return assetExists(id);

    override public function getPath(id:String):String
    {
        for (root in roots)
        {
            final path:String = root + '/' + id;

            if (FileSystem.exists(path))
                return path;
        }

        return super.getPath(id);
    }

    override public function getBytes(id:String):Bytes
    {
        final path:String = getPath(id);

        return path == null ? null : File.getBytes(path);
    }

    override public function getText(id:String):String
    {
        final path:String = getPath(id);

        return path == null ? null : File.getContent(path);
    }

    override public function getAudioBuffer(id:String):AudioBuffer
    {
        final bytes:Bytes = getBytes(id);

        return bytes == null ? null : AudioBuffer.fromBytes(bytes);
    }

    override public function getImage(id:String):Image
    {
        final bytes:Bytes = getBytes(id);

        return bytes == null ? null : Image.fromBytes(bytes);
    }

    override public function getFont(id:String):Font
    {
        final bytes:Bytes = getBytes(id);

        if (bytes == null)
            return null;

        final font:Font = Font.fromBytes(bytes);

        final openFLFont:OpenFLFont = new OpenFLFont();
        
        @:privateAccess openFLFont.__fromLimeFont(font);

        OpenFLFont.registerFont(openFLFont);

        return font;
    }

    override public function getAsset(id:String, type:String):Dynamic
    {
        return switch (cast(type, AssetType))
        {
            case BINARY:
                getBytes(id);
            case TEXT:
                getText(id);
            case IMAGE:
                getImage(id);
            case SOUND, MUSIC:
                Sound.fromAudioBuffer(AudioBuffer.fromBytes(getBytes(id)));
            case FONT:
                getFont(id);
            default:
                null;
        }
    }
}