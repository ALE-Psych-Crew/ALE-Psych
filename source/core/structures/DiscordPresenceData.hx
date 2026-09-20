package core.structures;

typedef DiscordPresenceData = {
    ?firstButton:DiscordPresenceDataButton,
    ?secondButton:DiscordPresenceDataButton,
    ?state:String,
    ?details:String,
    ?largeImageKey:String,
    ?largeImageText:String,
    ?smallImageKey:String,
    ?smallImageText:String,
    ?startTimestamp:Int,
    ?endTimestamp:Int,
    ?instance:Bool,
    ?joinSecret:String,
    ?matchSecret:String,
    ?spectateSecret:String,
    ?partyId:String,
    ?partySize:Int,
    ?partyMax:Int,
    ?partyPrivacy:Int,
    ?type:Int
}
