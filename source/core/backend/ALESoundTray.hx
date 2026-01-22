package core.backend;

import flixel.system.ui.FlxSoundTray;
import flixel.system.FlxAssets;

import openfl.text.TextFormat;

import openfl.media.Sound;

class ALESoundTray extends FlxSoundTray
{
	public var targetY:Float = 0;
	public var targetAlpha:Float = 1;

	public function new()
	{
		super();

		y = -height;

		alpha = 0;

		active = false;
	}

	override public function update(elapsed:Float):Void
	{
		y = CoolUtil.fpsLerp(y, targetY, 0.15);

		alpha = CoolUtil.fpsLerp(alpha, targetAlpha, 0.15);

		if (_timer > 0)
		{
			_timer -= elapsed / 750;
		} else if (Math.floor(y) > -height) {
			targetY = -height;

			targetAlpha = 0;
		}

		visible = active = Math.floor(y) >= -height;
	}

	public var font(default, set):String = null;
	function set_font(value:String)
	{
		font = value;

		final format:TextFormat = new TextFormat(font, 10, FlxColor.WHITE);

		_label.defaultTextFormat = format;
		_label.setTextFormat(format);

		return font;
	}

	public var sound:Sound = null;

	override public function showAnim(volume:Float, ?snd:FlxSoundAsset, duration:Float = 1.25, label:String = 'VOLUME'):Void
	{
		if (!silent && sound != null)
			FlxG.sound.play(sound, 0.75);

		_timer = duration;

		targetY = 0;
		targetAlpha = 1;

		visible = true;
		active = true;

		final numBars = Math.round(volume * 10);

		for (i in 0..._bars.length)
			_bars[i].alpha = i < numBars ? 1.0 : 0.5;

		_label.text = label;

		updateSize();
	}
}