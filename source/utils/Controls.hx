package utils;

import core.structures.UIControls;
import core.structures.NotesControls;
import core.structures.EngineControls;

import flixel.input.keyboard.FlxKey;

import api.MobileAPI;

class Controls
{
    public static var NOTE_LEFT(get, never):Bool;
    static function get_NOTE_LEFT():Bool
        return anyPressed(ClientPrefs.controls.notes.left);

    public static var NOTE_LEFT_P(get, never):Bool;
    static function get_NOTE_LEFT_P():Bool
        return anyJustPressed(ClientPrefs.controls.notes.left);

    public static var NOTE_LEFT_R(get, never):Bool;
    static function get_NOTE_LEFT_R():Bool
        return anyJustReleased(ClientPrefs.controls.notes.left);

    public static var NOTE_DOWN(get, never):Bool;
    static function get_NOTE_DOWN():Bool
        return anyPressed(ClientPrefs.controls.notes.down);

    public static var NOTE_DOWN_P(get, never):Bool;
    static function get_NOTE_DOWN_P():Bool
        return anyJustPressed(ClientPrefs.controls.notes.down);

    public static var NOTE_DOWN_R(get, never):Bool;
    static function get_NOTE_DOWN_R():Bool
        return anyJustReleased(ClientPrefs.controls.notes.down);

    public static var NOTE_UP(get, never):Bool;
    static function get_NOTE_UP():Bool
        return anyPressed(ClientPrefs.controls.notes.up);

    public static var NOTE_UP_P(get, never):Bool;
    static function get_NOTE_UP_P():Bool
        return anyJustPressed(ClientPrefs.controls.notes.up);

    public static var NOTE_UP_R(get, never):Bool;
    static function get_NOTE_UP_R():Bool
        return anyJustReleased(ClientPrefs.controls.notes.up);

    public static var NOTE_RIGHT(get, never):Bool;
    static function get_NOTE_RIGHT():Bool
        return anyPressed(ClientPrefs.controls.notes.right);

    public static var NOTE_RIGHT_P(get, never):Bool;
    static function get_NOTE_RIGHT_P():Bool
        return anyJustPressed(ClientPrefs.controls.notes.right);

    public static var NOTE_RIGHT_R(get, never):Bool;
    static function get_NOTE_RIGHT_R():Bool
        return anyJustReleased(ClientPrefs.controls.notes.right);

    @:unreflective static var ui:UIControls = ClientPrefs.controls.ui;

    public static var UI_LEFT(get, never):Bool;
    static function get_UI_LEFT():Bool
        return anyPressed(ClientPrefs.controls.ui.left);

    public static var UI_LEFT_P(get, never):Bool;
    static function get_UI_LEFT_P():Bool
        return anyJustPressed(ClientPrefs.controls.ui.left);

    public static var UI_LEFT_R(get, never):Bool;
    static function get_UI_LEFT_R():Bool
        return anyJustReleased(ClientPrefs.controls.ui.left);

    public static var UI_DOWN(get, never):Bool;
    static function get_UI_DOWN():Bool
        return anyPressed(ClientPrefs.controls.ui.down);

    public static var UI_DOWN_P(get, never):Bool;
    static function get_UI_DOWN_P():Bool
        return anyJustPressed(ClientPrefs.controls.ui.down);

    public static var UI_DOWN_R(get, never):Bool;
    static function get_UI_DOWN_R():Bool
        return anyJustReleased(ClientPrefs.controls.ui.down);

    public static var UI_UP(get, never):Bool;
    static function get_UI_UP():Bool
        return anyPressed(ClientPrefs.controls.ui.up);

    public static var UI_UP_P(get, never):Bool;
    static function get_UI_UP_P():Bool
        return anyJustPressed(ClientPrefs.controls.ui.up);

    public static var UI_UP_R(get, never):Bool;
    static function get_UI_UP_R():Bool
        return anyJustReleased(ClientPrefs.controls.ui.up);

    public static var UI_RIGHT(get, never):Bool;
    static function get_UI_RIGHT():Bool
        return anyPressed(ClientPrefs.controls.ui.right);

    public static var UI_RIGHT_P(get, never):Bool;
    static function get_UI_RIGHT_P():Bool
        return anyJustPressed(ClientPrefs.controls.ui.right);

    public static var UI_RIGHT_R(get, never):Bool;
    static function get_UI_RIGHT_R():Bool
        return anyJustReleased(ClientPrefs.controls.ui.right);

    public static var ACCEPT(get, never):Bool;
    static function get_ACCEPT():Bool
        return anyJustPressed(ClientPrefs.controls.ui.accept);

    public static var BACK(get, never):Bool;
    static function get_BACK():Bool
    {
        var backKeys = ClientPrefs.controls.ui.back;

        if (backKeys == null || backKeys.length == 0)
            return false;

        backKeys = backKeys.filter(k -> k > 0);

        if (backKeys.length == 0)
            return false;

        return anyJustPressed(backKeys);
    }

    public static var RESET(get, never):Bool;
    static function get_RESET():Bool
        return anyJustPressed(ClientPrefs.controls.ui.reset);

    public static var PAUSE(get, never):Bool;
    static function get_PAUSE():Bool
        return anyJustPressed(ClientPrefs.controls.ui.pause);

    public static var ENGINE_CHART(get, never):Bool;
    static function get_ENGINE_CHART():Bool
        return anyJustPressed(ClientPrefs.controls.engine.chart);

    public static var ENGINE_CHARACTER(get, never):Bool;
    static function get_ENGINE_CHARACTER():Bool
        return anyJustPressed(ClientPrefs.controls.engine.character);

    public static var ENGINE_MASTER_EDITOR(get, never):Bool;
    static function get_ENGINE_MASTER_EDITOR():Bool
        return anyJustPressed(ClientPrefs.controls.engine.master_menu);

    public static var CONTROL(get, never):Bool;
    static function get_CONTROL():Bool
        return FlxG.keys.pressed.CONTROL;

    public static var SHIFT(get, never):Bool;
    static function get_SHIFT():Bool
        return FlxG.keys.pressed.SHIFT;

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

    public static function anyPressed(keys:Array<FlxKey>)
        return MobileAPI.checkKeys(keys, PRESSED) || FlxG.keys.anyPressed(keys);
    
    public static function anyJustPressed(keys:Array<FlxKey>)
        return MobileAPI.checkKeys(keys, JUST_PRESSED) || FlxG.keys.anyJustPressed(keys);
    
    public static function anyJustReleased(keys:Array<FlxKey>)
        return MobileAPI.checkKeys(keys, JUST_RELEASED) || FlxG.keys.anyJustReleased(keys);
}
