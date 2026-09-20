package core.discord;

#if ALLOW_DISCORD
import hxdiscord_rpc.Types;

import cpp.RawPointer;
#end

class Presence
{
    public function new()
        _presence = #if ALLOW_DISCORD new DiscordRichPresence() #else null #end;


    public final _presence: #if ALLOW_DISCORD DiscordRichPresence #else Dynamic #end ;


    public var buttons #if ALLOW_DISCORD (get, never):RawPointer<DiscordButton> #else :Dynamic #end ;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_buttons():RawPointer<DiscordButton>
        return _presence.buttons;
    #end

    public var firstButton #if ALLOW_DISCORD (default, set) #end :Button;
    #if ALLOW_DISCORD
    @:dox(hide)
    function set_firstButton(value:Button):Button
    {
        firstButton = value;

        buttons[0] = firstButton._button;

        return firstButton;
    }
    #end

    public var secondButton #if ALLOW_DISCORD (default, set) #end :Button;
    #if ALLOW_DISCORD
    @:dox(hide)
    function set_secondButton(value:Button):Button
    {
        secondButton = value;

        buttons[1] = secondButton._button;

        return secondButton;
    }
    #end


    public var state #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_state():String
        return _presence.state;
    @:dox(hide)
    function set_state(value:String):String
        return _presence.state = value;
    #end

    public var details #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_details():String
        return _presence.details;
    @:dox(hide)
    function set_details(value:String):String
        return _presence.details = value;
    #end

    
    public var largeImageKey #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_largeImageKey():String
        return _presence.largeImageKey;
    @:dox(hide)
    function set_largeImageKey(value:String):String
        return _presence.largeImageKey = value;
    #end
        
    public var largeImageText #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_largeImageText():String
        return _presence.largeImageText;
    @:dox(hide)
    function set_largeImageText(value:String):String
        return _presence.largeImageText = value;
    #end
        

    public var smallImageKey #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_smallImageKey():String
        return _presence.smallImageKey;
    @:dox(hide)
    function set_smallImageKey(value:String):String
        return _presence.smallImageKey = value;
    #end
        
    public var smallImageText #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_smallImageText():String
        return _presence.smallImageText;
    @:dox(hide)
    function set_smallImageText(value:String):String
        return _presence.smallImageText = value;
    #end
        

    public var startTimestamp #if ALLOW_DISCORD (get, set) #end :Int;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_startTimestamp():Int
        return _presence.startTimestamp;
    @:dox(hide)
    function set_startTimestamp(value:Int):Int
        return _presence.startTimestamp = value;
    #end
        
    public var endTimestamp #if ALLOW_DISCORD (get, set) #end :Int;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_endTimestamp():Int
        return _presence.endTimestamp;
    @:dox(hide)
    function set_endTimestamp(value:Int):Int
        return _presence.endTimestamp = value;
    #end
        

    public var instance #if ALLOW_DISCORD (get, set) #end :Bool;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_instance():Bool
        return _presence.instance;
    @:dox(hide)
    function set_instance(value:Bool):Bool
        return _presence.instance = value;
    #end


    public var joinSecret #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_joinSecret():String
        return _presence.joinSecret;
    @:dox(hide)
    function set_joinSecret(value:String):String
        return _presence.joinSecret = value;
    #end

    public var matchSecret #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_matchSecret():String
        return _presence.matchSecret;
    @:dox(hide)
    function set_matchSecret(value:String):String
        return _presence.matchSecret = value;
    #end

    public var spectateSecret #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_spectateSecret():String
        return _presence.spectateSecret;
    @:dox(hide)
    function set_spectateSecret(value:String):String
        return _presence.spectateSecret = value;
    #end
        

    public var partyId #if ALLOW_DISCORD (get, set) #end :String;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_partyId():String
        return _presence.partyId;
    @:dox(hide)
    function set_partyId(value:String):String
        return _presence.partyId = value;
    #end
        
    public var partySize #if ALLOW_DISCORD (get, set) #end :Int;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_partySize():Int
        return _presence.partySize;
    @:dox(hide)
    function set_partySize(value:Int):Int
        return _presence.partySize = value;
    #end
        
    public var partyMax #if ALLOW_DISCORD (get, set) #end :Int;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_partyMax():Int
        return _presence.partyMax;
    @:dox(hide)
    function set_partyMax(value:Int):Int
        return _presence.partyMax = value;
    #end
        
    public var partyPrivacy #if ALLOW_DISCORD (get, set) #end :Int;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_partyPrivacy():Int
        return _presence.partyPrivacy;
    @:dox(hide)
    function set_partyPrivacy(value:Int):Int
        return _presence.partyPrivacy = value;
    #end
        

    public var type #if ALLOW_DISCORD (get, set) #end :Int;
    #if ALLOW_DISCORD
    @:dox(hide)
    function get_type():Int
        return _presence.type;
    @:dox(hide)
    function set_type(value:Int):Int
        return _presence.type = value;
    #end
}