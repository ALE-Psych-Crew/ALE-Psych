package core.assets;

import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetType;

import lime.media.AudioBuffer;
import lime.graphics.Image;
import lime.utils.Bytes;
import lime.text.Font;

import sys.FileSystem;
import sys.io.File;

class RootsLibrary extends AssetLibrary
{
    public final roots:Array<String>;

    public function new(roots:Array<String>)
    {
        this.roots = roots;

        super();

        __fromManifest(AssetManifest.fromFile(#if switch 'romfs:/' + #end 'manifest/default.json'));
    }

    override public function exists(id:String, type:String):Bool
        return getPath(id) != null;

    override public function getPath(id:String):String
    {
        for (root in roots)
        {
            final path:String = root + '/' + id;

            if (FileSystem.exists(path))
                return path;
        }

        return null;
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

    public function resolve<T>(id:String, method:Bytes -> T):T
    {
        final bytes:Bytes = getBytes(id);
        
        return bytes == null ? null : method(bytes);
    }

    override public function getAudioBuffer(id:String):AudioBuffer
        return resolve(id, AudioBuffer.fromBytes);

    override public function getImage(id:String):Image
        return resolve(id, Image.fromBytes);

    override public function getFont(id:String):Font
        return resolve(id, Font.fromBytes);

    override public function getAsset(id:String, type:String):Dynamic
    {
        return switch (cast type)
        {
            case BINARY:
                getBytes(id);
            case TEXT:
                getText(id);
            case IMAGE:
                getImage(id);
            case SOUND, MUSIC:
                getAudioBuffer(id);
            case FONT:
                getFont(id);
            default:
                null;
        }
    }
}