package core.objects;

import openfl.display.DisplayObject;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.utils.Assets;

class GameObject extends Sprite
{
    public var members:Array<DisplayObject> = [];

    public function new()
    {
        super();

        FlxG.signals.preUpdate.add(_updateHandler);
    }
    
    public function createBitmap(img:Dynamic):Bitmap
    {
        final bitmap = new Bitmap(Assets.getBitmapData('images/soundTray/' + img + '.png'));
        bitmap.smoothing = ClientPrefs.data.antialiasing;

        return bitmap;
    }

    public function add(obj:DisplayObject):DisplayObject
    {
        addChild(obj);

        members.push(obj);

        return obj;
    }

    public function insert(index:Int, obj:DisplayObject):DisplayObject
    {
        addChildAt(obj, index);

        members.insert(index, obj);

        return obj;
    }

    public function remove(obj:DisplayObject, ?splice:Bool = false):DisplayObject
    {
        removeChild(obj);

        final index = members.indexOf(obj);

        if (splice)
            members.splice(index, 1);
        else
            members[index] = null;

        return obj;
    }

    public function clear()
    {
        for (member in members)
            remove(member);

        members.resize(0);
    }

    private function _updateHandler()
        update(FlxG.elapsed);

    public function update(elapsed:Float) {}

    public function destroy()
    {
        FlxG.signals.preUpdate.remove(_updateHandler);

        for (member in members)
        {
            remove(member);

            if (member is GameObject)
                cast(member, GameObject).destroy();
        }

        members.resize(0);

        graphics.clear();

        parent?.removeChild(this);
    }
}