package funkin.visuals;

import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;

import openfl.geom.ColorTransform;
import openfl.display.BitmapData;
import openfl.display.BlendMode;

class ALECamera extends FlxCamera
{
	public function new(x = 0.0, y = 0.0, width = 0, height = 0, zoom = 0.0)
	{
		super(x, y, width, height, zoom);

		bgColor = FlxColor.TRANSPARENT;
	}

	override public function update(elapsed:Float):Void
	{
		if (target != null)
			updateFollowDelta(elapsed);

		updateScroll();

		updateFlash(elapsed);

		updateFade(elapsed);

		flashSprite.filters = filtersEnabled ? filters : null;

		updateFlashSpritePosition();
		
		updateShake(elapsed);
	}

	public function updateFollowDelta(?elapsed:Float = 0):Void
	{
		if (deadzone == null)
		{
			target.getMidpoint(_point);

			_point.addPoint(targetOffset);

			_scrollTarget.set(_point.x - width * 0.5, _point.y - height * 0.5);
		} else {
			var edge:Float;

			var targetX:Float = target.x + targetOffset.x;
			var targetY:Float = target.y + targetOffset.y;

			if (style == SCREEN_BY_SCREEN)
			{
				if (targetX >= viewRight)
					_scrollTarget.x += viewWidth;
				else if (targetX + target.width < viewLeft)
					_scrollTarget.x -= viewWidth;

				if (targetY >= viewBottom)
					_scrollTarget.y += viewHeight;
				else if (targetY + target.height < viewTop)
					_scrollTarget.y -= viewHeight;
				
				bindScrollPos(_scrollTarget);
			} else {
				edge = targetX - deadzone.x;

				if (_scrollTarget.x > edge)
					_scrollTarget.x = edge;

				edge = targetX + target.width - deadzone.x - deadzone.width;
			
				if (_scrollTarget.x < edge)
					_scrollTarget.x = edge;

				edge = targetY - deadzone.y;

				if (_scrollTarget.y > edge)
					_scrollTarget.y = edge;
				
				edge = targetY + target.height - deadzone.y - deadzone.height;

				if (_scrollTarget.y < edge)
					_scrollTarget.y = edge;
			}

			if (target is FlxSprite)
			{
				if (_lastTargetPosition == null)
					_lastTargetPosition = FlxPoint.get(target.x, target.y);

				_scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;

				_lastTargetPosition.x = target.x;
				_lastTargetPosition.y = target.y;
			}
		}

		var mult:Float = 1 - Math.exp(-elapsed * followLerp);

		scroll.x += (_scrollTarget.x - scroll.x) * mult;
		scroll.y += (_scrollTarget.y - scroll.y) * mult;
	}
	
    override function set_angle(val:Float):Float
    {
        angle = val;

        return angle;
    }

	override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
        if (!FlxG.renderBlit && angle != 0)
        {
            matrix.translate(-width / 2, -height / 2);

            var rad:Float = angle * Math.PI / 180;
            matrix.rotateWithTrig(Math.cos(rad), Math.sin(rad));

            matrix.translate(width / 2, height / 2);
        }
        
        super.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
    }
}