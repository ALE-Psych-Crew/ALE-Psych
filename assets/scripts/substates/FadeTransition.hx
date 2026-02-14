import flixel.util.FlxGradient;

import flixel.FlxState;

var finishCallback:Void -> Void;

var transGradient:FlxSprite;
var transBlack:FlxSprite;

var transIn:Bool;

function new(trsIn:Bool, ?cllBck:Void -> Void)
{
	transIn = trsIn;

	finishCallback = cllBck;

	FlxState.transitioning = true;
	
	transGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, (transIn ? [FlxColor.BLACK, 0x0] : [0x0, FlxColor.BLACK]));
	transGradient.scrollFactor.set();
	add(transGradient);
	transGradient.cameras = [subCamera];
	transGradient.y = -transGradient.height;

	transBlack = transBlack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height + (transIn ? 400 : 0), FlxColor.BLACK);
	transBlack.scrollFactor.set();
	add(transBlack);
	transBlack.cameras = [subCamera];
}

function onUpdate(elapsed:Float)
{
	transGradient.y += (transGradient.height + FlxG.height) * elapsed / 0.5;
	
	transBlack.y = transGradient.y + (transIn ? -1 : 1) * transBlack.height; 

	if (transGradient.y >= FlxG.height)
	{
		close();

		if (transIn)
			finishCallback();
	}
}

function onDestroy()
{
	FlxState.transitioning = false;
}