package core.plugins;

import haxe.ds.IntMap;

import core.interfaces.ITactileButton;
import core.enums.KeyCheck;

import flixel.input.keyboard.FlxKey;
import flixel.FlxBasic;

import funkin.visuals.plugins.MobileButton;

class MobileControlsPlugin extends FlxTypedGroup<FlxBasic>
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
    
    public var stateButtons:IntMap<Array<ITactileButton>> = new IntMap();
    public var subStateButtons:IntMap<Array<ITactileButton>> = new IntMap();
    
    public function checkKeys(keys:Array<Null<Int>>, prop:KeyCheck):Bool
    {
        for (key in keys)
        {
            if (key == null || key <= 0)
                continue;

            final group:Array<ITactileButton> = subStateButtons.get(key) ?? stateButtons.get(key);

            if (group == null)
                continue;

            for (obj in group)
            {
                if (obj == null)
                    continue;
                
                final property:Bool = switch(prop)
                {
                    case KeyCheck.PRESSED:
                        obj.pressed;
                    case KeyCheck.JUST_PRESSED:
                        obj.justPressed;
                    case KeyCheck.JUST_RELEASED:
                        obj.justReleased;
                }
                
                if (obj.exists && property)
                    return true;
            }
        }
        
        return false;
    }
    
    public function clean(?_)
    {
        for (group in [stateButtons, subStateButtons])
            destroyButtons(group);
    }

    public function restartButtons(group:IntMap<Array<ITactileButton>>)
    {
        for (key in group.keys())
            for (obj in group.get(key))
                obj.restart();
    }
    
    public function destroyButtons(group:IntMap<Array<ITactileButton>>)
    {
        for (key in group.keys())
        {
            for (obj in group.get(key))
            {
                obj.destroy();
                
                remove(cast obj, true);
            }
        }
        
        group.clear();
    }
    
    public function toggleButtons(group:IntMap<Array<ITactileButton>>, show:Bool)
    {
        for (key in group.keys())
        {
            for (obj in group.get(key))
            {
                obj.restart();
                
                obj.exists = show;
            }
        }
    }
    
    public function createButtons(x:Float = 0, y:Float = 0, buttonsData:Array<{label:String, keys:Array<FlxKey>}>, ?radius:Int = 100, subState:Bool = false)
    {
        final uniqueButton:Bool = buttonsData.length == 1;
        
        final group:IntMap<Array<ITactileButton>> = subState ? subStateButtons : stateButtons;
        
        for (index => data in buttonsData)
        {
            final angle:Float = Math.PI * 2 / buttonsData.length * index;
    
            final button:MobileButton = new MobileButton(data.keys, data.label);
            add(button);
    
            button.x = (uniqueButton ? x : x + radius + Math.cos(angle) * radius) - button.width / 2;
            
            button.y = (uniqueButton ? y : y + radius + Math.sin(angle) * radius) - button.height / 2;
            
            button.cameras = cameras;

            addToMap(button, group, data.keys);
        }
    }

    public function addToMap(obj:ITactileButton, map:IntMap<Array<ITactileButton>>, keys:Array<Int>)
    {
        for (key in keys)
        {
            if (!map.exists(key))
                map.set(key, []);

            if (map.get(key).contains(obj))
                continue;

            map.get(key).push(obj);
        }
    }
}