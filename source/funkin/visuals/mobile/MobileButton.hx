package funkin.visuals.mobile;

import core.backend.MobileControls;

import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;

class MobileButton extends FlxSpriteGroup
{
    public var keys:Null<Array<Null<FlxKey>>>;

    @:unreflective var replacedMap:Map<FlxKey, MobileButton> = new Map<FlxKey, MobileButton>();

    public var label:FlxSprite;
    public var bg:FlxSprite;

    public var pressAlpha:Float = 0.5;
    public var releaseAlpha:Float = 1;
    
    override public function new(?x:Float, ?y:Float, keys:Array<Null<FlxKey>>, letter:String, ?width:Float, ?height:Float)
    {
        super(x, y);

        var theWidth:Int = Math.floor(width ?? 125);
        var theHeight:Int = Math.floor(height ?? 125);

        bg = new FlxSprite();
        add(bg);

        label = new FlxSprite();
        add(label);

        if (letter != null)
        {
            bg.makeGraphic(theWidth, theHeight, 0x80404040);

            label.frames = Paths.getSparrowAtlas('ui/alphabet');
            label.animation.addByPrefix('idle', letter.toLowerCase() + ' instance 1');
            label.animation.play('idle');
            label.setGraphicSize(0, theHeight - theHeight * 0.4);
            label.updateHitbox();
            label.offset.x -= theWidth / 2 - label.width / 2;
            label.offset.y -= theHeight / 2 - label.height / 2;
            label.color = FlxColor.BLACK;
        } else {            
            bg.makeGraphic(theWidth, theHeight, FlxColor.TRANSPARENT);

            label.makeGraphic(theWidth, theHeight, 0xFF404040);
            
            releaseAlpha = alpha = 0;
            pressAlpha = 0.25;
        }

        for (key in keys)
            if (key != null || key != 0)
            {
                if (MobileControls._controlsMap.exists(key))
                    replacedMap.set(key, MobileControls._controlsMap.get(key));

                MobileControls._controlsMap.set(key, this);
            }

        this.keys = keys;
    }
    
    public var pressed:Bool = false;

    public var justPressed:Bool = false;
    public var callback:Void -> Void;

    public var justReleased:Bool = false;
    public var releaseCallback:Void -> Void;

    var pressDetect:Bool = true;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        justPressed = false;
        justReleased = false;

        var devPressed:Bool = false;
        var devReleased:Bool = false;

        var isOverlaped:Bool = false;

        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.overlaps(bg, cameras[0]) && touch.pressed)
            {
                devPressed = isOverlaped = true;
                
                break;
            }
        }
        #else
        devPressed = Controls.MOUSE;
        devReleased = Controls.MOUSE_R;
        
        isOverlaped = FlxG.mouse.overlaps(bg, cameras[0]);
        #end

        if (isOverlaped)
        {
            if (devPressed && pressDetect)
            {
                pressDetect = false;

                justPressed = true;

                pressed = true;

                if (callback != null)
                    callback();
                    
                label.alpha = pressAlpha;
            }
        }

        if (!pressDetect)
        {
            if (devReleased || !isOverlaped)
            {
                pressed = false;

                pressDetect = true;

                justReleased = true;

                if (releaseCallback != null)
                    releaseCallback();

                label.alpha = releaseAlpha;
            }
        }
    }

    override public function destroy()
    {
        for (key in keys)
            if (key != null || key != 0)
                if (replacedMap.exists(key))
                    MobileControls._controlsMap.set(key, replacedMap.get(key));
                else
                    MobileControls._controlsMap.remove(key);

        super.destroy();
    }
}