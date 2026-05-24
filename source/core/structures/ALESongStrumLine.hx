package core.structures;

import core.enums.CharacterType;

typedef ALESongStrumLine = {
    var file:String;
    var position:Point;
    var rightToLeft:Bool;
    var visible:Bool;
    var characters:Array<String>;
    var type:CharacterType;
};