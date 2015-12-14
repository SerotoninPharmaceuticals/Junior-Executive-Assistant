package;

import GameState;
import flixel.util.FlxRandom;

class GameLogic {
	public var state: GameState;
	public function new(State:GameState):Void {
		state = State;

		schedule = new Array();
	}

	private var isStory1Messed = false;
	private function beginGame():Void {
		trace("You're in day " + state.day);
		if(state.day == 4) {
			state.storyLevel = 1;
		}
		if(state.day >= 5 && state.day <= 7) {
			state.storyLevel = 2;
		}
		if(state.day == 8) {
			state.storyLevel = 3;
		}
		if(state.day == 9) {
			state.storyLevel = 4;
		}


		if(state.storyLevel == 6) {
			state.storyLevel = 7;
		}
		if(state.storyLevel == 5) {
			state.storyLevel = 6;
		}
		if(state.storyLevel == 4 && state.kpi != 0) {
			state.storyLevel = 5;
		}
		switch (state.storyLevel) {
		case 0:
			state.documentA = "printed";
			addTask("story-0", 6, function(){
				testBlock(8 + Std.random(3), function() {
					
				}, function() {
					state.dayEnded = true;
					state.lightState = "red";
				});
			});
		case 1:
			addTask("story-1", 4, function(){
				testBlock(4 + Std.random(2), function() {
					
				}, function() {
					isStory1Messed = true;
					function story1messed() {
						state.lightState = FlxRandom.float() > 0.5 ? "green" : "red";
						addTask("story1messed", FlxRandom.float() / 20, function () {
							story1messed();
						});
					}
					addTask("story1messed", 10 + 4 * FlxRandom.float(), function () {
						machine("stop-mess");
					});
					story1messed();
				});
			});
		case 2:
			state.dayEnded = true;
			state.lightState = "red";
		case 3:
			state.documentB = "printed";
			state.dayEnded = true;
			state.lightState = "red";
		case 4:
			state.documentA = "modified";
			addTask("story-4", 4, function(){
				testBlock(8 + Std.random(3), function() {
					
				}, function() {
					state.dayEnded = true;
					state.lightState = "red";
				});
			});
		case 5:
			addTask("story-5", 4, function(){
				testBlock(8 + Std.random(3), function() {
				}, function() {
					state.dayEnded = true;
					state.lightState = "red";
				});
			});
		case 6:
			state.rightButtonAddtion = "borken";
			state.answerMode = "single";
			addTask("story-6", 4, function(){
				testBlock(8 + Std.random(3), function() {
					
				}, function() {
					trace("Day 6 ended");
					state.dayEnded = true;
					state.lightState = "red";
				});
			});
		}
		case 7:
			state.documentC = "printed";
	}

	public function makeSavable():GameState {
		return {
			day: state.day,
			beginDay: new Date(2099, 9, 18, 12, 22, 33),
			lightState: "off",
			kpi: state.kpi,
			storyLevel: state.storyLevel,

			dayEnded: false,

			message: state.message,
			motto: mottos[Std.random(mottos.length)],

			documentA: state.documentA,
			documentB: state.documentB,
			documentC: state.documentC,

			leftButtonAddtion: state.leftButtonAddtion,
			rightButtonAddtion: state.rightButtonAddtion,
			answerMode: state.answerMode
		};
	}

	private function lightBlink(Times: Int,? Color: String = "green"):Void {
		if(Times <= 0) {
			state.lightState = "off";
		}
		removeTask("light-on");
		removeTask("light-off");

		for (i in 0 ... Times) {
			addTask("light-on", i* 0.5, function(){
				state.lightState = Color;
				addTask("light-off", 0.2, function(){
					state.lightState = "off";
				});
			});
		}
	}

	private var isTesting = false;
	private var testLeftIsRight = true;
	private function testBlock(Times: Int, EachCall: Void -> Void, FinalCall: Void -> Void):Void {
		trace("Open test");
		removeTask("test");
		removeTask("testend");
		lightBlink(0);
		for (i in 0 ... Times) {
			addTask("test", i * 4, function(){
				if(isTesting) {
					lose();
				}
				isTesting = true;
				testLeftIsRight = Std.random(100) > 50 ? true : false;
				if (testLeftIsRight) {
					lightBlink(1);
				} else {
					lightBlink(2);
				}
				EachCall();
			});
		}
		addTask("testend", Times * 4, function () {
			isTesting = false;
			trace("End test");
			FinalCall();
		});
	}

