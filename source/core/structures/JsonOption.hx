package core.structures;

import core.enums.OptionType;

typedef JsonOption = {
    name:String,
    variable:String,
    description:String,
    type:OptionType,
    initial:Dynamic,

    ?platform:String,

    ?path:String,

    ?list:String,

    ?min:Float,
    ?max:Float,
    ?change:Float,
    ?decimals:Int
};