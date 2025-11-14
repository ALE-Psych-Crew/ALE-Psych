using StringTools;

function onEvent(name:String, v1:String, v2:String)
{
    if (name == 'Screen Shake')
    {
        for (valIndex => val in [v1, v2])
        {
            var values:Array<Float> = [];
            
            for (index => data in val.split(','))
            {
                var value:Float = Std.parseFloat(data.trim());

                if (Math.isNaN(value))
                    value = [1, 0.05][index];

                values.push(value);
            }

            var camera:FlxCamera = [game.camGame, game.camHUD][valIndex];
            
            camera.shake(values[1] ?? 0.05, values[0] ?? 1);
        }
    }
}