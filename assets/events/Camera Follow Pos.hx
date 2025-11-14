function onEvent(name:String, v1:String, v2:String)
{
    if (name == 'Camera Follow Pos')
    {
        if (game.camFollow != null)
        {
            game.isCameraOnForcedPos = false;

            var x:Float = Std.parseFloat(v1);

            var y:Float = Std.parseFloat(v2);

            if (!Math.isNaN(x) || !Math.isNaN(y))
            {
                game.isCameraOnForcedPos = true;

                if (Math.isNaN(x))
                    x = 0;

                if (Math.isNaN(y))
                    y = 0;

                game.camFollow.x = x;
                game.camFollow.y = y;
            }
        }
    }
}