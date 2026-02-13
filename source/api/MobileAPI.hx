package api;

#if mobile
import extension.eightsines.EsOrientation;
#end

import flixel.input.keyboard.FlxKey;

import core.plugins.MobileControlsPlugin;

import core.enums.ScreenOrientation;
import core.enums.StateType;
import core.enums.KeyCheck;
import core.enums.KeyCheck;

import core.Main;

class MobileAPI
{
    public static var orientation:ScreenOrientation = LANDSCAPE;

    public static var controls(get, never):MobileControlsPlugin;
    static function get_controls():MobileControlsPlugin
        return Main.mobileControlsPlugin;

    public static function setOrientation(type:ScreenOrientation)
    {
        #if mobile
        EsOrientation.setScreenOrientation(type.toEsOrientation());
        #end

        orientation = type;
    }

    public static function restartButtons(subState:Bool)
        controls?.restartButtons(subState ? controls.subStateButtons : controls.stateButtons);

    public static function destroyButtons(subState:Bool)
        controls?.destroyButtons(subState ? controls.subStateButtons : controls.stateButtons);

    public static function toggleButtons(subState:Bool, show:Bool)
        controls?.toggleButtons(subState ? controls.subStateButtons : controls.stateButtons, show);

    public static function createButtons(x:Float, y:Float, buttonsData:Array<{label:String, keys:Array<FlxKey>}>, ?radius:Int, ?subState:Bool)
        controls?.createButtons(x, y, buttonsData, radius, subState);

    public static function checkKeys(keys:Array<Int>, prop:KeyCheck):Bool
        return controls == null ? false : controls.checkKeys(keys, prop);
}