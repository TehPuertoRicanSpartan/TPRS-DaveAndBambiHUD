import haxe.ds.StringMap;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.group.FlxTypedSpriteGroup;

var songHeading:StringMap = [
    // add your custom song headings here! legend from left to right is on the side
	"test" => ['daveHeading', false, [false, "animatedName", "animatedPrefix", 1, true, false, false], 0, 'Kawai Sprite', 'credits/kawaisprite'], //image path, antialiasing, [animated, animation name, animation prefix, frames, looped, flip 1?, flip 2?], icon offset, author, author icon path
];

var bg:FlxSprite;
var bgHeading:FlxSprite;

var funnyText:FlxText;
var funnyIcon:FlxSprite;

var creditsPopup:FlxTypedSpriteGroup;

function onCreatePost() {
	var info = (songHeading.get(PlayState.SONG.song.toLowerCase()) == null ? ['daveHeading', false, [false], 0, '???', 'credits/missing_icon'] : songHeading.get(PlayState.SONG.song.toLowerCase()));

	creditsPopup = new FlxTypedSpriteGroup(FlxG.width, 200);

	bg = new FlxSprite().makeGraphic(400, 50, FlxColor.WHITE);
	if (!info[2][0]) {
		bg.loadGraphic(Paths.image('headings/' + info[0]));
	} else {
		var info2 = info[2];
		bg.frames = Paths.getSparrowAtlas('headings/' + info[0]);
		bg.animation.addByPrefix(info2[1], info2[2], info2[3], info2[4], info2[5], info2[6]);
		bg.animation.play(info2[1]);
	}
	bg.antialiasing = (info[1] && ClientPrefs.data.antialiasing);
	creditsPopup.add(bg);

	funnyText = new FlxText(1, 0, 650, "Song by " + info[4], 16);
	funnyText.setFormat(Paths.font(dnbFont), 30, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	funnyText.borderSize = 2;
	funnyText.antialiasing = (info[1] && ClientPrefs.data.antialiasing);
	creditsPopup.add(funnyText);

	funnyIcon = new FlxSprite(0, 0, Paths.image((info[5] != null ? info[5] : "credits/missing_icon")));
	var offset = info[3];
	var scaleValues = getMinAndMax(funnyIcon.height, funnyText.height);
	funnyIcon.setGraphicSize(Std.int(funnyIcon.height / (scaleValues[1] / scaleValues[0])));
	funnyIcon.updateHitbox();
	var heightValues = getMinAndMax(funnyIcon.height, funnyText.height);
	funnyIcon.setPosition(funnyText.textField.textWidth + offset, (heightValues[0] - heightValues[1]) / 2);
	creditsPopup.add(funnyIcon);

	rescaleBG();

	var yValues = getMinAndMax(bg.height, funnyText.height);
	funnyText.y = funnyText.y + ((yValues[0] - yValues[1]) / 2);
}

function onSongStart() {
	creditsPopup.camera = game.camHUD;
	creditsPopup.scrollFactor.set();
	creditsPopup.x = creditsPopup.width * -1;
	game.uiGroup.add(creditsPopup);

	FlxTween.tween(creditsPopup, {x: 0}, 0.5 / game.playbackRate, {ease: FlxEase.backOut, onComplete: function(tweeen:FlxTween)
	{
		FlxTween.tween(creditsPopup, {x: creditsPopup.width * -1} , 1  / game.playbackRate, {ease: FlxEase.backIn, onComplete: function(tween:FlxTween)
		{
			creditsPopup.destroy();
		}, startDelay: 3 / game.playbackRate});
	}});
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

function rescaleBG()
{
	bg.setGraphicSize(Std.int((funnyText.textField.textWidth + funnyIcon.width + 0.5)), Std.int(funnyText.height + 0.5));
	bg.updateHitbox();
}
