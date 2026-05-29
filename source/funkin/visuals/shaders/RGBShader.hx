package funkin.visuals.shaders;

class RGBShader extends FXShader
{
    public var r(default, set):FlxColor;
    function set_r(value:FlxColor):FlxColor
    {
        setFloatArray('r', [value.redFloat, value.greenFloat, value.blueFloat]);

        return r = value;
    }
    
    public var g(default, set):FlxColor;
    function set_g(value:FlxColor):FlxColor
    {
        setFloatArray('g', [value.redFloat, value.greenFloat, value.blueFloat]);

        return g = value;
    }
    
    public var b(default, set):FlxColor;
    function set_b(value:FlxColor):FlxColor
    {
        setFloatArray('b', [value.redFloat, value.greenFloat, value.blueFloat]);

        return b = value;
    }

    public var multiplier(default, set):Float;
    function set_multiplier(value:Float):Float
    {
        value = FlxMath.bound(value, 0, 1);

        setFloat('multiplier', value);

        return multiplier = value;
    }
    
    public function new(r:FlxColor = 0xFFFF0000, g:FlxColor = 0xFF00FF00, b:FlxColor = 0xFF0000FF, multiplier:Float = 1)
    {
        super('default/rgb');

        this.r = r;
        this.g = g;
        this.b = b;
        this.multiplier = multiplier;
    }
}