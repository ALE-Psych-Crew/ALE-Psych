package funkin.visuals.shaders;

import flixel.addons.display.FlxRuntimeShader;
import lime.graphics.opengl.GLProgram;
import lime.app.Application;

@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.Program3D)
@:access(openfl.display.ShaderInput)
@:access(openfl.display.ShaderParameter)
class RuntimeShader extends FlxRuntimeShader
{
	final glslVersion:String;

    public var shaderName:String = '';

    public function new(?shaderName:String, ?forced:Bool = false, ?version:String = '120')
    {
        this.shaderName = shaderName;
		
		final allowed:Bool = ClientPrefs.data.shaders || forced;
        
		glslVersion = version.trim();

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

	override function __initGL():Void
	{
		if (__glSourceDirty || __paramBool == null)
		{
			__glSourceDirty = false;

			program = null;

			__inputBitmapData = new Array();
			__paramBool = new Array();
			__paramFloat = new Array();
			__paramInt = new Array();

			__processGLData(glVertexSource, "attribute");
			__processGLData(glVertexSource, "uniform");
			__processGLData(glFragmentSource, "uniform");
		}

		if (__context != null && program == null)
		{
			final gl = __context.gl;

			final prefix = '#version ' + glslVersion + '\n' + "#ifdef GL_ES\n"
				+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH\n"
					+ "precision highp float;\n"
					+ "#else\n"
					+ "precision mediump float;\n"
					+ "#endif\n" : "precision lowp float;\n")
				+ "#endif\n\n";

			final vertex = prefix + glVertexSource;
			final fragment = prefix + glFragmentSource;

			final id = vertex + fragment;

			if (__context.__programs.exists(id))
			{
				program = __context.__programs.get(id);
			} else {
				program = __context.createProgram(GLSL);
				program.__glProgram = __createGLProgram(vertex, fragment);

				__context.__programs.set(id, program);
			}

			if (program != null)
			{
				glProgram = program.__glProgram;

				for (input in __inputBitmapData)
					if (input.__isUniform)
						input.index = gl.getUniformLocation(glProgram, input.name);
					else
						input.index = gl.getAttribLocation(glProgram, input.name);

				for (parameter in __paramBool)
					if (parameter.__isUniform)
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);

				for (parameter in __paramFloat)
					if (parameter.__isUniform)
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);

				for (parameter in __paramInt)
					if (parameter.__isUniform)
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
			}
		}
	}
}