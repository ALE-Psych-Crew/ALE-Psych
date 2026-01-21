package funkin.visuals;

import flixel.FlxObject;

import flixel.math.FlxPoint;
import flixel.math.FlxPoint.FlxCallbackPoint;

import flixel.tweens.FlxTween.*;
import flixel.tweens.FlxEase.*;

class FXCamera extends ALECamera
{
	public var speed(default, set):Float;
	function set_speed(value:Float):Float
	{
		speed = value;

		followLerp = speed * 0.04;

		return speed;
	}

	public var zoomSpeed:Float = 0;
	public var targetZoom:Float = 1;

	public var offset:FlxCallbackPoint;
	public var position:FlxCallbackPoint;

	public function new(?speed:Float)
	{
		super();

		offset = new FlxCallbackPoint(updateTarget);

		position = new FlxCallbackPoint(updateTarget);

		follow(new FlxObject(width / 2, height / 2));
		
		this.speed = speed ?? 0;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (_zoomTween == null && zoomSpeed > 0)
			zoom = CoolUtil.fpsLerp(zoom, targetZoom, 0.05 * zoomSpeed);
	}

	public function updateTarget(_:FlxPoint)
	{
		target.x = position.x + offset.x;
		target.y = position.y + offset.y;
	}

	public var bopModulo:Int = 0;

	public var bopZoom:Float = 1;

	public function bop(curBeat:Int)
	{
		if (_zoomTween == null && bopModulo > 0 && curBeat % bopModulo == 0)
			zoom += 0.015 * bopZoom;
	}

	var _positionTween:FlxTween = null;

	public function tweenPosition(x:Float, y:Float, ?duration:Float, ?options:TweenOptions)
	{
		_positionTween = safePointTween(_positionTween, position, x, y, () -> { _positionTween = null; }, duration, options);
	}

	var _offsetTween:FlxTween = null;

	public function tweenOffset(x:Float, y:Float, ?duration:Float, ?options:TweenOptions)
	{
		_offsetTween = safePointTween(_offsetTween, offset, x, y, () -> { _offsetTween = null; }, duration, options);
	}

	inline function safePointTween(initTween:Null<FlxTween>, point:FlxPoint, x:Float, y:Float, endFunc:Void -> Void, ?duration:Float, ?options:TweenOptions):FlxTween
	{
		if (initTween != null)
			initTween.cancel();

		return FlxTween.tween(point, {x: x, y: y}, duration, callbackTweenOptions(endFunc, options));
	}

	var _zoomTween:FlxTween = null;

	public function tweenZoom(newZoom:Float, ?duration:Float, ?options:TweenOptions, ?permanent:Bool)
	{
		_zoomTween = safeUniqueTween(_zoomTween, zoom, newZoom, (val) -> {
			if (permanent ?? true)
				targetZoom = val;

			zoom = val;
		}, () -> { _zoomTween = null; }, duration, options);
	}

	var _speedTween:FlxTween = null;

	public function tweenSpeed(newSpeed:Float, ?duration:Float, ?options:TweenOptions)
	{
		_speedTween = safeUniqueTween(_speedTween, speed, newSpeed, (val) -> { speed = val; }, () -> { _speedTween = null; }, duration, options);
	}

	var _zoomSpeedTween:FlxTween = null;

	public function tweenZoomSpeed(newZoomSpeed:Float, ?duration:Float, ?options:TweenOptions)
	{
		_zoomSpeedTween = safeUniqueTween(_zoomSpeedTween, zoomSpeed, newZoomSpeed, (val) -> { zoomSpeed = val; }, () -> { _zoomSpeedTween = null; }, duration, options);
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