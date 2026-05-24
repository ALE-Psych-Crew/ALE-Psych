package core.audio;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.utils.Assets;
import openfl.Lib;

class SoundTray extends Sprite
{
    function createBitmap(img:Dynamic)
    {
        final bitmap = new Bitmap(Assets.getBitmapData('images/soundTray/' + img + '.png'));
        bitmap.smoothing = true;

        addChild(bitmap);

        return bitmap;
    }

    final bars:Array<Bitmap> = [];

    public function new()
    {
        super();

        final bg = createBitmap('bg');
        addChild(bg);

        final text = createBitmap('text');
        text.x = bg.width / 2 - text.width / 2;
        text.y = bg.height + 5;
        addChild(text);

        var offset:Float = 0;

        var longest:Bitmap = null;

        for (i in 0...10)
        {
            final bar = createBitmap(i);
            bar.x = offset;

            offset += bar.width;

            if (longest == null || bar.height > longest.height)
                longest = bar;

            bars.push(bar);

            addChild(bar);
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

    var timer:Float = 0;

    public function update(elapsed:Float)
    {
        if (Controls.MUTE)
        {
            FlxG.sound.muted = !FlxG.sound.muted;

            display();
        }

        if (Controls.VOLUME_UP || Controls.VOLUME_DOWN)
        {
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
        
		x = Lib.current.stage.stageWidth / 2 - width / 2;
    }

    function display()
    {
        final funcVal:Int = FlxG.sound.muted ? 0 : Math.round(FlxG.sound.volume * 10);

        for (index => bar in bars)
            bar.alpha = (index + 1) <= funcVal ? 1 : 0.5;

        timer = 1;

        CoolUtil.playSound('volume');
    }
}