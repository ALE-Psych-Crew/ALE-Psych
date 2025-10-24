package scripting.haxe;

import rulescript.RuleScript;
import rulescript.interps.RuleScriptInterp;
import rulescript.parsers.HxParser;
import rulescript.Context;

import scripting.haxe.ALEParser;

import haxe.ds.StringMap;
import haxe.Exception;

import rulescript.Context;

class ALERuleScript extends RuleScript
{
	public var failedParsing:Bool = false;

	override public function new(scriptName:String, ?context:Context)
	{
		super(null, new ALEParser(scriptName), context);

		getParser(HxParser).allowAll();

		getInterp(RuleScriptInterp).scriptName = scriptName.replace('.', '/') + '.hx';

		this.errorHandler = onError;
	}
	
	public function onError(error:Exception):Dynamic
	{
		failedParsing = true;

		debugTrace(error.message, ERROR);
		
		return error.details();
	}

	public function call(func:String, ?args:Array<Dynamic>)
	{
		var func = variables.get(func);

		if (func != null && Reflect.isFunction(func))
		{
			try
			{
				return Reflect.callMethod(null, func, args ?? []);
			} catch(error:Exception) {
				debugTrace(error.message, ERROR);
			}
		}

		return null;
	}

	public function set(name:String, value:Dynamic)
		variables.set(name, value);
	
	public function setClass(cls:Class<Dynamic>)
	{
		set(Type.getClassName(cls).split('.').pop(), cls);
	}
}