import Main;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxStringUtil;
import haxe.ds.StringMap;
import openfl.text.TextFormat;
import flixel.FlxBasic;
import lime.app.Application;
import lime.graphics.Image;
import openfl.Lib;

// you can configure these below

var settings:StringMap = [
	"font" => "comic.ttf", // if you want the regular vcr font, just replace "comic.ttf" with "vcr.ttf"
	"fontScale" => 1, // only use this if your font is too small
	"windowTabChange" => false, // pretty self-explanatory
];

var credits:StringMap = [
	// add your mod songs below! i, tehpuertoricanspartan, left an example. you can remove it if you want. if you have problems with the map, take a hint from the song name to the left
	"street-sights" => "someone come get tprs' wife back to his place, she MAD",
];

// don't touch ANY of the shit below unless you know what you're doing

var iconProp1:FlxSprite;
var iconProp2:FlxSprite;

var kadeEngineWatermark:FlxText;
var creditsWatermark:FlxText;

var oldWindowName:String;

var ogIconSize:Array<Array<Int>> = [];
function onCreatePost() {
	if (settings.get("font") == "comic.ttf")
		Main.fpsVar.defaultTextFormat = new TextFormat(Paths.font('comic.ttf'), 15, 0xFFFFFF, true);
	else
		Main.fpsVar.defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFF, false);

	if (settings.get("windowTabChange")) {
		oldWindowName = Application.current.window.name;
    	Application.current.window.setIcon(Image.fromFile(Paths.modFolders('images/windowIcons/dave.png'))); // thx to drawoon for the og icon code!
		Lib.application.window.title = "Friday Night Funkin' | VS. Dave and Bambi v3.0b";
	}
	
	game.showCombo = true;

	iconProp1 = new FlxSprite().makeGraphic(game.iconP1._frame.frame.width, game.iconP1._frame.frame.height, 0xFF000000);
	ogIconSize.push([game.iconP1._frame.frame.width, game.iconP1._frame.frame.height]);
	iconProp2 = new FlxSprite().makeGraphic(game.iconP2._frame.frame.width, game.iconP2._frame.frame.height, 0xFF000000);
	ogIconSize.push([game.iconP2._frame.frame.width, game.iconP2._frame.frame.height]);

	game.healthBar.y = (ClientPrefs.data.downScroll ? 50 : FlxG.height * 0.9);
	game.timeBar.y = (ClientPrefs.data.downScroll ? (FlxG.height * 0.9) + 20 : 30);
	game.iconP1.y = game.healthBar.y - (game.iconP1.height / 2);
	game.iconP2.y = game.healthBar.y - (game.iconP2.height / 2);

	var bars:Array<Dynamic> = [game.healthBar, game.timeBar];
	for (i in bars) {
		i.set_barWidth(i.bg.width - 8);
		i.set_barHeight(i.bg.height - 8);
		i.barOffset.set(4, 4);
		i.screenCenter(1);
	}

	var xValues = getMinAndMax(game.timeTxt.width, game.timeBar.width);
	var yValues = getMinAndMax(game.timeTxt.height, game.timeBar.height);
	game.timeTxt.x = game.timeBar.x - ((xValues[0] - xValues[1]) / 2);
	game.timeTxt.y = game.timeBar.y + ((yValues[0] - yValues[1]));
	game.timeTxt.setFormat(Paths.font(settings.get("font")), 32 * settings.get("fontScale"), 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	game.timeTxt.borderSize = 2.5 * settings.get("fontScale");
	game.timeBar.leftBar.color = 0xFF37FF14;
	game.timeBar.rightBar.color = 0xFF808080;

	game.scoreTxt.y = game.healthBar.y + 40;
	game.scoreTxt.setFormat(Paths.font(settings.get("font")), 20 * settings.get("fontScale"), 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	game.scoreTxt.borderSize = 1.5 * settings.get("fontScale");

	game.botplayTxt.y = game.healthBar.bg.y + (ClientPrefs.data.downScroll ? 100 : -100);
	game.botplayTxt.setFormat(Paths.font(settings.get("font")), 42 * settings.get("fontScale"), 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	game.botplayTxt.borderSize = 2.5 * settings.get("fontScale");

	var songName = PlayState.SONG.song;
	kadeEngineWatermark = new FlxText(4, game.healthBar.bg.y + (credits.get(songName) != null ? 30 : 50), 0, songName);
	kadeEngineWatermark.setFormat(Paths.font(settings.get("font")), 16 * settings.get("fontScale"), 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	kadeEngineWatermark.borderSize = 1.25 * settings.get("fontScale");
	kadeEngineWatermark.camera = game.camHUD;
	add(kadeEngineWatermark);

	if (credits.get(songName) != null) {
		creditsWatermark = new FlxText(4, game.healthBar.bg.y + 50, 0, credits.get(songName));
		creditsWatermark.setFormat(Paths.font(settings.get("font")), 16 * settings.get("fontScale"), 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		creditsWatermark.borderSize = 1.25 * settings.get("fontScale");
		creditsWatermark.camera = game.camHUD;
		add(creditsWatermark);
	}

	setObjectOrder(game.scoreTxt, game.members.indexOf(game.iconP1) - 1);
}

function onCountdownStarted() {
	for (i in game.strumLineNotes) {
		i.x += 5.5;
		if (ClientPrefs.data.downScroll)
			i.y = FlxG.height - 165;
	}
	for (j in 0...game.playerStrums.length) {
		game.setOnLuas('defaultPlayerStrumX' + j, game.playerStrums.members[j].x);
		game.setOnLuas('defaultPlayerStrumY' + j, game.playerStrums.members[j].y);
	}
	for (j in 0...game.opponentStrums.length) {
		game.setOnLuas('defaultOpponentStrumX' + j, game.opponentStrums.members[j].x);
		game.setOnLuas('defaultOpponentStrumY' + j, game.opponentStrums.members[j].y);
	}
}

function onUpdatePost() {
	var thingy = 0.88;
	iconProp1.setGraphicSize(Std.int(FlxMath.lerp(ogIconSize[0][0], iconProp1.width, thingy)), Std.int(FlxMath.lerp(ogIconSize[0][1], iconProp1.height, thingy)));
	iconProp1.updateHitbox();
	iconProp2.setGraphicSize(Std.int(FlxMath.lerp(ogIconSize[1][0], iconProp2.width, thingy)), Std.int(FlxMath.lerp(ogIconSize[1][1], iconProp2.height, thingy)));
	iconProp2.updateHitbox();

	var iconOffset = 26;
	game.iconP1.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
	game.iconP2.x = game.healthBar.x
		+ (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01))
		- (game.iconP2.width - iconOffset);

	game.iconP1.scale.set(iconProp1.width / 150, iconProp1.height / 150);
	game.iconP2.scale.set(iconProp2.width / 150, iconProp2.height / 150);

	game.iconP1.origin.set(0, 0);
	game.iconP2.origin.set(0, 0);

	game.scoreTxt.text = 'Score:' + game.songScore + ' | Misses:' + game.songMisses + ' | Accuracy:' + truncateFloat(game.ratingPercent * 100, 2) + '%';
	if (game.camZooming) {
		game.camGame.zoom = FlxMath.lerp(game.defaultCamZoom, game.camGame.zoom, 0.95);
		game.camHUD.zoom = FlxMath.lerp(1, game.camHUD.zoom, 0.95);
	}

	game.grpNoteSplashes.visible = false;
}

function onBeatHit() {
	var funny = Math.max(Math.min(game.health, 1.9), 0.1);
	iconProp1.setGraphicSize(Std.int(iconProp1.width + (50 * (funny + 0.1))), Std.int(iconProp1.height - (25 * funny)));
	iconProp1.updateHitbox();
	iconProp2.setGraphicSize(Std.int(iconProp2.width + (50 * ((2 - funny) + 0.1))), Std.int(iconProp2.height - (25 * (2 - funny))));
	iconProp2.updateHitbox();
}

function goodNoteHit() { // thx gabi!
	for (i in game.members)
		if (i != null && Std.isOfType(i, FlxSprite) && i.exists && i.velocity.y != 0 && i.acceleration.y != 0) {
			i.camera = game.camGame;
			i.x -= ClientPrefs.data.comboOffset[0];
			i.y += ClientPrefs.data.comboOffset[1];
		}
}

function onEvent(n:String, v1:String) {
	if (n == 'Change Character')
		reloadIcons(v1);
}

function onDestroy() {
	Main.fpsVar.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF, false);
	if (settings.get("windowTabChange")) {
		Application.current.window.setIcon(Image.fromFile(Paths.modFolders('images/windowIcons/icon16.png')));
		Lib.application.window.title = "Friday Night Funkin': Psych Engine";
	}
}

// functions

function truncateFloat(number:Float, precision:Int):Float {
	var num = number;
	num = num * Math.pow(10, precision);
	num = Math.round(num) / Math.pow(10, precision);
	return num;
}

function reloadIcons(char:String) {
	if (char.toLowerCase() == 'dad' || char.toLowerCase() == 'opponent' || char == '0') {
		ogIconSize.shift();
		ogIconSize.insert(0, [game.iconP2._frame.frame.width, game.iconP2._frame.frame.height]);
	} else {
		ogIconSize.pop();
		ogIconSize.push([game.iconP1._frame.frame.width, game.iconP1._frame.frame.height]);
	}
}

function setObjectOrder(obj:FlxBasic, position:Int) {
	remove(obj);
	insert(position, obj);
}

function getMinAndMax(value1:Float, value2:Float):Array<Float>
{
	var minAndMaxs:Array<Float> = [];

	var min = Math.min(value1, value2);
	var max = Math.max(value1, value2);

	minAndMaxs.push(min);
	minAndMaxs.push(max);

	return minAndMaxs;
}