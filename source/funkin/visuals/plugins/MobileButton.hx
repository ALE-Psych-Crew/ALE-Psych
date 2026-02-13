package funkin.visuals.plugins;

import flixel.input.keyboard.FlxKey;

import flixel.addons.display.shapes.FlxShapeCircle;

class MobileButton extends FlxSpriteGroup
{
    public var keys:Array<FlxKey>;

    public var bg:FlxShapeCircle;
    public var label:FlxText;

    public function new(keys:Array<FlxKey>, labelText:String, ?radius:Int)
    {
        super();

        this.keys = keys;

        radius ??= 50;

        bg = new FlxShapeCircle(0, 0, radius, {thickness: 3, color: 0xFF404040}, FlxColor.GRAY);
        add(bg);
        bg.active = false;

        label = new FlxText(0, 0, 0, labelText, Std.int(radius * 1.25));
        add(label);
        label.font = Paths.font('poppins.ttf');
        label.color = FlxColor.BLACK;
        label.x = bg.x + bg.width / 2 - label.width / 2;
        label.y = bg.y + bg.height / 2 - label.height / 2;
        label.active = false;

        alpha = 0.75;
    }

    public var pressed:Bool = false;

    public var justPressed:Bool = false;
    
    public var justReleased:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (justPressed)
            justPressed = false;

        if (justReleased)
            justReleased = false;

        if (Controls.MOUSE_P)
        {
            if (FlxG.mouse.overlaps(bg, cameras[0]))
            {
                pressed = justPressed = true;

                alpha = 1;
            }
        }

        if (pressed && !Controls.MOUSE)
        {
            pressed = false;
    
            justReleased = true;
    
            alpha = 0.75;
        }
    }
    
    public function restart()
    {
        pressed = justPressed = justReleased = false;
        
        alpha = 0.75;
    }
}