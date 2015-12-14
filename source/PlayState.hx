package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import ConsistData;
import MiniConsole;
import flash.display.BlendMode;
import GameLogic;
import flixel.util.FlxSpriteUtil;
import haxe.Timer;

class PlayState extends FlxState
{
	private var buttonLeft: FlxButton;
	private var buttonRight: FlxButton;

	private var light: FlxSprite;
	private var lightHalo: FlxSprite;

	private var console: MiniConsole;

	private var logic: GameLogic;


	private var documentMask: FlxSprite;
	private var documentLarge: FlxButton;

	private var documentPrintingShadow: FlxSprite;
	private var documentPrintingShadowFore: FlxSprite;
	private var documentPrintingShadowMask: FlxSprite;
	private var documentPrinting: FlxButton;

	private var smallDocumentA: FlxButton;
	private var smallDocumentAM: FlxButton;
	private var smallDocumentB: FlxButton;
	private var smallDocumentC: FlxButton;

	private var leftButtonUpImage = "assets/images/button.png";
	private var leftButtonDownImage = "assets/images/button-pressed.png";
	private var rightButtonUpImage = "assets/images/button.png";
	private var rightButtonDownImage = "assets/images/button-pressed.png";

	override public function create():Void
	{
		super.create();

		if(ConsistData.getData().data.save == null) {
		// if(true) {
			ConsistData.getData().data.save = GameLogic.brandNewDay();
		}
		logic = new GameLogic(Reflect.copy( ConsistData.getData().data.save));
		preState = Reflect.copy(logic.state);
		wallDocuments = Reflect.copy(logic.state);
		logic.newDay();

		if (logic.state.leftButtonAddtion == "broken") {
			leftButtonUpImage = "assets/images/button-base-left.png";
			leftButtonDownImage = "assets/images/button-base-left.png";
		}
		if (logic.state.rightButtonAddtion == "broken") {
			rightButtonUpImage = "assets/images/button-base-right.png";
			rightButtonDownImage = "assets/images/button-base-right.png";
		}
		if (logic.state.leftButtonAddtion == "fake") {
			leftButtonUpImage = "assets/images/button-fake.png";
			leftButtonDownImage = "assets/images/button-fake.png";
		}


		var background = new FlxSprite();
		background.loadGraphic("assets/images/background.png");
		add(background);

		if(logic.state.screenAddtion != "broken") {
			console = new MiniConsole();
			add(console);
			console.x = (1080 / 2) - (console.width / 2);
			console.y = 11;
			console.open();
		} else {
			var brokenConsole = new FlxSprite();
			brokenConsole.loadGraphic("assets/images/screen-broken.png");
			add(brokenConsole);
			brokenConsole.x = (1080 / 2) - (brokenConsole.width / 2);
			brokenConsole.y = 11;
		}

		lightHalo = new FlxSprite();
		lightHalo.loadGraphic("assets/images/light-halo-green.png");
		add(lightHalo);
		lightHalo.x = 433;
		lightHalo.y = 34;
		lightHalo.blend = BlendMode.OVERLAY;
		lightHalo.alpha = 0;

		light = new FlxSprite();
		light.loadGraphic("assets/images/light.png");
		add(light);
		light.x = 450;
		light.y = 89;

		buttonLeft = new FlxButton(0, 0, "");
		buttonLeft.loadGraphic(leftButtonUpImage);
		add(buttonLeft);
		buttonLeft.x = 488;
		buttonLeft.y = 84;
		buttonLeft.onDown.callback = leftButtonPress;
		buttonLeft.onUp.callback = leftButtonEnd;
		buttonLeft.onOut.callback = leftButtonEnd;

		buttonRight = new FlxButton(0, 0, "");
		buttonRight.loadGraphic(rightButtonUpImage);
		add(buttonRight);
		buttonRight.x = 568;
		buttonRight.y = 84;
		buttonRight.onDown.callback = rightButtonPress;
		buttonRight.onUp.callback = rightButtonEnd;
		buttonRight.onOut.callback = rightButtonEnd;


		// Document printing
		documentPrintingShadowFore = new FlxSprite();

		documentPrintingShadowMask = new FlxSprite();
		documentPrintingShadowMask.loadGraphic("assets/images/mask-of-document-shadow.png");

		documentPrintingShadow = new FlxSprite();
		add(documentPrintingShadow);
		documentPrintingShadow.x = 722;
		documentPrintingShadow.y = 0;

		// 
		documentPrinting = new FlxButton(0, 0, "");
		documentPrinting.loadGraphic("assets/images/document-printing-1.png");
		add(documentPrinting);
		documentPrinting.x = 708;
		documentPrinting.y = -1000;
		documentPrinting.onDown.callback = printingDocumentClicked;

		documentPrinting.alpha = 0;
		documentPrintingShadow.alpha = 0;


		// Small documents
		smallDocumentA = new FlxButton();
		smallDocumentA.loadGraphic("assets/images/document-a.png");
		add(smallDocumentA);
		smallDocumentA.x = 260;
		// smallDocumentA.y = 34;
		smallDocumentA.y = 160;
		smallDocumentA.onDown.callback = function(){
			if(isPrinting || documentPrinting.alpha != 0) {
				return;
			}
			viewDocument("assets/images/document-1.png", function(){});
		};

		smallDocumentAM = new FlxButton();
		smallDocumentAM.loadGraphic("assets/images/document-a-modified.png");
		add(smallDocumentAM);
		smallDocumentAM.x = 260;
		// smallDocumentAM.y = 34;
		smallDocumentAM.y = 160;
		smallDocumentAM.onDown.callback = function(){
			if(isPrinting || documentPrinting.alpha != 0) {
				return;
			}
			viewDocument("assets/images/document-1.png", function(){});
		};

		// 
		smallDocumentB = new FlxButton();
		smallDocumentB.loadGraphic("assets/images/document-b.png");
		add(smallDocumentB);
		smallDocumentB.x = 133;
		// smallDocumentB.y = 28;
		smallDocumentB.y = 160;
		smallDocumentB.onDown.callback = function(){
			if(isPrinting || documentPrinting.alpha != 0) {
				return;
			}
			viewDocument("assets/images/document-2.png", function(){});
		};
		// 
		smallDocumentC = new FlxButton();
		smallDocumentC.loadGraphic("assets/images/document-c.png");
		add(smallDocumentC);
		smallDocumentC.x = 0;
		// smallDocumentC.y = 37;
		smallDocumentC.y = 160;
		smallDocumentC.onDown.callback = function(){
			if(isPrinting || documentPrinting.alpha != 0) {
				return;
			}
			viewDocument("assets/images/document-3.png", function(){});
		};




		// Document viewing mask
		documentMask = new FlxSprite();
		documentMask.makeGraphic(1080, 160, 0xff000000);
		documentMask.alpha = 0.3;

		// Document large one
		documentLarge = new FlxButton();
		documentLarge.onDown.callback = documentLargeDrag;
		documentLarge.onUp.callback = documentLargeDrop;
		documentLarge.onOut.callback = documentLargeDrop;


	}

