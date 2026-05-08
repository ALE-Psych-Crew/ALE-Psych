package core.plugins;

import flixel.FlxBasic;

class PluginsHandler
{
	public static var topCamera:FlxCamera;

	public static final plugins:Array<FlxBasic> = [];

	static function onCameraAdd(camera:FlxCamera)
	{
		if (camera == topCamera && camera == null)
			return;

		if (FlxG.cameras.list.length == 0)
		{
			FlxG.signals.postStateSwitch.addOnce(onCameraAdd.bind(null));

			return;
		}
		
		CoolUtil.moveCameraToTop(topCamera);
	}

	static function onCameraRemove(camera:FlxCamera)
	{
		if (camera == topCamera && !camera.exists)
		{
			topCamera = new Camera();

			for (obj in plugins)
				obj.cameras = [topCamera];
		}

		onCameraAdd(null);
	}

	static var initialized:Bool = false;

	@:unreflective public static function init()
	{
		if (initialized)
			return;

		topCamera = new Camera();
		FlxG.cameras.add(topCamera, false);

		FlxG.cameras.cameraAdded.add(onCameraAdd);
		FlxG.cameras.cameraRemoved.add(onCameraRemove);

		initialized = true;
	}

	@:unreflective public static function destroy()
	{
		if (!initialized)
			return;

		for (plugin in plugins.copy())
			remove(plugin);

		FlxG.cameras.remove(topCamera, true);

		FlxG.cameras.cameraAdded.remove(onCameraAdd);
		FlxG.cameras.cameraRemoved.remove(onCameraRemove);

		topCamera = null;
		
		initialized = false;
	}

	public static function add(plugin:FlxBasic)
	{
		if (!initialized || plugins.contains(plugin))
			return;

		FlxG.plugins.addPlugin(plugin);

		plugin.cameras = [topCamera];

		plugins.push(plugin);
	}

	public static function remove(plugin:FlxBasic)
	{
		if (!initialized || !plugins.contains(plugin))
			return;

		FlxG.plugins.remove(plugin);

		if (plugin.cameras.contains(topCamera))
			plugin.cameras.remove(topCamera);

		if (plugin.cameras.length <= 0)
			plugin.cameras = [FlxG.camera];

		plugins.remove(plugin);

		plugin.destroy();
	}
}