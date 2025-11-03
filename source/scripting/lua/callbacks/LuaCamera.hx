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
         * Flashes a camera with a color overlay
         *
         * @param camera ID of the camera
         * @param tag ID of the flash effect
         * @param color Overlay color
         * @param duration Duration of the flash
         * @param force Defines whether the flash will be forced
         */
        set('cameraFlash', function(camera:String, tag:String, ?color:FlxColor, ?duration:Float, ?force:Bool)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).flash(color, duration, () -> { lua.call('onCameraFlashComplete', [tag]); }, force);
        });

        /**
         * Fades a camera in or out to a color
         *
         * @param camera ID of the camera
         * @param tag ID of the fade effect
         * @param color Fade color
         * @param duration Duration of the fade
         * @param fadeIn Defines whether the fade will fade in (`true`) or out (`false`)
         * @param force Defines whether the fade will be forced
         */
        set('cameraFade', function(camera:String, tag:String, ?color:FlxColor, ?duration:Float, ?fadeIn:Bool, ?force:Bool)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).fade(color, duration, fadeIn, () -> { lua.call('onCameraFadeComplete', [tag]); }, force);
        });

        /**
         * Stops all camera effects (shake, fade and flash)
         *
         * @param camera ID of the camera
         */
        set('stopCameraFX', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopFX();
        });

        /**
         * Stops the current camera fade
         *
         * @param camera ID of the camera
         */
        set('stopCameraFade', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopFade();
        });

        /**
         * Stops the current camera flash
         *
         * @param camera ID of the camera
         */
        set('stopCameraFlash', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopFlash();
        });

        /**
         * Stops the current camera shake
         *
         * @param camera ID of the camera
         */
        set('stopCameraShake', function(camera:String)
        {
            if (tagIs(camera, FlxCamera))
                getTag(camera).stopShake();
        });

        /**
         * Makes a camera follow an object
         *
         * @param camera ID of the camera
         * @param target ID of the object to follow
         * @param lerp Lerp value used by the camera follow
         */
        set('cameraFollow', function(camera:String, target:String, ?lerp:Float)
        {
            if (tagIs(camera, FlxCamera) && tagIs(target, FlxObject))
                getTag(camera).follow(getTag(target), null, lerp);
        });
    }
}
