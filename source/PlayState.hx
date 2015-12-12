package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import ConsistData;
import MiniConsole;

class PlayState extends FlxState
{
	override public function create():Void
	{
		super.create();
		var wall = new FlxSprite();
		wall.loadGraphic("assets/images/wall.png");
		add(wall);
		var machine = new FlxSprite();
		machine.loadGraphic("assets/images/machine.png");
		add(machine);
		machine.x = (1080 / 2) - (machine.width / 2);
		machine.y = -100;

		var console = new MiniConsole();
		add(console);
		console.x = (1080 / 2) - (console.width / 2);
		console.y = 10;
		console.open();
	}

	override public function update():Void
	{
		super.update();
	}
}