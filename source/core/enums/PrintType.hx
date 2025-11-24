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
    var LOAD_SONG = 'load_song';
    var LOAD_WEEK = 'load_week';
    var RESET_STATE = 'reset_state';
    var DISCORD = 'discord';

    public function unnecessary():Bool
    {
        return switch (cast(this, PrintType))
        {
            case POP_UP, HSCRIPT, LUA, LOAD_SONG, LOAD_WEEK, RESET_STATE, DISCORD:
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
            case LOAD_SONG:
                'LOAD SONG';
            case LOAD_WEEK:
                'LOAD WEEK';
            case RESET_STATE:
                'RESET STATE';
            case DISCORD:
                'DISCORD';
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
            case LOAD_SONG:
                FlxColor.CYAN;
            case LOAD_WEEK:
                0xFF00e5FF;
            case RESET_STATE:
                FlxColor.YELLOW;
            case DISCORD:
                0xFF5865F2;
            default:
                FlxColor.GRAY;
        }
    }
}