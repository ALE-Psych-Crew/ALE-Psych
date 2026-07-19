package scripting.haxe;

import core.interfaces.IScript;
import core.enums.StateType;

import ale.rulescript.RuleScript;

import rulescript.Context;

class HScript extends RuleScript implements IScript
{
    public final type:StateType;

	override public function new(scriptName:String, context:Context, ?args:Array<Dynamic>, type:StateType, ?presets:Array<Class<HScriptPresetBase>>)
	{
		this.type = type;

		super(scriptName, type == STATE ? FlxG.state : FlxG.state.subState, context);

        for (pre in presets ?? [])
            Type.createInstance(pre, [this]);

		set('game', superInstance);

		run();
		
		call('new', args);
	}
}