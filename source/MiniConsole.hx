package;

import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import MarqueenText;

class MiniConsole extends FlxSpriteGroup {

	private var textStatusBar: FlxTypeText;
	private var textMessage: MarqueenText;
	private var textMotto: MarqueenText;

	function new() {
		super();

		// Status bar
		textStatusBar = new FlxTypeText(0, 0, 180, "8:00 AM 8 Jan %d", 8, true);
		add(textStatusBar);

		// Message field
		textMessage = new MarqueenText(0, 10, 180, "Oh hi mark", 16, true);
		add(textMessage);
		textMessage.drive();

		// Motto field
		textMotto = new MarqueenText(0, 18, 180, "How's the weather?", 8, true);
		add(textMotto);
		textMotto.drive();
	}

	public function open(): Void {
		textStatusBar.start(null, false, false, null, null, null, null);
	}
	public function close(): Void {
		textStatusBar.erase();
		textStatusBar.skip();
	}

	override public function setSize(Width:Float, Height:Float):Void {
		super.setSize(Width, Height);
		textStatusBar.width = Width;
	}
}