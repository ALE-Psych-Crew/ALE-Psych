package core.structures;

typedef JsonStrumLineConfig = {
    > JsonBase,
    idle:String,
    hit:String,
    press:String,
    keyBind:JsonKeyBind,
    note:String,
    sustain:String,
    end:String,
    splash:Array<String>,
    sing:String,
    miss:String,
    ?shader:Array<String>
}