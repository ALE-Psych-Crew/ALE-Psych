package core.plugins;

class DebugPrintPlugin extends FlxTypedGroup<DebugPrintText>
{
    override public function new()
    {
        super();
    }

    public function print(debugText:String, ?prefix:String, ?color:FlxColor)
    {
        var text:DebugPrintText = recycle(DebugPrintText);
        text.clearFormats();

        members.remove(text);
        members.push(text);

        text.text = prefix + ' | ' + debugText;

        text.addFormat(new FlxTextFormat(color), 0, prefix.length);
        text.addFormat(new FlxTextFormat(0xFF505050), prefix.length + 1, prefix.length + 2);
        text.setBorderStyle(OUTLINE_FAST);
        
        var curHeight:Float = FlxG.height - 5;

        for (i in 1...(members.length + 1))
        {
            var obj:DebugPrintText = members[members.length - i];
            
            curHeight -= obj.height + 5;

            if (curHeight <= -obj.height)
                obj.kill();

            obj.y = curHeight;
        }
    }
}