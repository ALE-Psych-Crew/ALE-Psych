package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

class LuaDiscord extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
        
        set('changeDiscordPresence', function(details:String, ?state:String, ?largeImage:String, ?smallImage:String, ?usesTime:Bool, ?endTime:Float)
        {
            DiscordRPC.changePresence(details, state, largeImage, smallImage, usesTime, endTime);
        });

        set('changeDiscordClientID', (id:String) -> {
            DiscordRPC.shutdown();

            DiscordRPC.initialize(id);
        });
    }
}
