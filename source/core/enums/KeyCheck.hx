package core.enums;

enum abstract KeyCheck(String) from String to String
{
    var PRESSED = 'pressed';
    var JUST_PRESSED = 'just_pressed';
    var JUST_RELEASED = 'just_released';
}