	private var leftPressTimer:Timer;
	public function leftButtonPress():Void {
		if(isDocumentMode) {
			return;
		}
		buttonLeft.loadGraphic(leftButtonDownImage);
		if(logic.state.answerMode == "both") {
			logic.machine("left-button");
		} else {
			leftPressTimer = Timer.delay(function(){
				logic.machine("right-button-from-left");
			}, 700);
		}
	}
	public function leftButtonEnd():Void {
		buttonLeft.loadGraphic(leftButtonUpImage);
		if(leftPressTimer != null) {
			logic.machine("left-button");
			leftPressTimer.stop();
			leftPressTimer = null;
		}
	}
	public function rightButtonPress():Void {
		if(isDocumentMode) {
			return;
		}
		logic.machine("right-button");
		buttonRight.loadGraphic(rightButtonDownImage);
	}
	public function rightButtonEnd():Void {
		buttonRight.loadGraphic(rightButtonUpImage);
	}

	private var isDocumentMode = false;
	private var preState: GameState;
	private var wallDocuments: GameState;
	override public function update():Void
	{
		super.update();
		if(!isDocumentMode) {
			logic.update(FlxG.elapsed);
		}

		var beginDay = logic.state.beginDay;
		if(logic.state.screenAddtion != "broken") {
			console.updateText(
					new Date(beginDay.getFullYear(), beginDay.getMonth(), beginDay.getDate() + logic.state.day, 12, 33, 23),
					logic.state.message,
					logic.state.motto,
					logic.state.kpi
				);
		}

		// Process the light and halo
		if(preState.lightState != logic.state.lightState) {
			preState.lightState = logic.state.lightState;
			switch(logic.state.lightState) {
				case "off":
					light.loadGraphic("assets/images/light.png");
					lightHalo.alpha = 0;
				case "green":
					light.loadGraphic("assets/images/light-green.png");
					lightHalo.alpha = 0.7;
					lightHalo.loadGraphic("assets/images/light-halo-green.png");
				case "red":
					light.loadGraphic("assets/images/light-red.png");
					lightHalo.alpha = 1;
					lightHalo.loadGraphic("assets/images/light-halo-red.png");
			}
		}

		// Console and save game
		if(logic.state.dayEnded && !preState.dayEnded) {
			preState.dayEnded = true;
			if(logic.state.screenAddtion != "broken") {
				console.close();
			}
			ConsistData.getData().data.save = logic.makeSavable();
		}

		// Should print documentA
		if((logic.state.documentA != preState.documentA && logic.state.documentA != "modified")) {
			preState.documentA = logic.state.documentA;
			printDocument("assets/images/document-printing-1.png", "assets/images/document-1.png", function(){
				wallDocuments.documentA = logic.state.documentA;
				trace("Called back 1" + wallDocuments.documentA);
			});
		}
		if(logic.state.documentA == "modified") {
			preState.documentA = wallDocuments.documentA = logic.state.documentA;
		}
		//B
		if((logic.state.documentB != preState.documentB)) {
			preState.documentB = logic.state.documentB;
			printDocument("assets/images/document-printing-2.png", "assets/images/document-2.png", function(){
				trace("Called back 2");
				wallDocuments.documentB = logic.state.documentB;
				wallDocuments.documentB = logic.state.documentB;
			});
		}
		//C
		if((logic.state.documentC != preState.documentC)) {
			preState.documentC = logic.state.documentC;
			printDocument("assets/images/document-printing-3.png", "assets/images/document-3.png", function(){
				trace("Called back 3");
				wallDocuments.documentC = logic.state.documentC;
				preState.documentC = logic.state.documentC;
			});
		}

		if(isPrinting) {
			printingUpdateShadowAndDocument(documentPrinting.y + FlxG.elapsed * printingSpeed);
		}
		if(isDocumentLargeDragging) {
			documentLarge.y = documentLargeDraggingStartDocumentY + (FlxG.mouse.y - documentLargeDraggingStartY);
			if(documentLarge.y > 20) {
				documentLarge.y = 20;
			}
			if(documentLarge.y + documentLarge.height < 140) {
				documentLarge.y = -( documentLarge.height - 140);
			}
		}

		if(isViewingDocumentLarge) {
			if (FlxG.mouse.justPressed && (FlxG.mouse.x < 350 || FlxG.mouse.x > 730)) {
				if(isDocumentLargeDragging) {
					documentLargeDrop();
				}
				remove(documentMask);
				isViewingDocumentLarge = false;
				remove(documentLarge);
				isDocumentMode = false;
				printingEndCallback();
				printingEndCallback = function(){};
			}
		}

		// Switch smalldocs
		switch (wallDocuments.documentA) {
		case "printed":
			if(smallDocumentA.y == 160) {
				smallDocumentA.y = 34;
			}
		case "modified":
			if(smallDocumentA.y != 160) {
				smallDocumentA.y = 160;
			}
			if(smallDocumentAM.y == 160) {
				smallDocumentAM.y = 34;
			}
		}

		if(wallDocuments.documentB == "printed" && smallDocumentB.y == 160) {
			smallDocumentB.y = 28;
		}

		if(wallDocuments.documentC == "printed" && smallDocumentC.y == 160) {
			smallDocumentC.y = 37;
		}
	}

