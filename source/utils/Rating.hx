package utils;

import core.config.ClientPrefs;

import core.structures.RatingWindows;

class Rating
{
	public static function judgeNote(arr:Array<Rating>, diff:Float = 0):Rating
	{
		var data:Array<Rating> = arr;

		for (i in 0...data.length - 1)
			if (diff <= data[i].hitWindow)
				return data[i];

		return data[data.length - 1];
	}

	public static var ratingWindows:RatingWindows;

	public var name:String = '';
	public var image:String = '';
	public var hitWindow:Null<Int> = 0;
	public var ratingMod:Float = 1;
	public var score:Int = 350;
	public var noteSplash:Bool = true;
	public var hits:Int = 0;

	public function new(name:String)
	{
		this.name = name;
		this.image = name;
		this.hitWindow = 0;

		var window:String = name + 'Window';

		try
		{
			this.hitWindow = Reflect.field(Rating.ratingWindows, window);
		} catch (e:Dynamic) {};
	}

	public static function loadDefault():Array<Rating>
	{
		var ratingsData:Array<Rating> = [new Rating('sick')];

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.67;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.34;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);
		return ratingsData;
	}
}
