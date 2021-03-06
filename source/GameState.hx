package;

typedef GameState = {
	var day: Int;
	var beginDay: Date;
	var lightState: String;
	var balance: Float;

	var kpi: Float;
	var lastKpi: Float;
	var reached2: Bool;

	var storyLevel: Int;

	var dayEnded: Bool;

	var message: String;
	var motto: String;

	var documentA: String;
	var documentB: String;
	var documentC: String;

	var leftButtonAddtion: String;
	var rightButtonAddtion: String;
	var screenAddtion: String;

	var answerMode: String;
}