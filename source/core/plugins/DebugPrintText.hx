package core.plugins;

class DebugPrintText extends FlxText
{
    public function new()
    {
        super(10, 0, FlxG.width - 20, '', 15);

        font = Paths.font('jetbrains.ttf');
    }

    public function setData(debugText:String, ?prefix:String, ?color:FlxColor)
    {
        text = prefix + ' | ' + debugText;

        clearFormats();

        addFormat(new FlxTextFormat(color), 0, prefix.length);
        addFormat(new FlxTextFormat(0xFF505050), prefix.length + 1, prefix.length + 2);
    }

    var timer:Float = 6;

    override function update(elapsed:Float)
    {
        if (alive)
        {
            timer = Math.max(0, timer - elapsed);

            alpha = Math.min(1, timer);

            if (timer <= 0)
                kill();
        }

        super.update(elapsed);
    }

    override function kill()
    {
        timer = 6;

        super.kill();
    }
}