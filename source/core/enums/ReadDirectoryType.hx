package core.enums;

enum abstract ReadDirectoryType(String) from String to String
{
    var UNIQUE = 'unique';
    var MULTIPLE = 'multiple';
}