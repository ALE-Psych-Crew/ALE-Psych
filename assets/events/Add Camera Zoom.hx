function onEvent(name:String, v1:String, v2:String)
{
    if (name == 'Add Camera Zoom')
    {
        var gameZoom:Float = Std.parseFloat(v1);

        if (Math.isNaN(gameZoom))
            gameZoom = 0.03;

        var hudZoom:Float = Std.parseFloat(v2);

        if (Math.isNaN(gameZoom))
            hudZoom = 0.015;

        game.camGame.zoom += gameZoom;
        game.camHUD.zoom += hudZoom;
    }
}