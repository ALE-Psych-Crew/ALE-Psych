package core.objects;

import openfl.display.Bitmap;
import openfl.Lib;

/**
 * A tray that displays the current volume whenever it is changed
 */
class SoundTray extends GameObject
{
    /**
     * Volume bars
     */
    final bars:Array<Bitmap> = [];

    /**
     * This creates the volume tray
     */
    public function new()
    {
        super();

        final bg = createBitmap('soundTray/bg');
        add(bg);

        final text = createBitmap('soundTray/text');
        text.x = bg.width / 2 - text.width / 2;
        text.y = bg.height + 5;
        add(text);

        var offset:Float = 0;

        var longest:Bitmap = null;

        for (i in 0...10)
        {
            final bar = createBitmap('soundTray/' + i);
            bar.x = offset;

            offset += bar.width;

            if (longest == null || bar.height > longest.height)
                longest = bar;

            bars.push(bar);

            add(bar);
        }

        for (bar in bars)
        {
            bar.x += bg.width / 2 - offset / 2;

            bar.y = longest.height - bar.height + bg.height / 2 - longest.height / 2;
        }

        scaleX = scaleY = 0.55;

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
            y = CoolUtil.fpsLerp(y, 5, 0.2);
            alpha = CoolUtil.fpsLerp(alpha, 1, 0.2);

            timer -= elapsed;
        }
        
		x = Lib.current.stage.stageWidth / 2 - width / 2 - FlxG.game.x;
    }

    /**
     * This shows the tray
     */
    function display()
    {
        final funcVal:Int = FlxG.sound.muted ? 0 : Math.round(FlxG.sound.volume * 10);

        for (index => bar in bars)
            bar.alpha = (index + 1) <= funcVal ? 1 : 0.5;

        timer = 1;

        CoolUtil.playSound('volume');

		if (FlxG.save.isBound)
		{
			FlxG.save.data.mute = FlxG.sound.muted;
			FlxG.save.data.volume = FlxG.sound.volume;
			FlxG.save.flush();
		}
    }
}