package core.interfaces;

import flixel.FlxState;
import flixel.FlxBasic;

#if HSCRIPT_ALLOWED
import scripting.haxe.HScript;

import rulescript.Context;
#end

#if LUA_ALLOWED
import scripting.lua.LuaScript;
#end

interface IScriptState
{
    public var members(default, null):Array<FlxBasic>;

    #if HSCRIPT_ALLOWED
    public var hScripts:Array<HScript>;
    
    public var hScriptsContext:Context;
    #end

    #if LUA_ALLOWED
    public var luaScripts:Array<LuaScript>;
    #end

    public function loadScript(path:String, ?hsArgs:Array<Dynamic>, ?luaArgs:Array<Dynamic>):Void;
    public function loadHScript(path:String, ?args:Array<Dynamic>):Void;
    public function loadLuaScript(path:String, ?args:Array<Dynamic>):Void;

    public function setOnScripts(name:String, value:Dynamic):Void;
    public function setOnHScripts(name:String, value:Dynamic):Void;
    public function setOnLuaScripts(name:String, value:Dynamic):Void;

    public function callOnScripts(callback:String, ?arguments:Array<Dynamic> = null):Array<Dynamic>;
    public function callOnHScripts(callback:String, ?arguments:Array<Dynamic> = null):Array<Dynamic>;
    public function callOnLuaScripts(callback:String, ?arguments:Array<Dynamic> = null):Array<Dynamic>;

    public function destroyScripts():Void;
    public function destroyHScripts():Void;
    public function destroyLuaScripts():Void;

    public function add(obj:FlxBasic):FlxBasic;
    public function insert(index:Int, obj:FlxBasic):FlxBasic;
    public function remove(obj:FlxBasic, destroy:Bool = false):FlxBasic;
}