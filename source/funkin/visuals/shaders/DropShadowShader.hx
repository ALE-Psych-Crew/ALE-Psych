package funkin.visuals.shaders;

import flixel.math.FlxAngle;

class DropShadowShader extends FXShader
{
    public var target:FlxSprite;

    public var threshold(default, set):Float;
    function set_threshold(value:Float):Float
    {
        threshold = value;

        setFloat('threshold', value);
        
        return threshold;
    }

    public var distance(default, set):Float;
    function set_distance(value:Float):Float
    {
        distance = value;

        setFloat('distance', value);
        
        return distance;
    }

    public var strength(default, set):Float;
    function set_strength(value:Float):Float
    {
        strength = value;

        setFloat('strength', value);
        
        return strength;
    }

    public var angle(default, set):Float;
    function set_angle(value:Float):Float
    {
        angle = value;

        setFloat('angle', (value + 180) * FlxAngle.TO_RAD);
        
        return angle;
    }

    public var angleOffset(default, set):Float;
    function set_angleOffset(value:Float):Float
    {
        angleOffset = value;

        setFloat('angleOffset', value);
        
        return angleOffset;
    }

    public var threshold2(default, set):Float;
    function set_threshold2(value:Float):Float
    {
        threshold2 = value;

        setFloat('threshold2', value);
        
        return threshold2;
    }

    public var useMask(default, set):Bool;
    function set_useMask(value:Bool):Bool
    {
        useMask = value;

        setBool('useMask', value);
        
        return useMask;
    }

    public var saturation(default, set):Float;
    function set_saturation(value:Float):Float
    {
        saturation = value;

        setFloat('saturation', value);
        
        return saturation;
    }

    public var brightness(default, set):Float;
    function set_brightness(value:Float):Float
    {
        brightness = value;

        setFloat('brightness', value);
        
        return brightness;
    }

    public var contrast(default, set):Float;
    function set_contrast(value:Float):Float
    {
        contrast = value;

        setFloat('contrast', value);
        
        return contrast;
    }

    public var hue(default, set):Float;
    function set_hue(value:Float):Float
    {
        hue = value;

        setFloat('hue', value);
        
        return hue;
    }

    public var color(default, set):FlxColor;
    function set_color(value:FlxColor)
    {
        color = value;

        setFloatArray('color', rgbArray(color));

        return color;
    }
    
    function rgbArray(color:Int):Array<Float>
        return [((color >> 16) & 0xFF) / 255, ((color >> 8) & 0xFF) / 255, (color & 0xFF) / 255];

    public var stages(default, set):FlxColor;
    function set_stages(value:FlxColor)
    {
        stages = value;

        setFloat('stages', stages);

        return stages;
    }

    public function new(target:FlxSprite)
    {
        super('default/dropShadow');

        this.target = target;

        updateBounds();

        target?.animation.onFrameChange.add((_, __, ___) -> this.updateBounds());

        color = FlxColor.WHITE;
        strength = 1;
        threshold = 0.1;
        useMask = false;
        stages = 0;
        brightness = 0;
        hue = 0;
        contrast = 0;
        saturation = 0;
        angle = 0;
        distance = 20;
    }

    function updateBounds()
    {
        setFloatArray('frameBounds', [target.frame.uv.left, target.frame.uv.top, target.frame.uv.right, target.frame.uv.bottom]);

        setFloat('angleOffset', target.frame.angle * FlxAngle.TO_RAD);
    }
}