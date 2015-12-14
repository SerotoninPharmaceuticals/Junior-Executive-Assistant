package;

import flixel.FlxG;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flixel.FlxGame;
import flixel.addons.ui.FlxUIButton;

class Main extends Sprite 
{
	static public function main():Void
	{	
		Lib.current.addChild(new Main());
		FlxG.mouse.useSystemCursor = true;
		FlxG.autoPause = true;
	}
	
	public function new() 
	{
		super();
		
		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		addChild(new FlxGame(1080, 160, PlayState, 1, 60, 60, true));
	}
}