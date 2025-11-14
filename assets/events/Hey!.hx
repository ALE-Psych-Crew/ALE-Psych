using StringTools;

function onEvent(name:String, v1:String, v2:String)
{
    if (name == 'Hey!')
    {
        var duration:Float = Std.parseFloat(v2);

        if (Math.isNaN(duration) || duration <= 0)
            duration = 0.6;

        var chars:StringMap<Character> = [];

        if (['bf', 'boyfriend', '0', ''].contains(v1.toLowerCase().trim()))
            chars.push([game.boyfriend, 'hey']);

        if (['gf', 'girlfriend', '1', ''].contains(v1.toLowerCase().trim()))
            chars.push([game.dad.curCharacter.startsWith('gf') ? game.dad : game.gf, 'cheer']);

        for (char in chars)
        {
            char[0].playAnim(char[1]);
            char[0].specialAnim = true;
            char[0].heyTimer = duration;
        }
    }
}