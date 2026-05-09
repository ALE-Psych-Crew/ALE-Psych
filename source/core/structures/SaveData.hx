package core.structures;

@:structInit class SaveData
{
    public var antialiasing:Bool = true;
    public var flashing:Bool = true;
	public var lowQuality:Bool = false;
	public var shaders:Bool = true;
	
	public var downScroll:Bool = false;
	public var ghostTapping:Bool = true;
	public var noReset:Bool = false;

	public var cacheOnGPU:Bool = true;
	public var framerate:Int = 120;

	public var checkForUpdates:Bool = true;
	
	public var discordRPC:Bool = true;

	public var offset:Int = 0;

	public var botplay:Bool = false;

	public var practice:Bool = false;
}