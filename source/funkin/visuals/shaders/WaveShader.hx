package funkin.visuals.shaders;

class WaveShader extends FXShader
{
    public var time(default, set):Float;
    function set_time(value:Float)
    {
        time = value;

        setFloat('time', time);

        return time;
    }
    
    public var vertical(default, set):Bool;
    function set_vertical(value:Bool)
    {
        vertical = value;

        setBool('vertical', vertical);

        return vertical;
    }

    public var amplitude(default, set):Float;
    function set_amplitude(value:Float)
    {
        amplitude = value;

        setFloat('amplitude', amplitude);

        return amplitude;
    }

    public var frequency(default, set):Float;
    function set_frequency(value:Float)
    {
        frequency = value;

        setFloat('frequency', frequency);

        return frequency;
    }

    public var speed(default, set):Float;
    function set_speed(value:Float)
    {
        speed = value;

        setFloat('speed', speed);

        return speed;
    }

    public function new(target:FlxSprite)
    {
        super('default/wave');

        time = 0;
        vertical = false;
        amplitude = 0;
        frequency = 0;
        speed = 0;
    }
}