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
import flixel.system.FlxSound;
import flixel.util.FlxCollision;
import flixel.tweens.FlxTween;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxSort;

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

	private var tickSound: FlxSound;
	private var printingSound: FlxSound;

	private var receiptPrinting: FlxButton;
	private var receipt: FlxSprite;

	override public function create():Void
	{
		super.create();

		// if(ConsistData.getData().data.save == null) {
		if(true) {
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
		// buttonLeft.onDown.callback = leftButtonPress;
		buttonLeft.onUp.callback = leftButtonEnd;
		buttonLeft.onOut.callback = leftButtonEnd;

		buttonRight = new FlxButton(0, 0, "");
		buttonRight.loadGraphic(rightButtonUpImage);
		add(buttonRight);
		buttonRight.x = 568;
		buttonRight.y = 84;
		// buttonRight.onDown.callback = rightButtonPress;
		buttonRight.onUp.callback = rightButtonEnd;
		buttonRight.onOut.callback = rightButtonEnd;

		receiptPrinting = new FlxButton(0, 0, "");
		receiptPrinting.loadGraphic("assets/images/receipt-printing.png");
		add(receiptPrinting);
		receiptPrinting.x = 860;
		receiptPrinting.y = -receiptPrinting.height;

		var receiptGroup: FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

		receipt = new FlxButton(0, 0, "");
		receipt.loadGraphic("assets/images/receipt.png");
		receipt.x = 800;
		receipt.y = 10;
		var textDate = new FlxText();
		textDate.setFormat("assets/fonts/GOTHIC.TTF", 8, 0xff000000);
		textDate.x = 827;
		textDate.y = 50;
		receiptGroup.add(textDate);
		var textKpi = new FlxText();
		textKpi.setFormat("assets/fonts/GOTHIC.TTF", 8, 0x444444);
		textKpi.x = 890;
		textKpi.y = 90;
		receiptGroup.add(textKpi);
		var textIncome = new FlxText();
		textIncome.setFormat("assets/fonts/GOTHIC.TTF", 8, 0x444444);
		textIncome.x = 890;
		textIncome.y = 103;
		receiptGroup.add(textIncome);
		var textBalance = new FlxText();
		textBalance.setFormat("assets/fonts/GOTHIC.TTF", 8, 0x444444);
		textBalance.x = 890;
		textBalance.y = 116;
		receiptGroup.add(textBalance);
		receiptGroup.add(receipt);

		receiptPrinting.onDown.callback = function(){
			var beginDay = logic.state.beginDay;
			textDate.text = MiniConsole.getStrDate(new Date(beginDay.getFullYear(), beginDay.getMonth(), beginDay.getDate() + logic.state.day, 12, 33, 23));

			textKpi.text = MiniConsole.floatToStr(logic.state.kpi);

			textIncome.text = MiniConsole.floatToStr(ConsistData.getData().data.save.balance - preState.balance);
			textBalance.text = MiniConsole.floatToStr(ConsistData.getData().data.save.balance);

			remove(receiptPrinting);
			receiptGroup.sort(FlxSort.byY, FlxSort.ASCENDING);
			add(receiptGroup);
		};


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
			if(isViewingDocumentLarge || isPrinting || documentPrinting.alpha != 0) {
				return;
			}
			FlxG.sound.play("assets/sounds/paper-flip.wav", 1);
			if(logic.state.documentA == "modified") {
				viewDocument("assets/images/document-1-modified.png", function(){});
			} else {
				viewDocument("assets/images/document-1.png", function(){});
			}
		};

		smallDocumentAM = new FlxButton();
		smallDocumentAM.loadGraphic("assets/images/document-a-modified.png");
		add(smallDocumentAM);
		smallDocumentAM.x = 260;
		// smallDocumentAM.y = 34;
		smallDocumentAM.y = 160;
		smallDocumentAM.onDown.callback = function(){
			if(isViewingDocumentLarge || isPrinting || documentPrinting.alpha != 0) {
				return;
				}
			FlxG.sound.play("assets/sounds/paper-flip.wav", 1);
			viewDocument("assets/images/document-1-modified.png", function(){});
		};

		// 
		smallDocumentB = new FlxButton();
		smallDocumentB.loadGraphic("assets/images/document-b.png");
		add(smallDocumentB);
		smallDocumentB.x = 133;
		// smallDocumentB.y = 28;
		smallDocumentB.y = 160;
		smallDocumentB.onDown.callback = function(){
			if(isViewingDocumentLarge || isPrinting || documentPrinting.alpha != 0) {
				return;
			}
			FlxG.sound.play("assets/sounds/paper-flip.wav", 1);
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


		// Sound
		FlxG.sound.play("assets/sounds/ambient-humming.wav", 1, true);

		logic.winCallback = function(){
			FlxG.sound.play("assets/sounds/success.wav", 1);
		}
		logic.loseCallback = function(){
			FlxG.sound.play("assets/sounds/lose.wav", 1);
		}
		logic.beginWorkCallback = function(){
			tickSound = FlxG.sound.play("assets/sounds/clock-tick.wav", 1, true);
			console.open();
		}

	}

	private var leftPressTimer:Timer;
	private var leftPressing = false;
	public function leftButtonPress():Void {
		if(isDocumentMode) {
			return;
		}
		leftPressing = true;
		buttonLeft.loadGraphic(leftButtonDownImage);
		FlxG.sound.play("assets/sounds/button-down.wav", 1);
		if(logic.state.answerMode == "both") {
			logic.machine("left-button");
		} else {
			leftPressTimer = Timer.delay(function(){
				logic.machine("right-button-from-left");
			}, 700);
		}
	}
	public function leftButtonEnd():Void {
		if(!leftPressing) {
			return;
		}
		leftPressing = false;
		FlxG.sound.play("assets/sounds/button-up.wav", 1);
		buttonLeft.loadGraphic(leftButtonUpImage);
		if(leftPressTimer != null) {
			logic.machine("left-button");
			leftPressTimer.stop();
			leftPressTimer = null;
		}
	}
	private var rightPressing = false;
	public function rightButtonPress():Void {
		if(isDocumentMode) {
			return;
		}
		rightPressing = true;
		logic.machine("right-button");
		FlxG.sound.play("assets/sounds/button-down.wav", 1);
		buttonRight.loadGraphic(rightButtonDownImage);
	}
	public function rightButtonEnd():Void {
		if(!rightPressing) {
			return;
		}
		rightPressing = false;
		FlxG.sound.play("assets/sounds/button-up.wav", 1);
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
			if(tickSound != null) {
				tickSound.pause();
				FlxG.sound.play("assets/sounds/day-off.wav", 1);
				if(logic.state.storyLevel != 10) {
					FlxTween.tween(receiptPrinting, {y:-12 }, 0.8);
				}
			}
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

		// Mouse clicks
		if(FlxG.mouse.justPressed) {
			if(FlxCollision.pixelPerfectPointCheck(Std.int(FlxG.mouse.x), Std.int(FlxG.mouse.y), buttonLeft)) {
				leftButtonPress();
			}
			if(FlxCollision.pixelPerfectPointCheck(Std.int(FlxG.mouse.x), Std.int(FlxG.mouse.y), buttonRight)) {
				rightButtonPress();
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

		printingSound = FlxG.sound.play("assets/sounds/printing.wav", 0.3);
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
		if(printingSound != null) {
			printingSound.pause();
		}
		FlxG.sound.play("assets/sounds/paper-flip.wav", 1);
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