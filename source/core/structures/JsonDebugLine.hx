package core.structures;

import core.enums.DebugLineType;

typedef JsonDebugLine = {
    > JsonBase,
    var type:DebugLineType;
    @:optional var value:String;
    @:optional var path:String;
    @:optional var variable:String;
};