package;

import flixel.util.FlxSave;

class ConsistData {
	static private var saveInstance: FlxSave;
	static public function getData(): FlxSave {
		if(saveInstance == null) {
			saveInstance = new FlxSave();
			saveInstance.bind("JEA");
		}
		return saveInstance;
	}
}