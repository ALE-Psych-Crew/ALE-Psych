package scripting.lua.callbacks;

import flixel.util.FlxAxes;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

class LuaCamera extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
        
        /**
         * Shakes a camera
         * 
         * @param camera ID of the camera
         * @param tag ID of the shake
         * @param intensity Intensity of the shake
         * @param duration Duration of the shake
         * @param force Defines if the shake will be forced
         * @param axes Defines the axes in which the camera will shake. Can be `0x00`, `0x01`, `0x11` or `0x10`
         */
        set('cameraShake', function(camera:String, tag:String, ?intensity:Float, ?duration:Float, ?force:Bool, ?axes:FlxAxes)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).shake(intensity, duration, () -> { lua.call('onCameraShakeComplete', [tag]); }, force, axes);
        });

        /**
         * 
         */
        set('cameraFlash', function(camera:String, tag:String, ?color:FlxColor, ?duration:Float, ?force:Bool)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).flash(color, duration, () -> { lua.call('onCameraFlashComplete', [tag]); }, force);
        });

        /**
         * 
         */
        set('cameraFade', function(camera:String, tag:String, ?color:FlxColor, ?duration:Float, ?fadeIn:Bool, ?force:Bool)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).fade(color, duration, fadeIn, () -> { lua.call('onCameraFadeComplete', [tag]); }, force);
        });

        /**
         * 
         */
        set('stopCameraFX', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopFX();
        });

        /**
         * 
         */
        set('stopCameraFade', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopFade();
        });

        /**
         * 
         */
        set('stopCameraFlash', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopFlash();
        });

        /**
         * 
         */
        set('stopCameraShake', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopShake();
        });
    }
}
