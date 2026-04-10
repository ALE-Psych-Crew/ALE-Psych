package utils.cool;

class OptionsUtil
{
	public static function getPref(id:String):Dynamic
		return Reflect.getProperty(ClientPrefs.data, id) ?? Reflect.getProperty(ClientPrefs.custom, id);
	
	public static function getControl(groupID:String, id:String):Null<Array<Int>>
	{
		final group = Reflect.field(ClientPrefs.controls, groupID) ?? Reflect.field(ClientPrefs.customControls, groupID);

		if (group == null)
			return null;

		return cast Reflect.getProperty(group, id);
	}
}