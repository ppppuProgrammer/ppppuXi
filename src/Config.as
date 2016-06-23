package  
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import avmplus.DescribeTypeJSON;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	/**
	 * Class for the key input configuration menus of ppppu interactive/NX
	 * @author 
	 */
	public class Config extends Sprite
	{
		
		//private var m_parent:MovieClip;
		public const m_width:Number=480;
		public const m_height:Number = 680;
		private var buttonAwaitingKeyInput:PushButton=null;
		private var userSettings:UserSettings;
		private var p_config:Panel;
		private const UNASSIGNED_TEXT:String = "Unassigned";
		//Dictionary that maps keycodes to their associated names. Original code can be found at http://stackoverflow.com/a/19739892 
		public static var keyDict:Dictionary;
		private var keyFunctionsList:Vector.<String> = new < String > ["LockChar", "GotoChar", "AutoCharSwitch", "RandomChar", "CharCursorPrev", "CharCursorNext", "PrevAnimPage", "NextAnimPage", "AnimLockMode", "Menu", "Help", "NextHelpPage",
		"Backlight", "Background", "DisplayLimit", "Music", "CharTheme", "PrevMusic", "NextMusic", "MusicForAll", "Activate"];
		
		private var warningText:Label;
		
		public function Config(/*parentMC:MovieClip,*/ settings:UserSettings) 
		{
			//m_parent = parentMC;
			userSettings = settings;
			keyDict = GetKeyboardDict();
			InitMenu();
		}
		
		private function InitMenu():void
		{
			p_config = new Panel();
			addChild(p_config);
			p_config.setSize(m_width, m_height);
			p_config.addEventListener(MouseEvent.CLICK, PanelClickHandler,true);
			var posY_multiplier:int = 3;
			
			var labelsPosX:Number = 5;
			
			//Labels
			var l_description:Label = new Label(p_config, m_width / 4, posY_multiplier * 0, "key configuration");
			var txtFormat:TextFormat = l_description.textField.getTextFormat();
			txtFormat.size = 24;
			txtFormat.font = "Super Mario 256";
			l_description.textField.setTextFormat(txtFormat);
			l_description.setSize(100, 20);
			var l_description2:Label = new Label(p_config, 0, posY_multiplier * 10, "Click a box to change the key for a function. Press Escape to clear a key.");
			l_description2.x = (m_width - l_description2.width) / 2;
			//Character
			var l_lockChar:Label = new Label(p_config, labelsPosX, posY_multiplier*20, "Lock selected character");
			var l_switchChar:Label = new Label(p_config, labelsPosX, posY_multiplier*30, "Switch to selected character");
			new Label(p_config, labelsPosX, posY_multiplier*40, "Automatic character switch toggle");
			new Label(p_config, labelsPosX, posY_multiplier*50, "Random character select toggle");
			new Label(p_config, labelsPosX, posY_multiplier*60, "Character cursor up");
			new Label(p_config, labelsPosX, posY_multiplier*70, "Character cursor down");
			//Animation
			new Label(p_config, labelsPosX, posY_multiplier*80, "Previous animation page");
			new Label(p_config, labelsPosX, posY_multiplier*90, "Next animation page");
			new Label(p_config, labelsPosX, posY_multiplier*100, "Animation menu switch/lock mode toggle");
			//Misc
			new Label(p_config, labelsPosX, posY_multiplier*110, "Show/hide menus");
			new Label(p_config, labelsPosX, posY_multiplier*120, "Show/hide help");
			new Label(p_config, labelsPosX, posY_multiplier*130, "Change help page");
			new Label(p_config, labelsPosX, posY_multiplier*140, "Backlight ON/OFF");
			new Label(p_config, labelsPosX, posY_multiplier*150, "Background ON/OFF");
			new Label(p_config, labelsPosX, posY_multiplier*160, "Display limit toggle");
			new Label(p_config, labelsPosX, posY_multiplier*170, "Music ON/OFF");
			new Label(p_config, labelsPosX, posY_multiplier*180, "Use character's default theme");
			new Label(p_config, labelsPosX, posY_multiplier*190, "Change to previous music");
			new Label(p_config, labelsPosX, posY_multiplier*200, "Change to next music");
			new Label(p_config, labelsPosX, (posY_multiplier * 210), "Toggle same music for all characters mode");
			new Label(p_config, labelsPosX, (posY_multiplier * 220), "Activate scene transition if available");
			
			warningText = new Label(p_config, 40, m_height - 20, "");
			var warningTxtFormat:TextFormat = warningText.textField.getTextFormat();
			warningText.textField.textColor = 0xFF0000;
			warningTxtFormat.size = 14;
			warningText.textField.setTextFormat(warningTxtFormat);
			
			CreateButtons(p_config, keyFunctionsList);
			
			//Exit button
			var exitButton:PushButton = new PushButton(p_config, m_width - 32, 0, "X", CloseHandler);
			exitButton.setSize(32, 32);
		}
		
		private function CreateButtons(panel:Panel, functionsList:Vector.<String>):void
		{
			var startX:Number = 200; var startY:Number = 55;
			var xPosIncrement:int = 140; var yPosIncrement:int = 30;
			var button:PushButton;
			var buttonText:String;
			var keySetType:String;
			for (var currentSet:int = 0, totalSets:int = 2; currentSet < totalSets; ++currentSet )
			{
				if (currentSet == 0)	{keySetType = "main";}
				else { keySetType = "alt"; }
				
				for (var i:int = 0, l:int = functionsList.length; i < l;++i)
				{
					buttonText = KeyCodeToString(userSettings.keyBindings[functionsList[i]][keySetType]);
					button = new PushButton(panel, startX + (currentSet * xPosIncrement), startY + (i * yPosIncrement), buttonText, ButtonClickHandler);
					button.name = functionsList[i] + "_" + keySetType;
					button.setSize(110, 30);
				}
			}
		}
		public function CloseHandler(e:MouseEvent):void
		{
			var keybinds:Object = userSettings.keyBindings;
			for (var i:int = 0, l:int = keyFunctionsList.length; i < l;++i)
			{
				if (keybinds[keyFunctionsList[i]].main == -1 && keybinds[keyFunctionsList[i]].alt == -1)
				{
					if (warningText.text.length == 0)
					{
						warningText.text = "Warning: Config can not be closed until all functions have at least 1 key bound.";
						var warningTimer:Timer = new Timer(5000, 1);
						warningTimer.start();
						warningTimer.addEventListener(TimerEvent.TIMER_COMPLETE, RemoveWarning);
					}
					return;
				}
			}
			p_config.removeEventListener(MouseEvent.CLICK, PanelClickHandler);
			/*Changes the focus from the exit button. This is done because if the exit button has the stage's focus when the ppppuConfig instance
			removes itself from its parent, the stage completely loses focus and requires the user to click anywhere to regain focus.*/
			stage.focus = this;
			//this.parent.getChildByName("HelpLayer").visible = true;
			dispatchEvent(new SaveRequestEvent(SaveRequestEvent.SAVE_SHARED_OBJECT));
			this.parent.removeChild(this);
			
		}
		
		public function RemoveWarning(e:TimerEvent):void
		{
			var target:Timer = (e.target as Timer);
			target.removeEventListener(TimerEvent.TIMER_COMPLETE, RemoveWarning);
			warningText.text = "";
		}
		
		public function ButtonClickHandler(e:MouseEvent):void
		{
			if (buttonAwaitingKeyInput == null)
			{
				buttonAwaitingKeyInput = (e.target as PushButton);
				buttonAwaitingKeyInput.addEventListener(KeyboardEvent.KEY_DOWN, KeyInputHandler);
				buttonAwaitingKeyInput.label = "Hit a key to set";
			}
		}
		
		public function PanelClickHandler(e:MouseEvent):void
		{
			if (buttonAwaitingKeyInput)
			{
				buttonAwaitingKeyInput.removeEventListener(KeyboardEvent.KEY_DOWN, KeyInputHandler);
				//Change button text back to the key still set for it.
				var buttonName:String = buttonAwaitingKeyInput.name;
				var keyFunction:String = buttonName.substring(0, buttonName.indexOf("_"));
				var keyType:String = buttonName.substring(buttonName.indexOf("_")+1);
				buttonAwaitingKeyInput.label = KeyCodeToString(userSettings.keyBindings[keyFunction][keyType]);
				buttonAwaitingKeyInput = null;
			}
		}
		
		public function KeyInputHandler(e:KeyboardEvent):void
		{
			var keyPressed:int = e.keyCode;
			if ((keyPressed == 48 || keyPressed == 96) || (!(49 > keyPressed) && !(keyPressed > 57)) ||  (!(97 > keyPressed) && !(keyPressed > 105)))
			{
				//0-9 are reserved for the animation menu
				return;
			}
			var target:PushButton = (e.target as PushButton);
			var buttonName:String = target.name;
			var keyFunction:String = buttonName.substring(0, buttonName.indexOf("_"));
			var keyType:String = buttonName.substring(buttonName.indexOf("_") + 1);
			
			if (keyPressed == Keyboard.ESCAPE)
			{
				//Escape means to clear the key for the function
				userSettings.keyBindings[keyFunction][keyType] = -1;
				target.label = KeyCodeToString(-1);
			}
			else
			{
				CheckKeyForDuplicates(keyPressed);
				userSettings.keyBindings[keyFunction][keyType] = keyPressed;
				target.label = KeyCodeToString(keyPressed);
			}
		}
		
		//Looks through the key bindings to see if a key is already used and if so, remove it.
		private function CheckKeyForDuplicates(keycode:uint):void
		{
			var keybinds:Object = userSettings.keyBindings;
			var button:PushButton;
			for (var i:int = 0, l:int = keyFunctionsList.length; i < l;++i)
			{
				if (keybinds[keyFunctionsList[i]].main == keycode)
				{
					keybinds[keyFunctionsList[i]].main = -1;
					button = (p_config.content.getChildByName(keyFunctionsList[i] + "_main") as PushButton);
					button.label = KeyCodeToString(-1);
					return;
				}
				else if (keybinds[keyFunctionsList[i]].alt == keycode)
				{
					keybinds[keyFunctionsList[i]].alt = -1;
					button = (p_config.content.getChildByName(keyFunctionsList[i] + "_alt") as PushButton);
					button.label = KeyCodeToString(-1);
					return;
				}
			}		
		}
		
		private function KeyCodeToString(keycode:int):String
		{
			var keyName:String = keyDict[keycode];
			if (keyName == null) { keyName = UNASSIGNED_TEXT;}
			return keyName;
		}
		
		private function GetKeyboardDict():Dictionary
		{
			var jsonClassDescriber:DescribeTypeJSON = new DescribeTypeJSON();
			var classDescription:Object = jsonClassDescriber.getClassDescription(Keyboard);
			var keycodeNames:Array = classDescription.traits.variables as Array;
			//var keyDescription:XML = describeTypeJSON(Keyboard);
			//var keyNames:XMLList = keyDescription..constant.@name;

			var keyboardDict:Dictionary = new Dictionary();

			var len:int = keycodeNames.length;
			for (var i:int = 0; i < len; ++i) {
				var keyName:String = keycodeNames[i].name;
				keyboardDict[Keyboard[keyName]] = keyName;
			}

			return keyboardDict;
		}
	}

}