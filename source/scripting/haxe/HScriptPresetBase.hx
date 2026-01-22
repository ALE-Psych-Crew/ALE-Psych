package scripting.haxe;

import core.interfaces.IScriptState;

class HScriptPresetBase
{
    public var game:IScriptState;

    public function new(hs:HScript)
    {
		  game = hs.type == STATE ? ScriptState.instance : ScriptSubState.instance;
    }
}