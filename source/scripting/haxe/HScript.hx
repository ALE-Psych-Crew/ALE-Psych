package scripting.haxe;

import core.interfaces.IScript;
import core.enums.StateType;

import ale.hscript.interp.Scope;
import ale.hscript.Script;

class HScript extends Script implements IScript
{
    public final type:StateType;

	override public function new(scriptName:String, context:Scope, ?args:Array<Dynamic>, type:StateType, ?presets:Array<Class<HScriptPresetBase>>)
	{
		this.type = type;

		super(scriptName, context, type == STATE ? FlxG.state : FlxG.state.subState);

        for (pre in presets ?? [])
            Type.createInstance(pre, [this]);

		set('game', interp.superInstance);

		execute();
		
		call('new', args);
	}
}