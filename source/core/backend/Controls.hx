package core.backend;

import core.structures.UIControls;
import core.structures.NotesControls;
import core.structures.EngineControls;

import flixel.input.keyboard.FlxKey;

class Controls
{
    public static var NOTE_LEFT(get, never):Bool;
    static function get_NOTE_LEFT():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyPressed(ClientPrefs.controls.notes.left);

        #if !mobile return FlxG.keys.anyPressed(ClientPrefs.controls.notes.left); #end
    }

    public static var NOTE_LEFT_P(get, never):Bool;
    static function get_NOTE_LEFT_P():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.notes.left);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.notes.left); #end
    }

    public static var NOTE_LEFT_R(get, never):Bool;
    static function get_NOTE_LEFT_R():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustReleased(ClientPrefs.controls.notes.left);

        #if !mobile return FlxG.keys.anyJustReleased(ClientPrefs.controls.notes.left); #end
    }

    public static var NOTE_DOWN(get, never):Bool;
    static function get_NOTE_DOWN():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyPressed(ClientPrefs.controls.notes.down);

        #if !mobile return FlxG.keys.anyPressed(ClientPrefs.controls.notes.down); #end
    }

    public static var NOTE_DOWN_P(get, never):Bool;
    static function get_NOTE_DOWN_P():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.notes.down);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.notes.down); #end
    }

    public static var NOTE_DOWN_R(get, never):Bool;
    static function get_NOTE_DOWN_R():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustReleased(ClientPrefs.controls.notes.down);

        #if !mobile return FlxG.keys.anyJustReleased(ClientPrefs.controls.notes.down); #end
    }

    public static var NOTE_UP(get, never):Bool;
    static function get_NOTE_UP():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyPressed(ClientPrefs.controls.notes.up);
        
        #if !mobile return FlxG.keys.anyPressed(ClientPrefs.controls.notes.up); #end
    }

    public static var NOTE_UP_P(get, never):Bool;
    static function get_NOTE_UP_P():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.notes.up);
        
        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.notes.up); #end
    }

    public static var NOTE_UP_R(get, never):Bool;
    static function get_NOTE_UP_R():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustReleased(ClientPrefs.controls.notes.up);

        #if !mobile return FlxG.keys.anyJustReleased(ClientPrefs.controls.notes.up); #end
    }

    public static var NOTE_RIGHT(get, never):Bool;
    static function get_NOTE_RIGHT():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyPressed(ClientPrefs.controls.notes.right);

        #if !mobile return FlxG.keys.anyPressed(ClientPrefs.controls.notes.right); #end
    }

    public static var NOTE_RIGHT_P(get, never):Bool;
    static function get_NOTE_RIGHT_P():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.notes.right);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.notes.right); #end
    }

    public static var NOTE_RIGHT_R(get, never):Bool;
    static function get_NOTE_RIGHT_R():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustReleased(ClientPrefs.controls.notes.right);

        #if !mobile return FlxG.keys.anyJustReleased(ClientPrefs.controls.notes.right); #end
    }
    
    @:unreflective static var ui:UIControls = ClientPrefs.controls.ui;

    public static var UI_LEFT(get, never):Bool;
    static function get_UI_LEFT():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyPressed(ClientPrefs.controls.ui.left);

        #if !mobile return FlxG.keys.anyPressed(ClientPrefs.controls.ui.left); #end
    }

    public static var UI_LEFT_P(get, never):Bool;
    static function get_UI_LEFT_P():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.ui.left);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.ui.left); #end
    }

    public static var UI_LEFT_R(get, never):Bool;
    static function get_UI_LEFT_R():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustReleased(ClientPrefs.controls.ui.left);

        #if !mobile return FlxG.keys.anyJustReleased(ClientPrefs.controls.ui.left); #end
    }

    public static var UI_DOWN(get, never):Bool;
    static function get_UI_DOWN():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyPressed(ClientPrefs.controls.ui.down);

        #if !mobile return FlxG.keys.anyPressed(ClientPrefs.controls.ui.down); #end
    }

    public static var UI_DOWN_P(get, never):Bool;
    static function get_UI_DOWN_P():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.ui.down);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.ui.down); #end
    }

    public static var UI_DOWN_R(get, never):Bool;
    static function get_UI_DOWN_R():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustReleased(ClientPrefs.controls.ui.down);

        #if !mobile return FlxG.keys.anyJustReleased(ClientPrefs.controls.ui.down); #end
    }

    public static var UI_UP(get, never):Bool;
    static function get_UI_UP():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyPressed(ClientPrefs.controls.ui.up);

        #if !mobile return FlxG.keys.anyPressed(ClientPrefs.controls.ui.up); #end
    }

    public static var UI_UP_P(get, never):Bool;
    static function get_UI_UP_P():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.ui.up);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.ui.up); #end
    }

    public static var UI_UP_R(get, never):Bool;
    static function get_UI_UP_R():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustReleased(ClientPrefs.controls.ui.up);

        #if !mobile return FlxG.keys.anyJustReleased(ClientPrefs.controls.ui.up); #end
    }

    public static var UI_RIGHT(get, never):Bool;
    static function get_UI_RIGHT():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyPressed(ClientPrefs.controls.ui.right);

        #if !mobile return FlxG.keys.anyPressed(ClientPrefs.controls.ui.right); #end
    }

    public static var UI_RIGHT_P(get, never):Bool;
    static function get_UI_RIGHT_P():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.ui.right);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.ui.right); #end
    }

    public static var UI_RIGHT_R(get, never):Bool;
    static function get_UI_RIGHT_R():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustReleased(ClientPrefs.controls.ui.right);

        #if !mobile return FlxG.keys.anyJustReleased(ClientPrefs.controls.ui.right); #end
    }

    public static var ACCEPT(get, never):Bool;
    static function get_ACCEPT():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.ui.accept);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.ui.accept); #end
    }

    public static var BACK(get, never):Bool;
    static function get_BACK():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.ui.back);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.ui.back); #end
    }

    public static var RESET(get, never):Bool;
    static function get_RESET():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.ui.reset);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.ui.reset); #end
    }

    public static var PAUSE(get, never):Bool;
    static function get_PAUSE():Bool
    {
        #if android
        if (FlxG.android.justReleased.BACK)
            return FlxG.android.justReleased.BACK;
        #end

        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.ui.pause);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.ui.pause); #end
    }

    public static var ENGINE_CHART(get, never):Bool;
    static function get_ENGINE_CHART():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.engine.chart);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.engine.chart); #end
    }

    public static var ENGINE_CHARACTER(get, never):Bool;
    static function get_ENGINE_CHARACTER():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.engine.character);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.engine.character); #end
    }

    public static var ENGINE_MASTER_EDITOR(get, never):Bool;
    static function get_ENGINE_MASTER_EDITOR():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyJustPressed(ClientPrefs.controls.engine.master_menu);

        #if !mobile return FlxG.keys.anyJustPressed(ClientPrefs.controls.engine.master_menu); #end
    }

    public static var CONTROL(get, never):Bool;
    static function get_CONTROL():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyPressed([FlxKey.CONTROL]);

        #if !mobile return FlxG.keys.pressed.CONTROL; #end
    }

    public static var SHIFT(get, never):Bool;
    static function get_SHIFT():Bool
    {
        #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
            return MobileControls.anyPressed([FlxKey.SHIFT]);

        #if !mobile return FlxG.keys.pressed.SHIFT; #end
    }

    public static var MOUSE_WHEEL(get, never):Bool;
    static function get_MOUSE_WHEEL():Bool
        return FlxG.mouse.wheel != 0;
    
    public static var MOUSE_WHEEL_DOWN(get, never):Bool;
    static function get_MOUSE_WHEEL_DOWN():Bool
        return FlxG.mouse.wheel < 0;

    public static var MOUSE_WHEEL_UP(get, never):Bool;
    static function get_MOUSE_WHEEL_UP():Bool
        return FlxG.mouse.wheel > 0;

    public static var MOUSE(get, never):Bool;
    static function get_MOUSE():Bool
        return FlxG.mouse.pressed;
    
    public static var MOUSE_P(get, never):Bool;
    static function get_MOUSE_P():Bool
        return FlxG.mouse.justPressed;

    public static var MOUSE_R(get, never):Bool;
    static function get_MOUSE_R():Bool
        return FlxG.mouse.justReleased;
}