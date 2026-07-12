package funkin.visuals.shaders;

import flixel.addons.display.FlxRuntimeShader;

import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;

@:access(openfl.display3D.Context3D)
class RuntimeShader extends FlxRuntimeShader
{
    public var shaderName:String = '';

    public function new(?shaderName:String, ?forced:Bool = false)
    {
        this.shaderName = shaderName;
		
		final allowed:Bool = ClientPrefs.data.shaders || forced;
        
        super(Paths.exists('shaders/' + shaderName + '.frag') && allowed ? Paths.getContent('shaders/' + shaderName + '.frag') : null, Paths.exists('shaders/' + shaderName + '.vert') && allowed ? Paths.getContent('shaders/' + shaderName + '.vert') : null);
    }

	override function __createGLShader(source:String, type:Int):GLShader
	{
		final gl = __context.gl;

		final shader = gl.createShader(type);
		gl.shaderSource(shader, source);
		gl.compileShader(shader);

		if (gl.getShaderParameter(shader, gl.COMPILE_STATUS) == 0)
			throw gl.getShaderInfoLog(shader);

		return shader;
	}

	override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
	{
		try
		{
			return super.__createGLProgram(vertexSource, fragmentSource);
		} catch (error) {
			debugTrace('Compiling Shader "' + shaderName + '":\n' + error, ERROR);

			return null;
		}
	}
}