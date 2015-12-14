// package;

import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import Math;


class MarqueenText extends FlxSprite {
	private var textElement: FlxText;

	public var state: Bool = false;
	public var reverseMode: Bool = false;
	public var step: Float = -1;
	public var timeScape: Int = 10;

	function new(X:Float = 0, Y:Float = 0, Width:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
		super();
		textElement = new FlxText(X, Y, 0, Text, Size, EmbeddedFont);
		// add(textElement);
		this.width = Width;
		this.x = X;
		this.y = Y;
		this.makeGraphic(Std.int(Width), 200, flixel.util.FlxColors.TRANSPARENT);
		trace(this.pixels);

		// this.framePixels.draw(textElement.framePixels, null, null, null, new flash.geom.Rectangle(0, 0, Width, 200), false);
	}
	public function drive():Void {
		state = true;
		updateText();
	}
	public function stop():Void {
		state = false;
	}
	private function updateText():Void {
		if(!state || textElement.width > this.width) {
			return;
		}
		textElement.x += step;

		if(reverseMode == true) {
			if (textElement.x + textElement.width <= this.width) {
				step = Math.abs(step);
			} else if(textElement.x >= 0) {
				step = -Math.abs(step);
			}
		} else {
			if(step < 0 && (textElement.x + textElement.width) < 0)  {
				textElement.x = this.width;
			} else if(step > 0 && textElement.x > this.width) {
				textElement.x = - textElement.width;
			}
		}

		haxe.Timer.delay(function() updateText(), timeScape);
	}
}