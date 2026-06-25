package utils;

class Score
{
	public static var songs:Map<String, Map<String, {score:Float, accuracy:Float}>>;
	public static var weeks:Map<String, Map<String, Float>>;

	public static function init()
	{
		songs = new Map();

		weeks = new Map();
	}

	public static function saveSong(name:String, difficulty:String, score:Float, accuracy:Float)
	{
		name = CoolUtil.formatString(name);
		difficulty = CoolUtil.formatString(difficulty);

		songs[name] ??= new Map();

		songs[name][difficulty] ??= {
			score: 0.0,
			accuracy: 0.0
		};

		final cur = songs[name][difficulty];

		if (cur.score < score)
			cur.score = score;

		if (cur.accuracy < accuracy)
			cur.accuracy = accuracy;
	}

	public static function saveWeek(name:String, difficulty:String, score:Float)
	{
		name = CoolUtil.formatString(name);
		difficulty = CoolUtil.formatString(difficulty);

		weeks[name] ??= new Map();

		weeks[name][difficulty] ??= 0;

		if (weeks[name][difficulty] < score)
			weeks[name][difficulty] = score;
	}

	public static function destroy()
	{
		songs = null;

		weeks = null;
	}
}