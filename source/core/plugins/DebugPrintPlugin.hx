package core.plugins;

import funkin.visuals.plugins.DebugPrintText;

class DebugPrintPlugin extends FlxTypedGroup<DebugPrintText>
{
    public function print(debugText:String, ?prefix:String, ?color:FlxColor)
    {
        var text:DebugPrintText = recycle(DebugPrintText);

        members.remove(text);
        members.push(text);

        text.setData(debugText, prefix, color);
        
        var curHeight:Float = FlxG.height - 8;

        for (i in 1...(members.length + 1))
        {
            var obj:DebugPrintText = members[members.length - i];
            
            curHeight -= obj.height + 4;

            if (curHeight <= -obj.height)
                obj.kill();

            obj.y = curHeight;
        }
    }
}