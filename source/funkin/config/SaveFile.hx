package funkin.config;

import lime.system.System;

import haxe.io.Path;

import sys.FileSystem;
import sys.io.File;

import utils.cool.ReflectUtil;

class SaveFile
{
    public final folderPath:String;
    public final filePath:String;

    public var data(default, set):Dynamic = {};
    function set_data(value:Dynamic):Dynamic
        return merge(value);

    public function new(id:String, ?ignoreMod:Bool = false)
    {
        folderPath = Path.join([System.applicationStorageDirectory, ignoreMod ? null : Paths.mod]);

        filePath = Path.join([folderPath, id + '.json']);

        load();
    }

    public function load()
        if (FileSystem.exists(filePath))
            data = Json.parse(File.getContent(filePath));

    public function save()
    {
        if (!FileSystem.exists(folderPath))
            FileSystem.createDirectory(folderPath);

        File.saveContent(filePath, Json.stringify(data));
    }

    public function delete()
        if (FileSystem.exists(filePath))
            FileSystem.deleteFile(filePath);

    public function merge(newData:Dynamic, ?original:Dynamic):Dynamic
    {
        original ??= data;

        if (!ReflectUtil.isObject(newData) || !ReflectUtil.isObject(original))
            return {};

        for (field in Reflect.fields(newData))
        {
            final originalRes:Dynamic = Reflect.field(original, field);
            final newRes:Dynamic = Reflect.field(newData, field);

            if (ReflectUtil.isObject(originalRes) && ReflectUtil.isObject(newRes))
                merge(newRes, originalRes);
            else
                Reflect.setField(original, field, newRes);
        }

        return original;
    }
}