package funkin.visuals.objects;

import flixel.util.typeLimit.OneOfTwo;

import funkin.vis.dsp.SpectralAnalyzer;

import lime.media.AudioSource;

import flixel.group.FlxSpriteGroup;

class Visualizer extends FlxSpriteGroup
{
    public var analyzer:SpectralAnalyzer;

    public final intialWidth:Int;
    public final initialHeight:Int;

    public function new(audio:OneOfTwo<FlxSound, AudioSource>, ?intialWidth:Float, ?initialHeight:Float, barCount:Int = 16, color:FlxColor = FlxColor.RED)
    {
        super();

        @:privateAccess
        var audioSource:Null<AudioSource> = audio is FlxSound ? cast(audio, FlxSound)._channel.__audioSource : cast(audio, AudioSource);

        analyzer = new SpectralAnalyzer(audioSource, barCount, 0.1, 10);

        this.intialWidth = Math.floor(intialWidth ?? FlxG.width);
        this.initialHeight = Math.floor(initialHeight ?? FlxG.height);

		for (i in 0...barCount)
		{
			var spr = new FlxSprite((i / barCount) * this.intialWidth, 0).makeGraphic(Std.int((1 / barCount) * this.intialWidth) - 4, this.initialHeight, color);
            spr.origin.set(0, this.initialHeight);
			add(spr);
		}
    }

    @:generic static inline function min<T:Float>(x:T, y:T):T
        return x > y ? y : x;

    override function draw()
    {
        @:privateAccess var levels = analyzer.audioSource == null ? [for (i in 0...members.length) {value: 0.0, peak: 0.0}] : analyzer.getLevels();

        for (i in 0...min(members.length, levels.length))
            members[i].scale.y = levels[i].value;

        super.draw();
    }
}
