package utils.cool;

import core.plugins.PluginsHandler;

class CameraUtil
{
    static function prepareCameraPositionOverride(camera:FlxCamera)
    {
        if (FlxG.cameras.list.contains(camera))
            FlxG.cameras.list.remove(camera);

        if (FlxG.game.contains(camera.flashSprite))
            FlxG.game.removeChild(camera.flashSprite);
    }

    public static function moveCameraToTop(camera:FlxCamera)
    {
        prepareCameraPositionOverride(camera);

        @:privateAccess FlxG.game.addChildAt(camera.flashSprite, FlxG.game.getChildIndex(FlxG.game._inputContainer));

        FlxG.cameras.list.push(camera);
    }

    public static function moveCameraToBottom(camera:FlxCamera)
    {
        prepareCameraPositionOverride(camera);

        @:privateAccess FlxG.game.addChildAt(camera.flashSprite, 0);

        FlxG.cameras.list.push(camera);
    }
}