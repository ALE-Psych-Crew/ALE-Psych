package funkin.config;

import core.structures.Object;

import lime.system.System;

import haxe.io.Path;

import sys.FileSystem;
import sys.io.File;

import Type;

class SaveFile
{
    public final path:String;

    public var data(default, set):Object = {};
    function set_data(value:Object):Object
        return merge(value);

    public function new(id:String)
    {
        path = Path.join([System.applicationStorageDirectory, Paths.mod, id + '.json']);

        load();
    }

    public function load()
        if (FileSystem.exists(path))
            data = Json.parse(File.getContent(path));

    public function save()
    {
        final folderPath:String = Path.join([System.applicationStorageDirectory, Paths.mod]);

        if (!FileSystem.exists(folderPath))
            FileSystem.createDirectory(folderPath);

        File.saveContent(path, Json.stringify(data));
    }

    public function delete()
        if (FileSystem.exists(path))
            FileSystem.deleteFile(path);

    public function merge(newData:Object, ?original:Object):Object
    {
        original ??= data;

        function isObject(obj:Dynamic)
            return Type.typeof(obj) == ValueType.TObject;

        for (field in Reflect.fields(newData))
        {
            final originalRes:Dynamic = Reflect.field(original, field);
            final newRes:Dynamic = Reflect.field(newData, field);

            if (isObject(originalRes) && isObject(newRes))
                merge(newRes, originalRes);
            else
                Reflect.setField(original, field, newRes);
        }

        return original;
    }
}