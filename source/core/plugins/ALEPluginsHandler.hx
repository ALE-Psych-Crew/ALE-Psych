package core.plugins;

import flixel.FlxBasic;

class ALEPluginsHandler
{
	public static var pluginsCamera:FlxCamera;

	public static final plugins:Array<FlxBasic> = [];

	static function moveCameraToTop(camera:FlxCamera)
	{
		if (camera == pluginsCamera && pluginsCamera == null)
			return;

		if (FlxG.cameras.list.length == 0)
		{
			FlxG.signals.postStateSwitch.addOnce(moveCameraToTop.bind(null));

			return;
		}

		if (FlxG.cameras.list.contains(pluginsCamera))
			FlxG.cameras.list.remove(pluginsCamera);

		if (FlxG.game.contains(pluginsCamera.flashSprite))
			FlxG.game.removeChild(pluginsCamera.flashSprite);

		@:privateAccess FlxG.game.addChildAt(pluginsCamera.flashSprite, FlxG.game.getChildIndex(FlxG.game._inputContainer));

		FlxG.cameras.list.push(pluginsCamera);
	}

	static function resetCamera(camera:FlxCamera)
	{
		if (camera == pluginsCamera)
		{
			if (!camera.exists)
			{
				pluginsCamera = new ALECamera();

				for (obj in plugins)
					obj.cameras = [pluginsCamera];

				moveCameraToTop(null);

				pluginsCamera.bgColor.alpha = 0;

				pluginsCamera.ID = FlxG.cameras.list.length - 1;
			} else {
				moveCameraToTop(null);
			}
		} else {
			moveCameraToTop(null);
		}
	}

	static var initialized:Bool = false;

	@:unreflective public static function initialize()
	{
		if (initialized)
			return;

		pluginsCamera = new ALECamera();
		FlxG.cameras.add(pluginsCamera, false);

		FlxG.plugins.drawOnTop = true;

		FlxG.cameras.cameraAdded.add(moveCameraToTop);
		FlxG.cameras.cameraRemoved.add(resetCamera);

		initialized = true;
	}

	@:unreflective public static function finish()
	{
		if (!initialized)
			return;

		for (plugin in plugins)
			remove(plugin);

		FlxG.cameras.remove(pluginsCamera, true);

		FlxG.cameras.cameraAdded.remove(moveCameraToTop);
		FlxG.cameras.cameraRemoved.remove(resetCamera);

		pluginsCamera = null;
		
		initialized = false;

		plugins.resize(0);
	}

	@:unreflective public static function reset()
	{
		if (initialized)
			finish();

		initialize();
	}

	public static function add(plugin:FlxBasic)
	{
		if (!initialized || plugins.contains(plugin))
			return;

		FlxG.plugins.addPlugin(plugin);

		plugin.cameras = [pluginsCamera];

		plugins.push(plugin);
	}

	public static function remove(plugin:FlxBasic)
	{
		if (!initialized || !plugins.contains(plugin))
			return;

		FlxG.plugins.remove(plugin);

		if (plugin.cameras.contains(pluginsCamera))
			plugin.cameras.remove(pluginsCamera);

		if (plugin.cameras.length <= 0)
			plugin.cameras = [FlxG.camera];

		plugins.remove(plugin);
	}
}