using StringTools;

function onEvent(name:String, v1:String, v2:String)
{
    if (name == 'Alt Idle Animation')
    {
        var char:Character = switch (v1.toLowerCase().trim())
        {
            case 'bf', 'boyfriend', '0':
                game.boyfriend;
            case 'gf', 'girlfriend', '1':
                game.gf;
            default:
                game.dad;
        };

        if (char != null)
        {
            char.idleSuffix = v2;
            char.recalculateDanceIdle();
        }
    }
}