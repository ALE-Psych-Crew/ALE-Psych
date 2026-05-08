package;

import core.enums.ScriptCallType;

#if ALLOW_HSCRIPT
import scripting.haxe.HScript;

import rulescript.Context;
#end

interface IScriptedState extends IGroup
{
    public var scripts:Array<IScript>;

    #if ALLOW_HSCRIPT
    public var haxeScripts:Array<HScript>;

    public var haxeScriptsContext:Context;

    public function loadHScript(path:String, ?args:Array<Dynamic>):Void;

    public function setOnHScripts(name:String, value:Dynamic):Void;

    public function callOnHScripts(callback:String, ?arguments:Array<Dynamic> = null):Array<Dynamic>;
    #end

    public function loadScript(path:String, ?hsArgs:Array<Dynamic>, ?luaArgs:Array<Dynamic>):Void;

    public function setOnScripts(name:String, value:Dynamic):Void;

    public function callOnScripts(callback:String, ?arguments:Array<Dynamic> = null):Array<Dynamic>;

    public function scriptCallbackCall(type:ScriptCallType, id:String, ?globalArgs:Array<Dynamic>, ?hxArgs:Array<Dynamic>, ?luaArgs:Array<Dynamic>):Bool;

    public function destroyScripts():Void;
}