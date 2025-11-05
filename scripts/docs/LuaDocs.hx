package scripts.docs;

import sys.FileSystem;
import sys.io.File;

using StringTools;

enum abstract DocsMeta(String)
{
    var PARAM_META = '@param';
    var DEPRECATED_META = '@deprecated';
    var RETURN_META = '@return';
}

enum abstract DocsType(String)
{
    var DESCRIPTION = 'description';
    var DEPRECATED = 'deprecated';
    var PARAM = 'param';
    var RETURN = 'return';
}

typedef DocsInstruction = {
    var type:DocsType;
    var data:String;
    @:optional var name:String;
}

typedef DocsFunction = {
    var name:String;
    var args:Array<String>;
    var instructions:Array<DocsInstruction>;
    @:optional var ret:String;
}

typedef DocsPath = {
    var path:String;
    var folder:String;
    var name:String;
}

class LuaDocs
{
    static final GEN_PATH:String = 'docs/lua';

    static function deleteFolderRecursive(path:String)
    {
        if (!FileSystem.exists(path))
            return;

        var files = FileSystem.readDirectory(path);

        for (file in files)
        {
            var fullPath = path + "/" + file;

            if (FileSystem.isDirectory(fullPath))
                deleteFolderRecursive(fullPath);
            else
                FileSystem.deleteFile(fullPath);
        }

        FileSystem.deleteDirectory(path);
    }

    static var generated:Int = 0;

    static var functions:Int = 0;

    static var list:Array<String> = [];

    public static function main(?base:String, ?path:String)
    {
        deleteFolderRecursive(GEN_PATH);

        var fullPath:String = (base.length > 0 ? base + '/' : '') + path;

        if (!FileSystem.exists(fullPath))
            return;

        var toGen:Array<DocsPath> = [];

        if (FileSystem.isDirectory(fullPath))
        {
            for (file in FileSystem.readDirectory(fullPath))
                if (file.endsWith('.hx'))
                    toGen.push(
                        {
                            path: fullPath + '/' + file,
                            folder: path,
                            name: file.substr(0, file.length - 3)
                        }
                    );
        } else {
            var splitPath:Array<String> = path.split('/');

            toGen.push(
                {
                    path: fullPath,
                    folder: splitPath.length > 1 ? splitPath.slice(0, splitPath.length - 1).join('/') : '',
                    name: fullPath.split('/').pop().substr(0, fullPath.split('/').pop().length - 3)
                }
            );
        }
        
        generated = 0;

        functions = 0;

        list = [];

        for (index => file in toGen)
            generate(read(File.getContent(file.path)), file.folder, file.name);
        
        var homePage:String = '';

        homePage += '# ALE Psych Lua API\n\n';
        homePage += '## Home Page\n\n';
        homePage += '### Table of Contents:\n\n';

        for (file in list)
            homePage += '- [' + file + '](' + path + '/' + file + '.md)\n';

        File.saveContent(GEN_PATH + '/Home.md', homePage);

        Sys.println('');
        Sys.println('---- [ALE Psych\'s Lua Docs] ----');
        Sys.println('');
        Sys.println('Files Found: ' + toGen.length);
        Sys.println('Files Generated: ' + generated);
        Sys.println('Functions Found: ' + functions);
        Sys.println('Files Generated List: ' + list.join(' - '));
    }

    static function metaToString(str:String)
        return [
            PARAM_META => PARAM,
            DEPRECATED_META => DEPRECATED,
            RETURN_META => RETURN
        ].get(cast str);

    static function isMeta(str:String)
        return [PARAM_META, DEPRECATED_META, RETURN_META].contains(cast str);

    public static function read(str:String):Array<DocsFunction>
    {
        var lines:Array<String> = str.split('\n');

        var curLine:Int = 0;

        var commentLine:Bool = false;

        var functionLine:Bool = false;

        var instructions:Array<DocsFunction> = [];

        var inst:Array<DocsInstruction> = [];

        var curType:DocsType = DESCRIPTION;

        var curText:String = '';

        while (curLine < lines.length)
        {
            var line:String = lines[curLine];
            
            curLine++;

            if (line.trim().length <= 0)
                continue;

            function saveInstruction()
            {
                switch (curType)
                {
                    case DESCRIPTION:
                        inst.push(
                            {
                                type: DESCRIPTION,
                                data: curText
                            }
                        );
                    case DEPRECATED:
                        inst.push(
                            {
                                type: DEPRECATED,
                                data: curText
                            }
                        );
                    case PARAM:
                        inst.push(
                            {
                                type: PARAM,
                                name: curText.split(' ')[0],
                                data: [for (i in 1...curText.split(' ').length) curText.split(' ')[i]].join(' ')
                            }
                        );
                    case RETURN:
                        inst.push(
                            {
                                type: RETURN,
                                data: curText
                            }
                        );
                }
            }

            if (functionLine)
            {
                if (line.trim().startsWith('set('))
                {
                    functions++;

                    var regex:EReg = ~/[\(\)'",]|function/g;

                    var splitLine:Array<String> = regex.replace(line.trim().substring(4), ' ').split(' ').filter(function (str) return str.trim().length > 0);

                    var data:DocsFunction = {
                        name: splitLine[0],
                        args: [for (i in 1...(splitLine.length)) splitLine[i]],
                        instructions: inst,
                        ret: null
                    };

                    if (data.args.length > 0)
                        if (data.args[data.args.length - 1].startsWith(':'))
                            data.ret = data.args.pop();

                    instructions.push(data);
                }

                inst = [];

                functionLine = false;
            }

            if (line.trim() == '*/' && commentLine)
            {
                commentLine = false;

                functionLine = true;
                
                saveInstruction();

                curText = '';
                
                curType = DESCRIPTION;
            }

            if (commentLine)
            {
                if (!line.trim().startsWith('* '))
                    continue;

                var sprLine:String = line.trim().substr(2);
                
                if (sprLine.trim().length <= 0)
                    continue;

                var splitLine:Array<String> = sprLine.split(' ');

                for (line in splitLine)
                    if (isMeta(line))
                    {
                        saveInstruction();

                        curText = '';

                        curType = metaToString(line);
                    } else {
                        curText += line + ' ';
                    }
            }

            if (line.trim() == '/**' && !commentLine)
                commentLine = true;
        }

        return instructions;
    }
    
    public static function generate(instructions:Array<DocsFunction>, folder:String, name:String)
    {
        var finalText:String = '';

        var col = 0;

        for (co => instruction in instructions)
        {
            col++;

            finalText += '---\n\n### > `' + instruction.name + '(' + instruction.args.join(', ') + ')' + (instruction.ret ?? '') + '`\n\n';

            for (inst in instruction.instructions)
            {
                switch (inst.type)
                {
                    case DESCRIPTION:
                        finalText += '#### ' + inst.data + '\n\n';
                    case PARAM:
                        finalText += '- `' + inst.name + '`: ' + inst.data + '\n\n';
                    case DEPRECATED:
                        finalText += '###### `DEPRECATED`: ' + inst.data + '\n\n';
                    case RETURN:
                        finalText += '#### `RETURN`: ' + inst.data + '\n\n';
                }
            }
        }

        finalText += '\n\n##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)';

        if (finalText.trim().length <= 0)
            return;

        generated++;

        list.push(name);

        finalText = '# ' + name + finalText.substring(3, finalText.length);
        
        if (!FileSystem.exists(GEN_PATH + '/' + folder))
            FileSystem.createDirectory(GEN_PATH + '/' + folder);

        File.saveContent(GEN_PATH + '/' + folder + '/' + name + '.md', finalText);
    }
}