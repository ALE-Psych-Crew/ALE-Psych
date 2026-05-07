package core.enums;

enum abstract PrintType(String) from String to String
{
    var ERROR = 'error';
    var WARNING = 'warning';
    var DEPRECATED = 'deprecated';
    var TRACE = 'trace';
    var HSCRIPT = 'hscript';
    var LUA = 'lua';
    var MISSING_FILE = 'missing_file';
    var MISSING_FOLDER = 'missing_folder';
    var POP_UP = 'pop_up';
    var LOAD_SONG = 'load_song';
    var LOAD_WEEK = 'load_week';
    var RESET_STATE = 'reset_state';
    var DISCORD = 'discord';
    var BENCHMARK = 'benchmark';
}