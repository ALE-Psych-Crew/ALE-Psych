package core.structures;

import core.enums.Quality;

typedef JsonStageObject = {
    > JsonBopper,
    id:String,
    ?cameras:Array<String>,
    ?addMethod:String,
    ?classPath:String,
    ?classArguments:Array<Dynamic>,
    ?quality:Quality
}