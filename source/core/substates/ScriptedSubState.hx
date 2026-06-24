package core.substates;

import core.interfaces.IScriptedState;

import scripting.ScriptsManager;

class ScriptedSubState extends MusicBeatSubState implements IScriptedState
{
    public static var instance:ScriptedSubState;

    public var scriptsManager:ScriptsManager;

    public function new(?globalArgs:Array<Dynamic> #if ALLOW_HSCRIPT , ?haxeArgs:Array<Dynamic> #end #if ALLOW_LUA , ?luaArgs:Array<Dynamic> #end)
    {
        super();

        scriptsManager = new ScriptsManager(SUBSTATE, globalArgs #if ALLOW_HSCRIPT , haxeArgs #end #if ALLOW_LUA , luaArgs #end, true);
    }

    override function create()
    {
        instance = this;

        super.create();
    }

    override function destroy()
    {
        super.destroy();

        instance = null;
    }

    public function reset()
    {
        close();

        CoolUtil.openSubState(new ScriptedSubState(scriptsManager.globalArguments #if ALLOW_HSCRIPT , scriptsManager.haxeArguments #end #if ALLOW_LUA , scriptsManager.luaArguments #end));
    }
}