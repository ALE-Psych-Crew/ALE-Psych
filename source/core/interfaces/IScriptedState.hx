package core.interfaces;

import core.enums.ScriptCallType;

import scripting.ScriptsManager;

interface IScriptedState extends IState
{
    public var scriptsManager:ScriptsManager;
}