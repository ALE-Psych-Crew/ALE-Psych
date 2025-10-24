package core.interfaces;

import flixel.FlxState;

#if HSCRIPT_ALLOWED
import scripting.haxe.HScript;

import rulescript.Context;
#end

#if LUA_ALLOWED
import scripting.lua.LuaScript;
#end

interface IScriptState
{
    #if HSCRIPT_ALLOWED
    public var hScripts:Array<HScript>;
    
    public var hScriptsContext:Context;
    #end

    #if LUA_ALLOWED
    public var luaScripts:Array<LuaScript>;
    #end

    public function loadScript(path:String):Void;
    public function loadHScript(path:String):Void;
    public function loadLuaScript(path:String):Void;

    public function setOnScripts(name:String, value:Dynamic):Void;
    public function setOnHScripts(name:String, value:Dynamic):Void;
    public function setOnLuaScripts(name:String, value:Dynamic):Void;

    public function callOnScripts(callback:String, ?arguments:Array<Dynamic> = null):Array<Dynamic>;
    public function callOnHScripts(callback:String, ?arguments:Array<Dynamic> = null):Array<Dynamic>;
    public function callOnLuaScripts(callback:String, ?arguments:Array<Dynamic> = null):Array<Dynamic>;

    public function destroyScripts():Void;
    public function destroyHScripts():Void;
    public function destroyLuaScripts():Void;
}