	private function win():Void {
		state.kpi += 1;

		trace("WIN");
	}

	private function lose():Void {
		state.kpi -= 1;

		trace("LOSE");
		if (state.kpi <0) {
			state.kpi = 0;
		}
	}

	private var lastMachineMessage = "";
	public function machine(Input: String):Void {
		lastMachineMessage = Input;
		if(isTesting) {
			if(state.leftButtonAddtion == "borken" && Input == "left-button"){
				return;
			}
			if(state.rightButtonAddtion == "borken" && Input == "right-button"){
				return;
			}
			if ((testLeftIsRight && Input == "left-button") || (!testLeftIsRight && Input == "right-button") || (!testLeftIsRight && Input == "right-button-from-left")) {
				win();
			} else {
				lose();
			}
			lightBlink(0);
			isTesting = false;
			if(state.storyLevel == 5) {
				if(Input == "right-button") {
					testBlock(0, function(){}, function(){});
					state.dayEnded = true;
					state.lightState = "red";
				}
			}
		}
		if(isStory1Messed) {
			removeTask("story1messed");
			state.lightState = "red";
			state.dayEnded = true;
		}
	}

	public function newDay():Void {
		state.day ++;
		beginGame();
	}

	private var schedule: Array<Task>;
	private function addTask(Name: String, Delay: Float, Callback: Void -> Void):Void {
		schedule.push({
			name: Name,
			delay: Delay,
			runAt: timeline + Delay,
			callback: Callback
		});
	}
	private function executeTask(timeline):Void {
		var stackTasks:Array<Task> = new Array();
		schedule = schedule.filter(function(CurrentTask):Bool{
			if(CurrentTask.runAt <= timeline) {
				stackTasks.push(CurrentTask);
				return false;
			}
			return true;
		});

		for (i in 0 ... stackTasks.length) {
			stackTasks[i].callback();
		}
	}
	private function removeTask(Name: String):Void {
		schedule = schedule.filter(function(CurrentTask):Bool{
			if(CurrentTask.name == Name) {
				return false;
			}
			return true;
		});
	}

	private var todayFinished = 0;
	private var todayTested = 0;
	private var timeline: Float = 0;
	public function update(Delta: Float):Void {
		timeline += Delta;


		executeTask(timeline);
	}

	static public function brandNewDay():GameState {
		return {
			day: 10 - 1,
			beginDay: new Date(2099, 9, 18, 12, 22, 33),
			lightState: "off",
			kpi: 10,
			storyLevel: 5,

			dayEnded: false,

			message: "Welcome, homie",
			motto: mottos[Std.random(mottos.length)],

			documentA: "unavailable",
			documentB: "unavailable",
			documentC: "unavailable",


			leftButtonAddtion: "none",
			rightButtonAddtion: "none",

			answerMode: "both"
		};
	}

	private static var mottos = [
		"You can if you think you can.",
		"The greatest oak was once a little nut who held its ground. ",
		"Think big thoughts, but relish small pleasures. ",
		"Hope sees the invisible, feels the intangible and achieves the impossible.",
		"I take nothing for granted. I now have only good days, or great days.",
		"I long to accomplish a great and noble task, but it is my chief duty to accomplish humble tasks as though they were great and noble. The world is moved along not only by the mighty shoves of its heroes but also by the aggregate of the tiny pushes of each honest worker. ",
		"It doesn't matter who you are, where you come from. The ability to triumph begins with you. Always.",
		"Trust yourself. You know more than you think you do.",
		"No one knows what they can do until they try.",
		"What lies behind us and what lies before us are tiny matters compared to what lies within us.",
		"The best way to predict the future is to create it.",
		"Do not let what you cannot do interfere with what you can do.",
		"Life is 10% what happens to us and 90% how we react to it.",
		"By working faithfully eight hours a day you may eventually get to be boss and work twelve hours a day",
		"When I hear somebody sigh, ‘Life is hard,’ I am always tempted to ask, ‘Compared to what? ",
		"Do first things first, and second things not at all.",
		"Success seems to be connected with action. Successful people keep moving. They make mistakes but don’t quit.",
		"Where the willingness is great, the difficulties cannot be great."
	];
}

typedef Task = {
	var name: String;
	var delay: Float;
	var runAt: Float;
	var callback: Void -> Void;
}
