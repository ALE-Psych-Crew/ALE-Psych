package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

import flixel.FlxBasic;

class LuaBasic extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('setObjectCamera', function(tag:String, camera:String)
        {
            deprecatedPrint('Use "setObjectCameras" instead of "setObjectCamera"');

            if (tagIs(tag, FlxBasic) && tagIs(camera, FlxCamera))
                getTag(tag).cameras = [getTag(camera)];
        });

        set('setObjectCameras', function(tag:String, cameras:Array<String>)
        {
            var theCameras:Array<FlxCamera> = [];

            for (cam in cameras)
                if (tagIs(cam, FlxCamera))
                    theCameras.push(getTag(cam));

            if (tagIs(tag, FlxBasic))
                cast(getTag(tag), FlxBasic).cameras = theCameras;
        });

        set('objectsOverlap', function(tag0:String, tag1:String):Bool
        {
            if (tagIs(tag0, FlxBasic) && tagIs(tag0, FlxBasic))
                return FlxG.overlap(getTag(tag0), getTag(tag1));

            return false;
        });
    }
}
