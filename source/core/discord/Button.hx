package core.discord;

#if ALLOW_DISCORD
import hxdiscord_rpc.Types.DiscordButton;
#end

class Button
{
    public function new(?label:String, ?url:String)
    {
        _button = #if ALLOW_DISCORD new DiscordButton() #else null #end;

        if (label != null)
            this.label = label;

        if (url != null)
            this.url = url;
    }

    public final _button: #if ALLOW_DISCORD DiscordButton #else Dynamic #end ;

    public var label #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_label():String
        return _button.label;
    @:dox(hide)
    function set_label(val:String):String
        return _button.label = val;
    #end

    public var url #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_url():String
        return _button.url;
    @:dox(hide)
    function set_url(val:String):String
        return _button.url = val;
    #end
}