function onEvent(name:String, v1:String, v2:String)
{
    if (name == 'Play Sound')
    {
        var volume:Float = Std.parseFloat(v2);

        if (Math.isNaN(volume))
            volume = 1;

        FlxG.sound.play(Paths.sound(v1), volume);
    }
}