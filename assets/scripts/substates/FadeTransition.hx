import flixel.util.FlxColor;
import flixel.util.FlxGradient;

import flixel.FlxState;

var transBlack:FlxSprite;
var transGradient:FlxSprite;

var transCamera:FlxCamera;

function onCreate()
{
	FlxState.transitioning = true;

	transCamera = new ALECamera();
	
    FlxG.cameras.add(transCamera, false);

	transGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, (transOut ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
	transGradient.scrollFactor.set();
	add(transGradient);
	transGradient.cameras = [transCamera];

	transBlack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height + (transIn ? 400 : 0), FlxColor.BLACK);
	transBlack.scrollFactor.set();
	add(transBlack);
	transBlack.cameras = [transCamera];

	transGradient.y = -transGradient.height;
}

function onUpdate(elapsed:Float)
{
	transGradient.y += (transGradient.height + FlxG.height) * elapsed / 0.5;
	
	transBlack.y = transGradient.y + (transIn ? -1 : 1) * transBlack.height; 

	if (transGradient.y >= FlxG.height)
	{
		if (transIn)
			finishCallback();

		close();
	}
}

function onDestroy()
{
	FlxState.transitioning = false;

    FlxG.cameras.remove(transCamera);
}