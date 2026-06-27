package funkin.config;

import core.structures.ControlsData;
import core.structures.SaveData;

class ClientPrefs
{
    public static var data:SaveData = {};

	public static var custom:Dynamic = {};
	
	public static var controls:ControlsData = {};

	public static var customControls:Dynamic = {};
	
	public static function getPreference(id:String):Dynamic
		return Reflect.field(data, id) ?? Reflect.field(custom, id);

	public static function setPreference(id:String, value:Dynamic):Dynamic
	{
		if (Reflect.hasField(data, id))
			Reflect.setField(data, id, value)
		else
			Reflect.setField(custom, id, value);

		return value;
	}

	public static function getControl(groupID:String, id:String):Null<Array<Int>>
	{
		final group = Reflect.field(controls, groupID) ?? Reflect.field(customControls, groupID);

		return group == null ? null : cast Reflect.field(group, id);
	}

	public static function setControl(groupID:String, id:String, value:Array<Int>):Array<Int>
	{
		final group = Reflect.hasField(controls, groupID) ? Reflect.field(controls, groupID) : Reflect.field(customControls, groupID);

		if (group != null)
			Reflect.setField(group, id, value);

		return value;
	}
}