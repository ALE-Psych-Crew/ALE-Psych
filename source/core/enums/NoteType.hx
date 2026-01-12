package core.enums;

enum abstract NoteType(String) from String to String
{
    var NOTE = 'note';
    var SUSTAIN = 'sustain';
    var END = 'end';
}