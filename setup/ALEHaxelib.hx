package setup;

import sys.io.File;

import sys.FileSystem;

import haxe.Json;

typedef Category = {
    name:String,
    libraries:Array<Library>,
}

typedef Library = {
    name:String,
    ?version:String,
    ?git:String,
    ?commit:String,
    ?skipDependencies:Bool
}

class ALEHaxelib
{
    public static function main()
    {
        if (!FileSystem.exists('.haxelib') || !FileSystem.isDirectory('.haxelib'))
            FileSystem.createDirectory('.haxelib');

        Sys.println('\n' + File.getContent('setup/ALEHaxelibLogo.txt') + '\n\n');

        final categories:Array<Category> = cast Json.parse(File.getContent('setup/libraries.json')).categories;

        var totalLibraries:Int = 0;

        for (category in categories)
            totalLibraries += category.libraries.length;

        var installedLibraries:Int = 0;

        for (category in categories)
        {
            Sys.println('  > ' + category.name + ' - ' + category.libraries.length + '\n');

            for (lib in category.libraries)
            {
                installedLibraries++;

                Sys.println('     - Installing ' + lib.name + '...\n');

                var command:Array<String> = ['haxelib'];

                if (lib.git != null)
                {
                    command = command.concat(['git', lib.name, lib.git]);

                    if (lib.commit != null)
                        command.push(lib.commit);
                } else if (lib.version != null) {
                    command = command.concat(['install', lib.name, lib.version]);
                }

                if (lib.skipDependencies)
                    command.push('--skip-dependencies');

                Sys.print('       Haxelib: ');

                final process:Int = Sys.command(command.join(' '));

                if (process == 0)
                    Sys.println('\n       * Installed - ' + ALEHaxelib.roundDecimal(installedLibraries / totalLibraries * 100, 2) + '%');
                else
                    Sys.println('\n       * Error');

                Sys.println('\n');
            }
        }
    }

	static function roundDecimal(value:Float, precision:Int):Float
	{
		var mult:Float = 1;

		for (i in 0...precision)
			mult *= 10;

        return Math.fround(value * mult) / mult;
	}
}