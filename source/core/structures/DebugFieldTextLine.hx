package core.structures;

import core.enums.DebugFieldTextLineType;

typedef DebugFieldTextLine = {
    var type:DebugFieldTextLineType;
    @:optional var value:String;
    @:optional var path:String;
    @:optional var variable:String;
}