	private var isPrinting = false;
	private var printingSpeed = 40;
	private function printingUpdateShadowAndDocument(Target: Float) {
		documentPrinting.y  = Target;
		var heightShouldBe = Std.int(Target - (-documentPrinting.height - 20));
		if (heightShouldBe < 5) {
			heightShouldBe = 5;
		}
		documentPrintingShadowFore.makeGraphic(160, heightShouldBe, 0xff000000);
		FlxSpriteUtil.alphaMaskFlxSprite(documentPrintingShadowFore, documentPrintingShadowMask, documentPrintingShadow);
		if (documentPrinting.y + documentPrinting.height >= 130) {
			endPrinting();
		}
	}
	var printingEndCallback:Void -> Void;
	private function printDocument(SmallImage, LargeImage, Callback: Void -> Void):Void {
		trace("Start print" + SmallImage);
		isDocumentMode = true;
		documentPrinting.alpha = 1;
		documentPrintingShadow.alpha = 1;
		isPrinting = true;
		documentPrinting.loadGraphic(SmallImage);
		documentPrinting.y = -documentPrinting.height - 20;
		documentPrintingShadowFore.makeGraphic(160, 5, 0xff000000);
		printingSpeed = 40;
		haxe.Timer.delay(function() {
			printingSpeed = 10;
		}, 1200);
		haxe.Timer.delay(function() {
			printingSpeed = 40;
		}, 1800);
		haxe.Timer.delay(function() {
			printingSpeed = 20;
		}, 2200);
		haxe.Timer.delay(function() {
			printingSpeed = 40;
		}, 2400);

		haxe.Timer.delay(function() {
			printingSpeed = 10;
		}, 2600);

		haxe.Timer.delay(function() {
			printingSpeed = 20;
		}, 3200);
		haxe.Timer.delay(function() {
			printingSpeed = 40;
		}, 4300);

		haxe.Timer.delay(function() {
			printingSpeed = 10;
		}, 5100);

		haxe.Timer.delay(function() {
			printingSpeed = 20;
		}, 5400);

		printingEndCallback = function() {
			viewDocument(LargeImage, Callback);
		}
	}

