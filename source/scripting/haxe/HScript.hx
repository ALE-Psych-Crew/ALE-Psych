package scripting.haxe;

import scripting.haxe.HScriptPresetBase;

import core.enums.StateType;

import ale.rulescript.RuleScript;
import rulescript.Context;

class HScript extends RuleScript
{
	public final type:StateType;

	override public function new(scriptName:String, context:Context, ?args:Array<Dynamic>, type:StateType, ?customCallbacks:Array<Class<HScriptPresetBase>>)
	{
		this.type = type;

		super(scriptName, type == STATE ? FlxG.state : FlxG.state.subState, context);

		set('game', superInstance);

        for (callbacks in (customCallbacks ?? []))
            Type.createInstance(callbacks, [this]);

		run();
		
		call('new', args);
	}
}