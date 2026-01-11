package core.plugins;

import funkin.visuals.plugins.Notification;

import flixel.tweens.FlxEase.EaseFunction;

import ale.ui.ALEUIUtils;

class NotificationsPlugin extends FlxTypedGroup<Notification>
{
    public function notify(title:String, content:String, ?moveTime:Float, ?waitTime:Float, ?inEase:EaseFunction, ?outEase:EaseFunction):Notification
    {
        var notification:Notification = new Notification(title, content, moveTime, waitTime, inEase, outEase);
        notification.finishCallback = () -> {
            remove(notification, true);

            updateNotificationsTarget();
        };

        add(notification);

        updateNotificationsTarget();

        return notification;
    }

    function updateNotificationsTarget()
    {
        var curPos:Float = FlxG.height + ALEUIUtils.OBJECT_SIZE;

        for (i in 0...members.length)
        {
            final obj:Notification = members[members.length - 1 - i];

            curPos -= obj.height + 30;
            
            obj.target = curPos;
        }
    }
}