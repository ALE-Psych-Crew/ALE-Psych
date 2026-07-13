package core.input.touch;

import flixel.addons.display.shapes.FlxShapeCircle;

import flixel.input.touch.FlxTouch;

class TouchButton extends flixel.group.FlxSpriteGroup
{
	final keys:Vector<FlxKey>;

    public var bg:FlxShapeCircle;
    public var label:FlxText;

	public function new(keys:Array<FlxKey>, labelText:String, ?x:Float, ?y:Float, ?radius:Int = 50)
	{
		super(x, y);

		keys = keys.filter(k -> (k : Null<FlxKey>) != null && (k : Int) > 0);

		this.keys = new Vector<FlxKey>(keys.length);

		for (i => key in keys)
			this.keys[i] = key;

        bg = cast add(new FlxShapeCircle(0, 0, radius, {thickness: 3, color: 0xFF404040}, FlxColor.GRAY));
        bg.active = false;

        label = cast add(new FlxText(0, 0, 0, labelText, Std.int(radius * 1.25)));
        label.font = Paths.font('poppins.ttf');
        label.x = bg.x + bg.width / 2 - label.width / 2;
        label.y = bg.y + bg.height / 2 - label.height / 2;
        label.color = FlxColor.BLACK;
        label.active = false;

		alpha = 0.5;
	}

	var justReleased:Bool = false;
	var justPressed:Bool = false;
	var pressed:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		disableJustPressed();

		disableJustReleased();

		if (checkPressed())
		{
			for (key in keys)
			{
				TouchControls.justPressedMap[key]++;

				TouchControls.pressedMap[key]++;
			}

			justPressed = true;

			pressed = true;

			alpha = 0.75;
		}

		if (checkReleased())
		{
			for (key in keys)
			{
				TouchControls.justReleasedMap[key]++;

				TouchControls.pressedMap[key]--;
			}

			justReleased = true;

			pressed = false;

			alpha = 0.5;
		}
	}


	function disableJustPressed()
	{
		if (!justPressed)
			return;

		for (key in keys)
			TouchControls.justPressedMap[key]--;

		justPressed = false;
	}

	function disableJustReleased()
	{
		if (!justReleased)
			return;

		for (key in keys)
			TouchControls.justReleasedMap[key]--;

		justReleased = false;
	}

	function disablePressed()
	{
		if (!pressed)
			return;

		for (key in keys)
			TouchControls.pressedMap[key]--;

		pressed = false;
	}


	var touch:FlxTouch;

	function checkPressed():Bool
	{
		if (justReleased)
			return false;

		#if FLX_NO_TOUCH
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera))
			return true;
		#else
		if (touch == null)
			for (t in FlxG.touches.list)
				if (t.justPressed && t.overlaps(this, camera))
				{
					touch = t;

					return true;
				}
		#end

		return false;
	}

	function checkReleased():Bool
	{
		if (!pressed)
			return false;

		#if FLX_NO_TOUCH
		if (FlxG.mouse.justReleased)
			return true;
		#else
		if (touch != null && touch.justReleased)
		{
			touch = null;

			return true;
		}
		#end

		return false;
	}

	public function disable()
	{
		disableJustPressed();
		disableJustReleased();
		disablePressed();

		alpha = 0.5;
	}


	override function destroy()
	{
		disable();

		touch = null;

		super.destroy();
	}
}