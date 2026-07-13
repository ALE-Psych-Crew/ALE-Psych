package core.plugins;

import core.input.touch.TouchButton;

import flixel.input.keyboard.FlxKey;

class TouchPlugin extends FlxTypedSpriteGroup<TouchButton>
{
    final state:Array<TouchButton> = [];
    final subState:Array<TouchButton> = [];

    public function createButtons(buttonsData:Array<{label:String, keys:Array<FlxKey>}>, ?x:Float = 0, ?y:Float = 0, ?angle:Float = 0, ?radius:Float = 100)
    {
        for (index => data in buttonsData)
        {
            final angle:Float = Math.PI * 2 / buttonsData.length * index + angle * Math.PI / 180;

            final button:TouchButton = new TouchButton(data.keys, data.label, x, y);

            if (buttonsData.length > 1)
            {
                button.x += Math.cos(angle) * radius;
                button.y += Math.sin(angle) * radius;
            }

            button.x -= button.width / 2;
            button.y -= button.height / 2;

            add(button);

            if (FlxG.state.subState == null)
                state.push(button);
            else
                subState.push(button);
        }
    }

    public function initSubState()
    {
        for (button in state)
        {
            button.disable();
            button.exists = false;
        }
    }

    public function destroySubState()
    {
        for (button in subState.copy())
        {
            button.destroy();

            subState.remove(button);
        }

        for (button in state)
            button.exists = true;
    }

    public function destroyState()
    {
        for (button in state.copy())
        {
            button.destroy();

            state.remove(button);
        }
    }
}