package funkin.debug;

import openfl.display.Sprite;

import core.structures.DebugFieldText;

import openfl.events.KeyboardEvent;

import utils.cool.KeyUtil;

class DebugCounter extends Sprite
{
    @:unreflective var fps:DebugField;

    var fields:Array<DebugField> = [];

    public function new(data:Array<Array<DebugFieldText>>)
    {
        super();
		
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);

        FlxG.stage.addEventListener('activate', onFocus);
        FlxG.stage.addEventListener('deactivate', onUnFocus);

        fps = new FPSField();
        addField(fps);

        curHeight = fps.bg.scaleY;

        for (field in [new EngineField(), new ConductorField(), new FlixelField()].concat([for (field in data) new DebugField(field)]))
            addField(field);

        switchMode(0);
    }

    var curHeight:Float = 0;

    public function addField(field:DebugField)
    {
        fields.push(field);

        addChild(field);
        
        field.y = curHeight;

        curHeight += field.height;
    }

    public function removeField(field:DebugField)
    {
        fields.remove(field);

        removeChild(field);

        sortFields();
    }

    public function sortFields()
    {
        curHeight = fps.bg.scaleY;

        for (field in fields)
        {
            field.y = curHeight;

            curHeight += field.bg.scaleY;
        }
    }

    private var timer:Int = 0;

    private var focused:Bool = true;

    override function __enterFrame(time:Int)
    {
        if ((focused || !FlxG.autoPause) && visible)
        {
            if (timer > 50)
            {
                timer = 0;
            } else {
                timer += time;

                return;
            }
        } else {
            return;
        }
        
        super.__enterFrame(time);
    }

    public function destroy()
    {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);

        FlxG.stage.removeEventListener('activate', onFocus);
        FlxG.stage.removeEventListener('deactivate', onUnFocus);

        for (field in fields)
        {
            removeField(field);

            field = null;
        }
        
        removeChild(fps);

        fps = null;
    }

    function onFocus(_)
        focused = true;

    function onUnFocus(_)
        focused = false;
    
    public var curMode:Int = 0;

    public function switchMode(change:Int = 1)
    {
        curMode += change;

        curMode = curMode % 3;

        switch (curMode)
        {
            case 0:
                for (field in fields)
                    field.visible = false;

                fps.visible = true;
                fps.bg.visible = false;
            
                for (label in fps.labels)
                    label.text = label.valueFunction();

                fps.updateBG();
            case 1:
                for (field in fields)
                {
                    for (label in field.labels)
                        label.text = label.valueFunction();

                    field.updateBG();

                    field.visible = true;
                }

                fps.bg.visible = true;
            case 2:
                for (field in fields)
                    field.visible = false;

                fps.visible = false;
        }
    }
    
    function onKeyPressed(event:KeyboardEvent)
    {
		var key = KeyUtil.openFLToFlixelKey(event);

		if (ClientPrefs.controls.engine.fps_counter.contains(key))
            switchMode();
    }
}