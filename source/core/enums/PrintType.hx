package core.enums;

enum abstract PrintType(String)
{
    var ERROR = 'error';
    var WARNING = 'warning';
    var DEPRECATED = 'deprecated';
    var TRACE = 'trace';
    var HSCRIPT = 'hscript';
    var LUA = 'lua';
    var MISSING_FILE = 'missing_file';
    var MISSING_FOLDER = 'missing_folder';
    var CUSTOM = 'custom';
    var POP_UP = 'pop-up';

    public function unnecessary():Bool
    {
        return switch (cast(this, PrintType))
        {
            case POP_UP, HSCRIPT, LUA:
                true;
            default:
                false;
        }
    }

    public function toString():String
    {
        return switch (cast(this, PrintType))
        {
            case ERROR:
                'ERROR';
            case WARNING:
                'WARNING';
            case DEPRECATED:
                'DEPRECATED';
            case TRACE:
                'TRACE';
            case HSCRIPT:
                'HSCRIPT';
            case LUA:
                'LUA';
            case MISSING_FILE:
                'MISSING FILE';
            case MISSING_FOLDER:
                'MISSING FOLDER';
            case POP_UP:
                'POP-UP';
            default:
                'UNKNOWN';
        }
    }

    public function toColor():FlxColor
    {
        return switch (cast(this, PrintType))
        {
            case ERROR:
                0xFFFF5555;
            case WARNING:
                0xFFFFA500;
            case DEPRECATED:
                0xFF8000;
            case TRACE:
                0xFFFFFFFF;
            case HSCRIPT:
                0xFF88CC44;
            case LUA:
                0xFF4466DD;
            case MISSING_FILE:
                0xFFFF7F00;
            case MISSING_FOLDER:
                0xFFFF7F00;
            case POP_UP:
                0xFFFF00FF;
            default:
                FlxColor.GRAY;
        }
    }
}