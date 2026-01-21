package core.enums;

enum abstract Rating(String) from String to String
{
	var SICK = 'sick';
	var GOOD = 'good';
	var BAD = 'bad';
	var SHIT = 'shit';

	public function toScore():Int
	{
		return switch (cast(this, Rating))
		{
			case SICK:
				350;
			case GOOD:
				200;
			case BAD:
				100;
			case SHIT:
				50;
			default:
				0;
		}
	}

	public function toAccuracy():Int
	{
		return switch (cast(this, Rating))
		{
			case SICK:
				100;
			case GOOD:
				67;
			case BAD:
				33;
			default:
				0;
		}
	}
}