package funkin.visuals.shaders;

import flixel.addons.display.FlxRuntimeShader;
import lime.graphics.opengl.GLProgram;
import lime.app.Application;

class RuntimeShader extends FlxRuntimeShader
{
    public var shaderName:String = '';

    public function new (?shaderName:String, ?forced:Bool = false)
    {
        this.shaderName = shaderName;
		
		final allowed:Bool = ClientPrefs.data.shaders || forced;
        
        super(Paths.exists('shaders/' + shaderName + '.frag') && allowed ? Paths.getContent('shaders/' + shaderName + '.frag') : null, Paths.exists('shaders/' + shaderName + '.vert') && allowed ? Paths.getContent('shaders/' + shaderName + '.vert') : null);
    }

	override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
	{
		try
		{
			final res = super.__createGLProgram(vertexSource, fragmentSource);

			return res;
		} catch (error) {
			debugTrace('Error when Starting Shader "' + shaderName + '":\n' + error, ERROR);

			return null;
		}
	}
}