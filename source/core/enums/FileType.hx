package core.enums;

enum abstract FileType(String) from String to String
{
    var BYTES = 'bytes';
    var CONTENT = 'content';
    var IMAGE = 'image';
    var AUDIO = 'audio';
    var ATLAS = 'atlas';
    var MULTI_ATLAS = 'multi_atlas';
}