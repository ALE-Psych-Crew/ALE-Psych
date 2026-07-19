package utils.cool;

import core.enums.StateType;

import flixel.util.typeLimit.OneOfThree;

import flixel.FlxSubState;
import flixel.FlxState;

#if ALLOW_HSCRIPT
import ale.rulescript.RuleScriptGlobal;
#end

class StateUtil
{
	public static function switchState(st:OneOfThree<String, Class<FlxState>, FlxState>, ?skipTransIn:Bool, ?skipTransOut:Bool)
	{
		var state:FlxState = null;

		if (st is String)
			state = new CustomState(st);

		if (st is Class)
			state = Type.createInstance(st, []);

		if (st is FlxState)
			state = st;

		if (state == null)
			return;

		if (state is CustomState)
		{
            final custom:String = cast(state, CustomState).name;
			
            if (Paths.exists('scripts/states/' + custom + RuleScriptGlobal.SCRIPT_EXTENSION) || Paths.exists('scripts/states/' + custom + '.lua') || Paths.isDirectory('scripts/states/' + custom))
                transitionSwitch(state, skipTransIn, skipTransOut);
            else
                debugTrace('Custom State called "' + custom + '" doesn\'t Exist', MISSING_FILE);
		} else {
			transitionSwitch(state, skipTransIn, skipTransOut);
		}
	}

	static function transitionSwitch(state:FlxState, ?skipTransIn:Bool, ?skipTransOut:Bool)
	{
		if (skipTransIn != null)
			CoolVars.skipTransIn = skipTransIn;

		if (skipTransOut != null)
			CoolVars.skipTransOut = skipTransOut; 

        if (CoolVars.skipTransIn)
		{
            CoolVars.skipTransIn = false;

			FlxG.switchState(state);
		} else {
			openSubState(new CustomSubState(
				'FadeTransition',
                [true, () -> FlxG.switchState(state)]
			));
		}
	}

	public static function openSubState(sub:OneOfThree<String, Class<FlxSubState>, FlxSubState> = null)
	{
		var subState:FlxSubState = null;

		if (sub is String)
			subState = new CustomSubState(sub);

		if (sub is Class)
			subState = Type.createInstance(sub, []);

		if (sub is FlxSubState)
			subState = sub;

		if (subState == null)
			return;

        if (subState is CustomSubState)
        {
            final custom:String = cast(subState, CustomSubState).name;
            
            if (Paths.exists('scripts/substates/' + custom + RuleScriptGlobal.SCRIPT_EXTENSION) || Paths.exists('scripts/substates/' + custom + '.lua') || Paths.isDirectory('scripts/substates/' + custom))
                FlxG.state.openSubState(subState);
            else
                debugTrace('Custom SubState called "' + custom + '" doesn\'t Exist', MISSING_FILE);
        } else {
			FlxG.state.openSubState(subState);
		}
	}

	public static function resolveState(name:String, type:StateType):String
	{
		if (CoolVars.meta != null)
		{
			final group:Any = switch (type)
			{
				case STATE:
					CoolVars.meta.states;

				case SUBSTATE:
					CoolVars.meta.substates;
			}

			if (group != null)
				name = Reflect.field(group, name) ?? name;
		}

		return name;
	}
}