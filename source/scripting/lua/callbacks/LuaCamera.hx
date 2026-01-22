package scripting.lua.callbacks;

import flixel.FlxObject;
import flixel.util.FlxAxes;

import scripting.lua.LuaPresetBase;
import scripting.lua.LuaPresetUtils;

class LuaCamera extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('makeLuaCamera', function(tag:String, x:Float, y:Float, width:Int, heigth:Int, zoom:Float)
            {
                setTag(tag, new ALECamera(x, y, width, heigth, zoom));
            }
        );

        set('addCamera', function(tag:String, ?defaultDraw:Bool)
            {
                if (tagIs(tag, FlxCamera))
                    FlxG.cameras.add(getTag(tag), defaultDraw);
            }
        );

        set('removeCamera', function(tag:String)
            {
                if (tagIs(tag, FlxCamera))
                    if (FlxG.cameras.list.contains(getTag(tag)))
                        FlxG.cameras.remove(getTag(tag));
            }
        );
        
        set('cameraShake', function(camera:String, tag:String, ?intensity:Float, ?duration:Float, ?force:Bool, ?axes:FlxAxes)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).shake(intensity, duration, () -> { lua.call('onCameraShakeComplete', [tag]); }, force, axes);
        });

        set('cameraFlash', function(camera:String, tag:String, ?color:FlxColor, ?duration:Float, ?force:Bool)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).flash(color, duration, () -> { lua.call('onCameraFlashComplete', [tag]); }, force);
        });

        set('cameraFade', function(camera:String, tag:String, ?color:FlxColor, ?duration:Float, ?fadeIn:Bool, ?force:Bool)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).fade(color, duration, fadeIn, () -> { lua.call('onCameraFadeComplete', [tag]); }, force);
        });

        set('stopCameraFX', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopFX();
        });

        set('stopCameraFade', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopFade();
        });

        set('stopCameraFlash', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopFlash();
        });

        set('stopCameraShake', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopShake();
        });

        set('cameraFollow', function(camera:String, target:String, ?lerp:Float)
        {
            if (tagIs(camera, FlxCamera) && tagIs(target, FlxObject))
                getTag(camera).follow(getTag(target), null, lerp);
        });
    }
}
