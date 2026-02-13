package core.plugins;

import haxe.ds.IntMap;

import core.enums.KeyCheck;

import flixel.input.keyboard.FlxKey;

import funkin.visuals.plugins.MobileButton;

class MobileControlsPlugin extends FlxTypedGroup<MobileButton>
{
    override public function new()
    {
        super();
        
        FlxG.signals.preStateCreate.add(clean);
    }
    
    override function destroy()
    {
        super.destroy();
        
        FlxG.signals.preStateCreate.remove(clean);
    }
    
    public var stateButtons:IntMap<MobileButton> = new IntMap();
    public var subStateButtons:IntMap<MobileButton> = new IntMap();
    
    public function checkKeys(keys:Array<Int>, prop:KeyCheck):Bool
    {
        for (key in keys)
        {
            final button:MobileButton = subStateButtons.get(key) ?? stateButtons.get(key);
            
            if (button == null)
                continue;
            
            final property:Bool = switch(prop)
            {
                case KeyCheck.PRESSED:
                    button.pressed;
                case KeyCheck.JUST_PRESSED:
                    button.justPressed;
                case KeyCheck.JUST_RELEASED:
                    button.justReleased;
            }
            
            if (button.exists && property)
                return true;
        }
        
        return false;
    }
    
    public function clean(?_)
    {
        for (group in [stateButtons, subStateButtons])
            destroyButtons(group);
    }

    public function restartButtons(group:IntMap<MobileButton>)
    {
        for (key in group.keys())
            group.get(key).restart();
    }
    
    public function destroyButtons(group:IntMap<MobileButton>)
    {
        for (key in group.keys())
        {
            final obj:MobileButton = group.get(key);
            
            obj.destroy();
            
            remove(obj, true);
        }
        
        group.clear();
    }
    
    public function toggleButtons(group:IntMap<MobileButton>, show:Bool)
    {
        for (key in group.keys())
        {
            final button:MobileButton = group.get(key);
            
            button.restart();
            
            button.exists = show;
        }
    }
    
    public function createButtons(x:Float = 0, y:Float = 0, buttonsData:Array<{label:String, keys:Array<FlxKey>}>, ?radius:Int = 100, subState:Bool = false)
    {
        final uniqueButton:Bool = buttonsData.length == 1;
        
        final group:IntMap<MobileButton> = subState ? subStateButtons : stateButtons;
        
        for (index => data in buttonsData)
        {
            var shouldContinue:Bool = false;
            
            for (key in data.keys)
                if (group.exists(key))
                {
                    shouldContinue = true;
                    
                    break;
                }
            
            if (shouldContinue)
                continue;
            
            final angle:Float = Math.PI * 2 / buttonsData.length * index;
    
            final button:MobileButton = new MobileButton(data.keys, data.label);
            add(button);
    
            button.x = (uniqueButton ? x : x + radius + Math.cos(angle) * radius) - button.width / 2;
            
            button.y = (uniqueButton ? y : y + radius + Math.sin(angle) * radius) - button.height / 2;
            
            button.cameras = cameras;

            for (key in data.keys)
                group.set(key, button);
        }
    }
}