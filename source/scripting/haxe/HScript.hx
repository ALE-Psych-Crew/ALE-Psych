package scripting.haxe;

import core.interfaces.IScript;
import core.enums.StateType;

#if ALE_HSCRIPT
import ale.hscript.Script;
#else
import ale.rulescript.RuleScript;
#end

typedef Context = #if ALE_HSCRIPT ale.hscript.interp.Scope #else rulescript.Context #end ;

class HScript extends #if ALE_HSCRIPT Script #else RuleScript #end implements IScript
{
    public final type:StateType;

	override public function new(scriptName:String, context:Context, ?args:Array<Dynamic>, type:StateType, ?presets:Array<Class<HScriptPresetBase>>)
	{
		this.type = type;

		super(scriptName, #if ALE_HSCRIPT context, #end type == STATE ? FlxG.state : FlxG.state.subState #if !ALE_HSCRIPT , context #end);

        for (pre in presets ?? [])
            Type.createInstance(pre, [this]);

		set('game', #if ALE_HSCRIPT interp.superInstance #else superInstance #end);

		#if ALE_HSCRIPT
		execute();
		#else
		run();
		#end
		
		call('new', args);
	}
}