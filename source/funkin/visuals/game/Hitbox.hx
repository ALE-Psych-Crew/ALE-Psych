package funkin.visuals.game;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSpriteUtil;

import openfl.events.KeyboardEvent;

import core.input.touch.TouchButton;

class Hitbox extends TouchButton
{
    public function new(keys:Array<FlxKey>, index:Int, length:Int)
    {
        super(keys, '', FlxG.width / length * index);

        idleAlpha = 0.025;
        pressedAlpha = 0.05;

        alpha = 1;

        add(bg = new FlxSprite().makeGraphic(Math.ceil(FlxG.width / length), Math.ceil(FlxG.height), FlxColor.WHITE));

        FlxSpriteUtil.drawRect(bg, 0, 0, width, height, FlxColor.TRANSPARENT, {color: FlxColor.BLACK, thickness: 3});

        alpha = idleAlpha;
    }

    override function initObjects(_, _) {}

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (justPressed)
            PlayState.instance?.justPressedKey(new KeyboardEvent(KeyboardEvent.KEY_DOWN, false, true, 0, keys[0]));

        if (justReleased)
            PlayState.instance?.justReleasedKey(new KeyboardEvent(KeyboardEvent.KEY_UP, false, true, 0, keys[0]));
    }

	override function checkPressed():Bool
	{
		if (justReleased || pressed)
			return false;

		#if FLX_NO_TOUCH
		if (FlxG.mouse.pressed && FlxG.mouse.overlaps(this, camera))
            return true;
		#else
        for (touch in FlxG.touches.list)
            if (touch.pressed && touch.overlaps(this, camera))
                return true;
		#end

		return false;
	}

	override function checkReleased():Bool
	{
		if (!pressed || justPressed)
			return false;

		#if FLX_NO_TOUCH
		if (FlxG.mouse.pressed && FlxG.mouse.overlaps(this, camera))
            return false;
		#else
        for (touch in FlxG.touches.list)
            if (touch.pressed && touch.overlaps(this, camera))
                return false;
		#end

		return true;
	}
}