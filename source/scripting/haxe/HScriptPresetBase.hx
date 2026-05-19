package scripting.haxe;

import core.interfaces.IScriptedState;

class HScriptPresetBase
{
    public var game:IScriptedState;

    public function new(script:HScript)
        game = script.type == STATE ? ScriptedState.instance : ScriptedSubState.instance;
}