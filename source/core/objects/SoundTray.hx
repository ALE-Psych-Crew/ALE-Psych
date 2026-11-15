package core.objects;

import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;

import openfl.display.Bitmap;

import openfl.Lib;

/**
 * A tray that displays the current volume whenever it is changed
 */
class SoundTray extends GameObject
{
    public var bg:Bitmap;
    public var fillingBack:Bitmap;
    public var fillingFront:Bitmap;
    public var border:Bitmap;
    public var thumb:Bitmap;
    public var text:Bitmap;

    public function new()
    {
        super();

        add(bg = createBitmap('soundTray/bg'));

        add(fillingBack = createBitmap('soundTray/filling'));
        fillingBack.x = bg.width / 2 - fillingBack.width / 2;
        fillingBack.y = bg.height / 2 - fillingBack.height / 2;
        fillingBack.transform.colorTransform = new ColorTransform(0.3, 0.3, 0.3);

        add(fillingFront = createBitmap('soundTray/filling'));
        fillingFront.x = bg.width / 2 - fillingFront.width / 2;
        fillingFront.y = bg.height / 2 - fillingFront.height / 2;
        fillingFront.scrollRect = new Rectangle(0, 0, fillingFront.width * FlxG.sound.volume, fillingFront.height);

        add(border = createBitmap('soundTray/border'));
        border.x = fillingFront.x + fillingFront.width / 2 - fillingFront.width / 2;
        border.y = fillingFront.y + fillingFront.height / 2 - fillingFront.height / 2;

        add(thumb = createBitmap('soundTray/thumb'));
        thumb.x = fillingFront.x + fillingFront.scrollRect.width - thumb.width / 2;
        thumb.y = border.y + border.height / 2 - thumb.height / 2;
        
        add(text = createBitmap('soundTray/text'));
        text.x = bg.width / 2 - text.width / 2;
        text.y = bg.height + 5;

        y = -height;
        alpha = 0;
    }

    /**
     * Time remaining until the tray retracts (in seconds)
     */
    var timer:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (Controls.MUTE)
        {
            FlxG.sound.muted = !FlxG.sound.muted;

            display();
        }

        if (Controls.VOLUME_UP || Controls.VOLUME_DOWN)
        {
            if (FlxG.sound.muted)
                FlxG.sound.muted = false;

            FlxG.sound.volume = FlxMath.bound(FlxG.sound.volume + (Controls.VOLUME_UP ? 0.1 : -0.1), 0, 1);

            display();
        }

        if (timer <= 0)
        {
            y = CoolUtil.fpsLerp(y, -height, 0.2);
            alpha = CoolUtil.fpsLerp(alpha, 0, 0.2);
        } else {
            y = CoolUtil.fpsLerp(y, 15, 0.2);
            alpha = CoolUtil.fpsLerp(alpha, 1, 0.2);

            timer -= elapsed;
        }

        if (Math.round(alpha) > 0)
        {
            thumb.rotation = CoolUtil.fpsLerp(thumb.rotation, 0, 0.25);

            final rect:Rectangle = fillingFront.scrollRect;
            rect.width = CoolUtil.fpsLerp(rect.width, fillingFront.width * FlxG.sound.volume, 0.25);

            fillingFront.scrollRect = rect;

            thumb.x = fillingFront.x + rect.width - thumb.width / 2;
        }

		x = Lib.current.stage.stageWidth / 2 - bg.width / 2 - FlxG.game.x;
    }

    /**
     * This shows the tray
     */
    function display()
    {
        timer = 1;

        final factor:Float = FlxG.sound.muted ? 0.3 : 1;

        transform.colorTransform = new ColorTransform(factor, factor, factor);

        if (!FlxG.sound.muted)
            thumb.rotation = 5;

        CoolUtil.playSound('volume');

		if (FlxG.save.isBound)
		{
			FlxG.save.data.mute = FlxG.sound.muted;
			FlxG.save.data.volume = FlxG.sound.volume;
			FlxG.save.flush();
		}
    }
}