package;

import flixel.text.FlxText;
import Math;


class MarqueenText extends FlxText {
	public var fullText: String;
	private var length: Int = 0;
	private var charOffset: Int = 0;

	public var isPlaying: Bool = false;
	public var reverseMode: Bool = false;
	public var stepRight: Bool = true;
	public var timeScape: Int = 400;

	function new(X:Float = 0, Y:Float = 0, Length:Int = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
		super(X, Y, 0, null, Size, EmbeddedFont);
		this.length = Length;
		fullText = Text;
		displayText();
	}
	public function drive():Void {
		isPlaying = true;
		updateText();
	}
	public function stop():Void {
		isPlaying = false;
	}
	private function displayText():Void {
		this.text = "";
		var newText = fullText + " ---";
		for (cursor in 0 ... length) {
			if ((cursor - charOffset) % (newText.length + 1) == 0) {
				this.text += " ";
			} else {
				this.text += newText.charAt((cursor - charOffset) % (newText.length + 1) - 1);
			}
		}
	}
	private function updateText():Void {
		if(!isPlaying) {
			return;
		}
		charOffset += -1;
		displayText();

		// if(reverseMode == true) {
		// 	if (textElement.x + textElement.width <= this.width) {
		// 		step = Math.abs(step);
		// 	} else if(textElement.x >= 0) {
		// 		step = -Math.abs(step);
		// 	}
		// } else {
		// 	if(step < 0 && (textElement.x + textElement.width) < 0)  {
		// 		textElement.x = this.width;
		// 	} else if(step > 0 && textElement.x > this.width) {
		// 		textElement.x = - textElement.width;
		// 	}
		// }

		haxe.Timer.delay(function() updateText(), timeScape);
	}

	public function setNewText(Text: String):Void {
		charOffset = 0;
		fullText = Text;
	}
}