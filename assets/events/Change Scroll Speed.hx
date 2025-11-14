function onEvent(name:String, v1:String, v2:String)
{
    if (name == 'Change Scroll Speed')
    {
        var speed:Float = Std.parseFloat(v1);

        if (Math.isNaN(speed))
            speed = 1;

        var duration:Float = Std.parseFloat(v2);

        if (Math.isNaN(duration))
            duration = 0;

        if (duration <= 0)
            songSpeed = speed;
        else
            FlxTween.tween(game, {songSpeed: speed}, duration / game.playbackRate);
    }
}