package funkin.visuals.game;

class Hitbox extends FlxSprite
{
    public var onPress:Void -> Void;
    public var onRelease:Void -> Void;

    public function new(strums:Int, index:Int, onPress:Void -> Void, onRelease:Void -> Void)
    {
        super();

        final hitboxWidth:Float = FlxG.width / strums;

        makeGraphic(Math.floor(hitboxWidth), FlxG.height);

        x = index * hitboxWidth;

        alpha = 0;

        this.onPress = onPress;
        this.onRelease = onRelease;
    }
    
    var pressed:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var isOverlaped:Bool = false;

        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.overlaps(this, cameras[0]) && touch.pressed)
            {
                isOverlaped = true;
                
                break;
            }
        }
        #else
        isOverlaped = Controls.MOUSE && FlxG.mouse.overlaps(this, cameras[0]);
        #end

        if (!pressed && isOverlaped)
        {
            pressed = true;

            alpha = 0.025;

            onPress();
        } else if (pressed && !isOverlaped) {
            pressed = false;

            alpha = 0;

            onRelease();
        }
    }
}