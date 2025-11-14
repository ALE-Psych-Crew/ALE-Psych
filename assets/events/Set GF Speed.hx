function onEvent(name:String, v1:String, v2:String)
{
    if (name == 'Set GF Speed')
    {
        var speed:Float = Std.parseFloat(v1);

        if (Math.isNaN(speed) || speed < 1)
            speed = 1;

        game.gfSpeed = speed;
    }
}