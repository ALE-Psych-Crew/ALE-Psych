package core.enums;

enum abstract OptionType(String) from String to String
{
    var BOOL = 'bool';
    var STATE = 'state';
    var SUBSTATE = 'state';
    var STRING = 'string';
    var INT = 'int';
    var FLOAT = 'float';
}