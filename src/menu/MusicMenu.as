package menu 
{
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author 
	 */
	public class MusicMenu extends Panel
	{
		private var nextMusicButton:IconPushButton;
		private var previousMusicButton:IconPushButton;
		private var musicOnOffButton:IconPushButton;
		private var characterPreferredMusicButton:IconPushButton;
		private var musicTitleDisplayer:Label;
		
		public function MusicMenu(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0) 
		{
			name = "Music Menu";
			super(parent, xpos, ypos);
			
			setSize(stage.stageWidth, 30);
			
			characterPreferredMusicButton = new IconPushButton(this, _width-30, 0);
			characterPreferredMusicButton.setSize(30, 30);
			characterPreferredMusicButton.toggle = false;
			characterPreferredMusicButton.unselectedIcon = new CharacterMusicIcon;
			musicOnOffButton = new IconPushButton(this, characterPreferredMusicButton.x - 30, 0);
			musicOnOffButton.setSize(30, 30);
			musicOnOffButton.selectedIcon = new MusicEnabledIcon;
			musicOnOffButton.unselectedIcon = new MusicDisabledIcon;
			
			nextMusicButton = new IconPushButton(this, musicOnOffButton.x - 40, 0);
			nextMusicButton.setSize(30, 30);
			nextMusicButton.toggle = false;
			nextMusicButton.unselectedIcon = new ChangeMusicIcon;
			previousMusicButton = new IconPushButton(this, nextMusicButton.x - 40, 0);
			previousMusicButton.setSize(30, 30);
			previousMusicButton.toggle = false;
			previousMusicButton.unselectedIcon = new ChangePrevMusicIcon;
			
			musicTitleDisplayer = new Label(this, 0, 5, "");
			musicTitleDisplayer.setSize(previousMusicButton.x - 20, 30);
			var musicInfoTxtFormat:TextFormat = new TextFormat();
			musicInfoTxtFormat.font = "Super Mario 256";
			musicInfoTxtFormat.size=18;
			musicInfoTxtFormat.align = TextFormatAlign.CENTER;
			musicInfoTxtFormat.color = 0x000000;
			/*musicInfoText = new TextField();
			musicInfoText.embedFonts = true;
			musicInfoText.antiAliasType = AntiAliasType.ADVANCED;
			musicInfoText.selectable = false;
			musicInfoText.defaultTextFormat = musicInfoTxtFormat;
			musicInfoText.autoSize = TextFieldAutoSize.CENTER;*/
			musicTitleDisplayer.autoSize = false;
			musicTitleDisplayer.textField.defaultTextFormat = musicInfoTxtFormat;
		}
		
		public function ChangeMusicInfoDisplay(displayText:String):void
		{
			musicTitleDisplayer.text = displayText;
			
		}
		
	}

}