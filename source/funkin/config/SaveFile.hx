package funkin.config;

import lime.system.System;

import sys.FileSystem;
import sys.io.File;

import haxe.io.Path;

class SaveFile
{
    public final path:String;

    public var data:Dynamic = {};

    public function new(id:String)
    {
        path = Path.join([System.applicationStorageDirectory, Paths.mod, id + '.json']);

        if (FileSystem.exists(path))
            data = Json.parse(File.getContent(path));
    }

    public function save():Dynamic
    {
        final folderPath:String = Path.join([System.applicationStorageDirectory, Paths.mod]);

        if (!FileSystem.exists(folderPath))
            FileSystem.createDirectory(folderPath);

        File.saveContent(path, Json.stringify(data));

        return data;
    }
}