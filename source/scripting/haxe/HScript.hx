package scripting.haxe;

import core.enums.ScriptType;

import haxe.ds.StringMap;
import haxe.Exception;

import flixel.FlxG;
import flixel.FlxObject;

import sys.FileSystem;
import sys.io.File;

import scripting.haxe.HScriptImports;

import rulescript.Context;

class HScript extends ALERuleScript
{
	public final type:ScriptType;

	override public function new(filePath:String, context:Context, type:ScriptType, scriptName:String)
	{
		this.type = type;

		super(scriptName, context);

		preset();

		scriptName = filePath.split('/').pop();

		if (FileSystem.exists(filePath))
			tryExecute(File.getContent(filePath), onError);
	}

	function preset():Void
	{
		var instanceVariables:StringMap<Dynamic> = new StringMap<Dynamic>();
		
		if (type == STATE)
		{
			instanceVariables = [
				'game' => FlxG.state,
				'add' => FlxG.state.add,
				'insert' => FlxG.state.insert,
				'remove' => FlxG.state.remove,
				'openSubState' => FlxG.state.openSubState,
				//'debugPrint' => ScriptState.instance.debugPrint,
				'getObjectOrder' => function(obj:FlxObject)
				{
					return FlxG.state.members.indexOf(obj);
				},
				'setObjectOrder' => function(obj:FlxObject, index:Int)
				{
					FlxG.state.remove(obj);
					FlxG.state.insert(index, obj);
				}
			];
		} else if (type == SUBSTATE) {
			instanceVariables = [
				'game' => FlxG.state.subState,
				'add' => FlxG.state.subState.add,
				'insert' => FlxG.state.subState.insert,
				'remove' => FlxG.state.subState.remove,
				'close' => FlxG.state.subState.close,
				//'debugPrint' => ScriptSubState.instance.debugPrint,
				'getObjectOrder' => function(obj:FlxObject)
				{
					return FlxG.state.subState.members.indexOf(obj);
				},
				'setObjectOrder' => function(obj:FlxObject, index:Int)
				{
					FlxG.state.subState.remove(obj);
					FlxG.state.subState.insert(index, obj);
				}
			];
		};

		for (insVar in instanceVariables.keys())
			set(insVar, instanceVariables.get(insVar));
	}
}