package;

import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import MarqueenText;

class MiniConsole extends FlxSpriteGroup {

	var textDate: FlxText;
	var textKpi: FlxText;
	var textMessage: MarqueenText;
	var textMotto: MarqueenText;

	function new() {
		super();

		// Status bar
		textDate = new FlxText(0, 2, 175, "13 Dec", 14, true);
		textDate.setFormat("assets/fonts/led_display-7.ttf", 14, 0x66ffaa);
		add(textDate);

		textKpi = new FlxText(0, 2, 175, "KPI 12/20", 14, true);
		textKpi.setFormat("assets/fonts/led_display-7.ttf", 14, 0x66ffaa, "right");
		add(textKpi);

		// Message field
		textMessage = new MarqueenText(0, 16, 8, "Oh hi mark", 30, true);
		textMessage.setFormat("assets/fonts/led_display-7.ttf", 30, 0x66ffaa);
		add(textMessage);
		textMessage.drive();
		textMessage.alpha = 0;

		// Motto field
		textMotto = new MarqueenText(0, 46, 17, "How's the weather?", 14, true);
		textMotto.setFormat("assets/fonts/led_display-7.ttf", 14, 0x66ffaa);
		add(textMotto);
		textMotto.drive();
		textMotto.timeScape = 200;
	}

	public function open(): Void {
		// textDate.alpha = 1;
		// textKpi.alpha = 1;
		textMessage.alpha = 1;
		// textMotto.alpha = 1;
	}
	public function close(): Void {
		// textDate.alpha = 0;
		// textKpi.alpha = 0;
		textMessage.alpha = 0;
		// textMotto.alpha = 0;
	}

	public function updateText(NewDate: Date, Message: String, Motto: String, Kpi: Float):Void {
		textDate.text = getStrDate(NewDate);
		textKpi.text = "KPI:" + floatToStr(Kpi);
		if(textMessage.fullText != Message) {
			textMessage.setNewText(Message);
		}
		if(textMotto.fullText != Motto) {
			textMotto.setNewText(Motto);
		}
	}

	public static function floatToStr(Number: Float): String {
		var str = Std.string(Number);
		if(str.indexOf('.')  != -1) {
			return str.substr(0, str.indexOf('.') + 2);
		} else {
			return str + ".0";
		}
	}

	public static function getStrDate(NewDate: Date): String {
		return Std.string(NewDate.getDate()) + " " + monthDict[NewDate.getMonth() - 1];
	}

	static private var monthDict = [
		"Jan.",
		"Feb.",
		"Mar.",
		"Apr.",
		"May.",
		"Jun.",
		"Jul.",
		"Aug.",
		"Sep.",
		"Oct.",
		"Nov.",
		"Dec."
	];

}