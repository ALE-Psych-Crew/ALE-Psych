package core.plugins;

class DebugPrintText extends FlxText
{
    public function new()
    {
        super(10, 0, FlxG.width - 20, '', 15);

        font = Paths.font('jetbrains.ttf');
    }

    var timer:Float = 6;

    override function update(elapsed:Float)
    {
        if (!alive)
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
        super.kill();
        
        timer = 6;
    }
}