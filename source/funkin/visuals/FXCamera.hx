package funkin.visuals;

import flixel.FlxObject;

import flixel.math.FlxPoint;
import flixel.math.FlxPoint.FlxCallbackPoint;

import flixel.tweens.FlxTween.*;
import flixel.tweens.FlxEase.*;

import utils.cool.MathUtil;

class FXCamera extends ALECamera
{
	public var speed(default, set):Float = 0;
	function set_speed(value:Float):Float
	{
		speed = value;

		followLerp = speed * 0.04;

		return speed;
	}

	public var bopModulo:Int = 4;

	public var bopZoom:Float = 1;

	public var zoomSpeed:Float = 0;
	public var targetZoom:Float = 1;

	public var offset:FlxCallbackPoint;
	public var position:FlxCallbackPoint;

	var _positionTween:FlxTween;

	var _zoomSpeedTween:FlxTween;

	var _offsetTween:FlxTween;

	var _zoomTween:FlxTween;

	var _speedTween:FlxTween;

	public function reset()
	{
		speed = 1;

		bopModulo = 4;
		bopZoom = 1;
		
		zoomSpeed = 1;
		targetZoom = 1;

		offset.x = offset.y = 0;

		position.x = width / 2;
		position.y = height / 2;

		cancelPositionTween();
		cancelZoomSpeedTween();
		cancelOffsetTween();
		cancelZoomTween();
		cancelSpeedTween();
	}

	public function new(?speed:Float)
	{
		super();

		follow(new FlxObject(width / 2, height / 2));

		offset = new FlxCallbackPoint(updateTarget);

		position = new FlxCallbackPoint(updateTarget);

		reset();
		
		this.speed = speed ?? 0;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (_zoomTween == null && zoomSpeed > 0)
			zoom = MathUtil.fpsLerp(zoom, targetZoom, 0.05 * zoomSpeed);
	}

	public function updateTarget(_:FlxPoint)
	{
		target.x = position.x + offset.x;
		target.y = position.y + offset.y;
	}

	public function bop(curBeat:Int)
	{
		if (_zoomTween == null && bopModulo > 0 && curBeat % bopModulo == 0)
			zoom += 0.015 * bopZoom;
	}

	public function tweenPosition(x:Float, y:Float, ?duration:Float, ?options:TweenOptions)
	{
		_positionTween = safePointTween(_positionTween, position, x, y, () -> { _positionTween = null; }, duration, options);
	}

	public function cancelPositionTween()
	{
		if (_positionTween != null)
		{
			_positionTween.cancel();

			_positionTween = null;
		}
	}

	public function tweenOffset(x:Float, y:Float, ?duration:Float, ?options:TweenOptions)
	{
		_offsetTween = safePointTween(_offsetTween, offset, x, y, () -> { _offsetTween = null; }, duration, options);
	}

	public function cancelOffsetTween()
	{
		if (_offsetTween != null)
		{
			_offsetTween.cancel();

			_offsetTween = null;
		}
	}

	inline function safePointTween(initTween:Null<FlxTween>, point:FlxPoint, x:Float, y:Float, endFunc:Void -> Void, ?duration:Float, ?options:TweenOptions):FlxTween
	{
		if (initTween != null)
			initTween.cancel();

		return FlxTween.tween(point, {x: x, y: y}, duration, callbackTweenOptions(endFunc, options));
	}

	public function tweenZoom(newZoom:Float, ?duration:Float, ?options:TweenOptions, ?permanent:Bool)
	{
		_zoomTween = safeUniqueTween(_zoomTween, zoom, newZoom, (val) -> {
			if (permanent ?? true)
				targetZoom = val;

			zoom = val;
		}, () -> { _zoomTween = null; }, duration, options);
	}

	public function cancelZoomTween()
	{
		if (_zoomTween != null)
		{
			_zoomTween.cancel();

			_zoomTween = null;
		}
	}

	public function tweenSpeed(newSpeed:Float, ?duration:Float, ?options:TweenOptions)
	{
		_speedTween = safeUniqueTween(_speedTween, speed, newSpeed, (val) -> { speed = val; }, () -> { _speedTween = null; }, duration, options);
	}

	public function cancelSpeedTween()
	{
		if (_speedTween != null)
		{
			_speedTween.cancel();

			_speedTween = null;
		}
	}

	public function tweenZoomSpeed(newZoomSpeed:Float, ?duration:Float, ?options:TweenOptions)
	{
		_zoomSpeedTween = safeUniqueTween(_zoomSpeedTween, zoomSpeed, newZoomSpeed, (val) -> { zoomSpeed = val; }, () -> { _zoomSpeedTween = null; }, duration, options);
	}

	public function cancelZoomSpeedTween()
	{
		if (_zoomSpeedTween != null)
		{
			_zoomSpeedTween.cancel();

			_zoomSpeedTween = null;
		}
	}

	inline function safeUniqueTween(initTween:Null<FlxTween>, startValue:Float, endValue:Float, updateFunc:Float -> Void, endFunc:Void -> Void, ?duration:Float, ?options:TweenOptions):FlxTween
	{
		if (initTween != null)
			initTween.cancel();

		return FlxTween.num(startValue, endValue, duration, callbackTweenOptions(endFunc, options), updateFunc);
	}

	inline function callbackTweenOptions(endFunc:Void -> Void, ?options:TweenOptions):TweenOptions
	{
		options ??= {};

		return {
			type: options.type,
			startDelay: options.startDelay,
			onUpdate: options.onUpdate,
			onStart: options.onStart,
			loopDelay: options.loopDelay,
			ease: options.ease,
			onComplete: (twn) -> {
				if (options.onComplete != null)
					options.onComplete(twn);

				endFunc();
			}
		}
	}
}