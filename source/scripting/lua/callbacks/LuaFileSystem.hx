package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import sys.io.File;
import sys.FileSystem;

class LuaFileSystem extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
        
        set('checkFileExists', function(name:String):Bool
        {
            return Paths.exists(name);
        });

        set('saveFile', function(name:String, content:String)
        {
            File.saveContent(Paths.mods + '/' + Paths.mod + '/' + name, content);
        });

        set('deleteFile', function(name:String)
        {
            FileSystem.deleteFile(Paths.mods + '/' + Paths.mod + '/' + name);
        });
        
        set('getTextFromFile', function(name:String):String
        {
            return Paths.getContent(name);
        });

        set('directoryFileList', function(name:String)
        {
            return Paths.readDirectory(name);
        });
    }
}