	private function endPrinting():Void {
		if(isPrinting) {
			isPrinting = false;
			printingUpdateShadowAndDocument(130 - documentPrinting.height);
		}
	}

	private function printingDocumentClicked():Void {
		endPrinting();
		printingEndCallback();
		documentPrinting.alpha = 0;
		documentPrintingShadow.alpha = 0;
		printingUpdateShadowAndDocument(-1000);
	}

	private var isViewingDocumentLarge = false;
	private function viewDocument(LargeImage, Callback: Void -> Void):Void {
		if(isViewingDocumentLarge) {
			return;
		}
		printingEndCallback = Callback;
		add(documentMask);
		documentLarge.loadGraphic(LargeImage);
		add(documentLarge);
		documentLarge.x = 540 - documentLarge.width / 2;
		documentLarge.y = 20;
		isDocumentMode = true;
		haxe.Timer.delay(function() {
			isViewingDocumentLarge = true;
		}, 200);
	}

	private var isDocumentLargeDragging = false;
	private var documentLargeDraggingStartY = 0.0;
	private var documentLargeDraggingStartDocumentY = 0.0;
	private function documentLargeDrag():Void {
		isDocumentLargeDragging = true;
		documentLargeDraggingStartDocumentY = documentLarge.y;
		documentLargeDraggingStartY = FlxG.mouse.y;
	}
	private function documentLargeDrop():Void {
		isDocumentLargeDragging = false;
	}



}