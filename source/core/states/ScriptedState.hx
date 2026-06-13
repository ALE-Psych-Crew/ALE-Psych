package core.states;

import core.interfaces.IScriptedState;

import scripting.ScriptsManager;

class ScriptedState extends MusicBeatState implements IScriptedState
{
    public static var instance:ScriptedState;

    public var scriptsManager:ScriptsManager;

    public function new(?globalArgs:Array<Dynamic> #if ALLOW_HSCRIPT , ?haxeArgs:Array<Dynamic> #end #if ALLOW_LUA , ?luaArgs:Array<Dynamic> #end)
    {
        super();

        scriptsManager = new ScriptsManager(STATE, globalArgs #if ALLOW_HSCRIPT , haxeArgs #end #if ALLOW_LUA , luaArgs #end);
    }

    override function create()
    {
        instance = this;

        super.create();

        if (CoolVars.meta.hotReloading && CoolVars.meta.developerMode)
            FlxG.autoPause = false;
    }

    override function destroy()
    {
        super.destroy();

        if (CoolVars.meta.hotReloading && CoolVars.meta.developerMode)
            FlxG.autoPause = true;

        instance = null;
    }
}