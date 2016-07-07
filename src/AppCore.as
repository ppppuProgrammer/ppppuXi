package  
{
	//import Characters.*;
	import com.bit101.components.List;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	import events.AnimationTransitionEvent;
	import events.ExitLinkedAnimationEvent;
	
	import events.ChangeBackgroundEvent;
	import events.SaveRequestEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.net.registerClassAlias;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import CharacterManager;
	import menu.IconList;
	import menu.MainMenu;
	import MenuButton;
	import modifications.*;
	import modifications.Mod;
	import flash.display.Sprite;
	import modifications.AnimatedCharacterMod;
	/**
	 * Responsible for managing all the various aspects of ppppuNX (and interactive). 
	 * @author ppppuProgrammer
	 */
	public class AppCore extends MovieClip
	{
		public var mainStage:MainStage;
		//Keeps track of what keys were pressed and/or held down
		private var keyDownStatus:Array = [];
		//private var characterList:Vector.<Character> = new <Character>[new PeachCharacter/*, new RosalinaCharacter*/];
		//private const defaultCharacter:Character = characterList[0];
		//private const defaultCharacterName:String = defaultCharacter.GetName();
		//private var currentCharacter:Character = defaultCharacter;
		//private var m_useBacklight:Boolean = true;
		//private var m_showBackground:Boolean = true;
		//private var characterNameList:Vector.<String> = new <String>["Peach"/*, "Rosalina"*/];
		//private const defaultCharacter:String = characterNameList[0];
		//private var currentCharacter:String = defaultCharacter;
		//private var currentAnimationIndex:uint = 0;
		private var characterManager:CharacterManager;
		
		private const flashStartFrame:int = 2;
		//Main menu for the program.
		//private var charVoiceSystem:SoundEffectSystem;
		
		private var playSounds:Boolean = false;
		
		private var helpScreenMC:HelpScreen;
		private const HELP_INITIAL_FONT_SIZE:int = 14;
		
		private var displayWidthLimit:int;
		private var mainStageLoopStartFrame:int;
		//For stopping animation
		//private var lastPlayedFrame:int = -1;
		
		//Indicates that the program should be "frozen" while the various other swfs are being loaded .  
		private var startupLoadFreeze:Boolean = true;
		
		//Settings related
		public var settingsSaveFile:SharedObject = SharedObject.getLocal("ppppSuperWiiU_Interactive");
		
		public var userSettings:UserSettings = new UserSettings();
		
		//Loading
		private var contentLoader:LoaderMax = new LoaderMax({name:"Content loader"});
		
		//private var musicPlayer:MusicPlayer = new MusicPlayer();
		private var mainMenu:MainMenu;
		
		//Timing
		private var totalRunFrames:int = 0;
		
		//Music
		private var musicPlayer:MusicPlayer = new MusicPlayer();
		
		private const appName:String = "ppppuXi beta";
		
		//Constructor
		public function AppCore() 
		{
			//Create the "main stage" that holds the character template and various other movieclips such as the transition and backlight 
			mainStage = new MainStage();
			mainStage.stop();
			addChild(mainStage);
			
			contentLoader.autoLoad = true;
			
			mainStage.mouseChildren = false;
			mainStage.mouseEnabled = false;
			
			var frameLabels:Array = mainStage.currentLabels;
			for (var i:int = 0, l:int = frameLabels.length; i < l;++i)
			{
				var label:FrameLabel = frameLabels[i] as FrameLabel;
				if (label.name == "re")
				{
					mainStageLoopStartFrame = label.frame;
				}
			}
			//Touch inputs are to be handled as if they were mouse inputs
			Multitouch.inputMode = MultitouchInputMode.NONE;
			//Add an event listener that'll allow for frame checking.
			mainStage.addEventListener(Event.ENTER_FRAME, RunLoop);
			mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = false;
			addEventListener(events.SaveRequestEvent.SAVE_SHARED_OBJECT, SaveSettingsToDisk);
			//settingsSaveFile.clear();
		}
		
		//Sets up the various aspects of the flash to get it ready for performing.
		public function Initialize(startupMods:Array = null):void
		{
			//var msBounds:Rectangle = mainStage.getBounds(mainStage);
			//var mainStagePlacementX:Number = ((mainStage.stage.stageWidth - msBounds.right));
			//mainStage.x = mainStagePlacementX;
			//Add the key listeners
			stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyPressCheck);
			stage.addEventListener(KeyboardEvent.KEY_UP, KeyReleaseCheck);
			
			addEventListener(ChangeBackgroundEvent.CHANGE_BACKGROUND, ChangeBackgroundColors, true);
			addEventListener(AnimationTransitionEvent.ANIMATION_TRANSITIONED, AnimationTransitionOccured, true);
			mainStage.MenuLayer.mouseEnabled = true;
			//Disable mouse interaction for various objects
			mainStage.mouseEnabled = false;
			mainStage.CharacterLayer.mouseEnabled = false;
			mainStage.CharacterLayer.mouseChildren = false;
			mainStage.HelpLayer.mouseEnabled = false;
			mainStage.HelpLayer.mouseChildren = false;
			mainStage.BacklightBG.mouseEnabled = false;
			mainStage.BacklightBG.mouseChildren = false;
			mainStage.InnerDiamondBG.mouseEnabled = false;
			mainStage.InnerDiamondBG.mouseChildren = false;
			mainStage.OuterDiamondBG.mouseChildren = false;
			mainStage.OuterDiamondBG.mouseEnabled = false;
			mainStage.TransitionDiamondBG.mouseChildren = false;
			mainStage.TransitionDiamondBG.mouseEnabled = false;
			
			characterManager = new CharacterManager(/*mainStage, userSettings*/);
			mainStage.x = (stage.stageWidth - mainStage.CharacterLayer.width /*- characterManager.MENUBUTTONSIZE/2*/) / 2;
			mainStage.CharacterLayer.addChild(characterManager);
			
			
			
			//list.
			
			/*var textList:List = new List(this);
			textList.x = 50;
			textList.listItemHeight = 30;
			textList.setSize(50, list.listItemHeight*10);
			for (var i:int = 0; i < 20; ++i)
			{
				textList.addItem( { label: String(i) } );
			}
			textList.alternateRows = list.alternateRows = true;*/
			//displayWidthLimit = stage.stageWidth - this.x*2;
			
			//Creates the menus for the flash. This will also not allow any more characters to be added
			//characterManager.CreateMenus(mainStage.MenuLayer);
			//characterManager.InitializeMusicManager(mainStage, stage.frameRate);
			//characterManager.SetupMusicForCharacters();
			//characterManager.ToggleMenu();
			
			mainMenu = new MainMenu(characterManager, null/*characterManager.musicPlayer*/, userSettings);
			addChild(mainMenu);
			mainMenu.Initialize();
			
			mainStage.CharacterLayer.visible = false;
			//Movie clip initialization.
			helpScreenMC = new HelpScreen();
			//setup movie clips before we start using them.
			SetupHelpMovieClip();
			LoadUserSettings();
			if (startupMods != null)
			{
				for (var i:int = 0, l:int = startupMods.length; i < l; ++i)
				{
					ProcessMod(startupMods[i]);
				}
			}
			
			/*if (characterManager.IsCharacterSet() == false && characterManager.GetTotalNumOfCharacters() > 0)
			{
				mainMenu.SetCharacterSelectorAndUpdate(0);
				//characterManager.SwitchToCharacter(0);
			}*/
			
			//mainMenu.SetupCharacterLocks();
			//characterManager.InitializeSettingsWindow();
			
			mainStage.play();
			
			
		}
		
		
		public function FinalizeInitialization():void
		{
			
		}
		private function SetupHelpMovieClip():void
		{
			//Set the position of the help screen
			//SetDisplayObjPosition(helpScreenMC, ((stage.stageWidth - helpScreenMC.width)/2), 0);
			helpScreenMC.visible = false;
			
			helpScreenMC.x = (mainStage.HelpLayer.getRect(mainStage.HelpLayer).right - helpScreenMC.width) / 2;
			mainStage.HelpLayer.addChild(helpScreenMC);
			helpScreenMC.y = 0;
			
			var buildDate:String = Version.BUILDDATE;
			var date:String = buildDate.substring(0, buildDate.indexOf(" "));
			var time:String = buildDate.substring(buildDate.indexOf(" ")+1);
			var dayMonthSlashPos:int = date.indexOf("/");
			var monthYearSlashPos:int = date.lastIndexOf("/");
			var month:String = date.substring(0, dayMonthSlashPos);
			if (month.length == 1) { month = 0 + month; }
			var day:String = date.substring(dayMonthSlashPos + 1, monthYearSlashPos);
			if (day.length == 1) { day = 0 + day; }
			var year:String = date.substring(monthYearSlashPos + 1);
			
			//time
			var buildAfterNoon:Boolean = (time.indexOf("PM") != -1) ? true : false;
			var hour:String = String( int(time.substring(0, time.indexOf(":"))) + buildAfterNoon ? 12 : 0);
			if (hour.length == 1) { hour = 0 + hour; }
			var minute:String = time.substring(time.indexOf(":") + 1, time.indexOf(" "));
			if (minute.length == 1) {  minute = 0 + minute; }
			
			//format is YYYYMMDDHHmm (greatest to least significance)
			var finalBuildDate:String = year + month + day + hour + minute;
			
			helpScreenMC.BuildText.text = appName + " version " + Version.VERSION + " Build #" + 
			Version.BUILDNUMBER + " Build date: " + finalBuildDate;
		}

		//The "heart beat" of the flash. Ran every frame to monitor and react to certain, often frame sensitive, events
		private function RunLoop(e:Event):void
		{
			//var mainStageMC:MovieClip = (e.target as MovieClip);
			var frameNum:int = totalRunFrames; //The current frame that the main stage is at.

			if(frameNum == 0)
			{
				if (characterManager.GetTotalNumOfCharacters() == 0)
				{
					mainStage.stopAllMovieClips();
				}
				else
				{
					mainStage.gotoAndStop("Start");
					PlayBackgroundAnimations();
				}
			}
			
			if (mainStage.currentFrame == flashStartFrame)
			{
				++totalRunFrames;
				//trace("total Frames: " + totalRunFrames);
				var animationFrame:uint = GetFrameNumberToSetForAnimation(); //The frame that an animation should be on. Animations are typically 120 frames / 4 seconds long
				mainMenu.UpdateFrameForAnimationCounter(animationFrame);
				if (userSettings.firstTimeRun == true)
				{
					UpdateKeyBindsForHelpScreen();
					ToggleHelpScreen(); //Show the help screen
					ShowMenu(true);
					//characterManager.ToggleMenu();
					userSettings.firstTimeRun = false;
					settingsSaveFile.data.ppppuSettings = userSettings;
					settingsSaveFile.flush();
				}
				else
				{
					if (userSettings.showMenu)
					{
						ShowMenu(userSettings.showMenu);
						//characterManager.ToggleMenu();
					}
				}

				mainStage.CharacterLayer.visible = true;
				if (userSettings.showBackground == true)
				{
					mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = true;
				}
				
				/*mainStage.OuterDiamondBG.gotoAndPlay(animationFrame);
				mainStage.InnerDiamondBG.gotoAndPlay(animationFrame);
				mainStage.TransitionDiamondBG.gotoAndPlay(animationFrame);
				mainStage.BacklightBG.gotoAndPlay(animationFrame);*/
				
				if(frameNum % 120 == 0) //Add character clip
				{
					
					//frameNum != 7 is so Peach is the first character displayed on start
					if(characterManager.AreCharacterSwitchesAllowed())
					{
						if (frameNum != flashStartFrame)
						{
							characterManager.CharacterSwitchLogic();
						}
					}
					var charsWereSwitched:Boolean = characterManager.DisplayAndUpdateCurrentCharacter();
					var animId:int = characterManager.GetCurrentAnimationIdOfCharacter();
					//Need to get the index that targets the given animation id. 
					var currentCharacterIdTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
					var target:int = currentCharacterIdTargets.indexOf(animId);
					mainMenu.UpdateAnimationIndexSelected(target, charsWereSwitched);
				}
			}
		}
		
		//Activated if a key is detected to be released. Sets the keys "down" status to false
		private function KeyReleaseCheck(keyEvent:KeyboardEvent):void
		{
			keyDownStatus[keyEvent.keyCode] = false;
		}
			
		/*Activated if a key is detected to be pressed and after processing logic, sets the keys "down" status to true. If this is the first 
		frame a key is detected to be down, perform the action related to that key, unless the random animation key is held down. Though 
		it was an unintentional oversight at first, people were amused by this, so it has been kept as a feature.*/
		private function KeyPressCheck(keyEvent:KeyboardEvent):void
		{
			/*if (characterManager.IsSettingsWindowActive())
			{
				return;
			}*/
			var keyPressed:int = keyEvent.keyCode;
			var keyBindings:Object = userSettings.keyBindings;
			if(keyDownStatus[keyPressed] == undefined || keyDownStatus[keyPressed] == false || (keyPressed == 48 || keyPressed == 96))
			{
				if((keyPressed == 48 || keyPressed == 96))
				{
					var chosenAnimId:int = characterManager.RandomizeCurrentCharacterAnimation(GetFrameNumberToSetForAnimation());
					//Need to get the index that targets the given animation id. 
					var currentCharacterIdTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
					var target:int = currentCharacterIdTargets.indexOf(chosenAnimId);
					
					mainMenu.UpdateAnimationIndexSelected(target);
				}
				else if((!(49 > keyPressed) && !(keyPressed > 57)) ||  (!(97 > keyPressed) && !(keyPressed > 105)))
				{
					//keypress of 1 has a keycode of 49
					if(keyPressed > 96)
					{
						keyPressed = keyPressed - 48;
					}
					//AnimationIndex 
					
					var animationIndex:int = keyPressed - 49; 
					var trueIndex:int = mainMenu.GetTrueItemIndexFromRelativePosition(animationIndex);
					var currentCharacterIdTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
					var switchSuccessful:Boolean = characterManager.ChangeAnimationForCurrentCharacter(currentCharacterIdTargets[trueIndex]);
					if (switchSuccessful == true)	
					{ 
						characterManager.ChangeFrameOfCurrentAnimation(GetFrameNumberToSetForAnimation()); 
						mainMenu.UpdateAnimationIndexSelected(trueIndex); 
					}
					//characterManager.HandleAnimActionForCurrentCharacter(animationFrame);
				}
				else if(keyPressed == keyBindings.AutoCharSwitch.main || keyPressed == keyBindings.AutoCharSwitch.alt)
				{
					characterManager.SetAllowingCharacterSwitching(!characterManager.AreCharacterSwitchesAllowed());
					//if(characterManager.GetRandomSelectStatus() && !characterManager.GetCharSwitchStatus())
					//{
						//characterManager.SetRandomSelectStatus(false);
					//}
				}
				/*else if(keyPressed == keyBindings.PrevAnimPage.main || keyPressed == keyBindings.PrevAnimPage.alt)
				{
					//Try to go to the previous page of animations
					characterManager.GotoPrevAnimationPage();
				}
				else if(keyPressed == keyBindings.NextAnimPage.main || keyPressed == keyBindings.NextAnimPage.alt)
				{
					//Try to go to the next page of animations
					characterManager.GotoNextAnimationPage();
				}*/
				else if(keyPressed == keyBindings.AnimLockMode.main || keyPressed == keyBindings.AnimLockMode.alt)
				{
					//toggle animation lock/goto mode
					//characterManager.ToggleAnimationLockMode();
				}
				else if(keyPressed == keyBindings.LockChar.main || keyPressed == keyBindings.LockChar.alt)
				{
					//(Un)lock the character who the menu cursor is on
					mainMenu.ToggleCharacterLock();
					//characterManager.ToggleLockOnCharacter(characterManager.GetMenuCursorPosition());
				}
				else if(keyPressed == keyBindings.GotoChar.main || keyPressed == keyBindings.GotoChar.alt)
				{
					//Go to the character who the menu cursor is on
					mainMenu.SwitchToSelectedCharacter();
					//characterManager.GotoSelectedMenuCharacter(characterManager.GetMenuCursorPosition());
					//settingsSaveFile.flush();
				}
				else if(keyPressed == keyBindings.CharCursorPrev.main || keyPressed == keyBindings.CharCursorPrev.alt)
				{
					//Move menu cursor to the character above
					//characterManager.MoveMenuCursorToPrevPos();
					mainMenu.MoveCharacterSelector(-1);
				}
				else if(keyPressed == keyBindings.CharCursorNext.main || keyPressed == keyBindings.CharCursorNext.alt)
				{
					//Move menu cursor to the character below
					//characterManager.MoveMenuCursorToNextPos();
					mainMenu.MoveCharacterSelector(1);
				}
				else if(keyPressed == keyBindings.RandomChar.main || keyPressed == keyBindings.RandomChar.alt)
				{
					//Toggles random character switching
					characterManager.SetIfRandomlySelectingCharacter(!characterManager.IsRandomlySelectingCharacter());
				}
				else if(keyPressed == keyBindings.Menu.main || keyPressed == keyBindings.Menu.alt)
				{
					//characterManager.ToggleMenu();
					mainMenu.visible = !mainMenu.visible;
				}
				else if(keyPressed == keyBindings.Help.main || keyPressed == keyBindings.Help.alt)
				{	
					ToggleHelpScreen();
				}
				else if(keyPressed == keyBindings.Backlight.main || keyPressed == keyBindings.Backlight.alt)
				{
					ToggleBackLight(!userSettings.backlightOn, GetFrameNumberToSetForAnimation());
				}
				else if (keyPressed == keyBindings.DisplayLimit.main || keyPressed == keyBindings.DisplayLimit.alt)
				{
					ToggleDrawLimiter();
				}
				else if(keyPressed == keyBindings.Background.main || keyPressed == keyBindings.Background.alt)
				{
					ChangeBackgroundVisibility(!userSettings.showBackground, ((mainStage.currentFrame - 2)% 120) + 1);
				}
				else if(keyPressed == keyBindings.Music.main || keyPressed == keyBindings.Music.alt)
				{
					//characterManager.ToggleMusicPlay();
				}
				else if(keyPressed == keyBindings.CharTheme.main || keyPressed == keyBindings.CharTheme.alt)
				{
					//characterManager.UseDefaultMusicForCurrentCharacter();
				}
				else if(keyPressed == keyBindings.NextHelpPage.main || keyPressed == keyBindings.NextHelpPage.alt)
				{
					if(helpScreenMC.currentFrame == helpScreenMC.totalFrames)
					{
						helpScreenMC.gotoAndStop(1);
						UpdateKeyBindsForHelpScreen();
					}
					else
					{
						helpScreenMC.nextFrame();
					}
				}
				else if(keyPressed == keyBindings.PrevMusic.main || keyPressed == keyBindings.PrevMusic.alt)
				{
					//characterManager.ChangeMusicForCurrentCharacter(false);
				}
				else if(keyPressed == keyBindings.NextMusic.main || keyPressed == keyBindings.NextMusic.alt)
				{
					//characterManager.ChangeMusicForCurrentCharacter(true);
				}
				else if(keyPressed == keyBindings.MusicForAll.main || keyPressed == keyBindings.MusicForAll.alt)
				{
					//characterManager.SetCurrentMusicForAllCharacters();
					//characterManager.MusicForEachOrAll();
				}
				else if(keyPressed == keyBindings.Activate.main || keyPressed == keyBindings.Activate.alt)
				{
					//characterManager.SetCurrentMusicForAllCharacters();
					characterManager.ActivateAnimationChange();
				}
				/*else if(keyPressed == Keyboard.E)
				{
					characterManager.DEBUG_TestMusicLoop();
				}*/
				keyDownStatus[keyPressed] = true;
			}
			keyDownStatus[keyEvent.keyCode] = true;
		}
	
		public function ChangeBackgroundVisibility(visible:Boolean, playFrameNum:int):void
		{
			userSettings.showBackground = visible;
			mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = visible;
			if (!visible)
			{
				this.scrollRect = null;
				
				mainStage.CharacterLayer.scrollRect = new Rectangle(0, 0, mainStage.CharacterLayer.getChildAt(0).width, stage.stageHeight);
					
				if(userSettings.backlightOn)
				{
					//Disable backlight. The ToggleBackLight function will take care of saving the settings.
					ToggleBackLight(false, 0);
				}
				mainStage.OuterDiamondBG.stop();
				mainStage.TransitionDiamondBG.stop();
				mainStage.InnerDiamondBG.stop();
			}
			else
			{
				mainStage.CharacterLayer.scrollRect = null;
				/*if (userSettings.limitRenderArea)
				{
					mainStage.CharacterLayer.scrollRect = null;
					this.scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
				}*/
				//settingsSaveFile.flush();
				mainStage.OuterDiamondBG.gotoAndPlay(playFrameNum);
				mainStage.TransitionDiamondBG.gotoAndPlay(playFrameNum);
				mainStage.InnerDiamondBG.gotoAndPlay(playFrameNum);
			}
			
		}
		
		//Reduces the visible area of the flash to the original ppppu's size (480x720) and enables cacheAsBitmap to speed up performance.
		//
		public function ToggleDrawLimiter():void
		{
			if (userSettings.limitRenderArea && !userSettings.showBackground)
			{
				//If the display limit is on already and the background is not shown, 
				//Do not allow the limiter to be turned off.
				return;
			}
			//this.cacheAsBitmap = !this.cacheAsBitmap;
			//userSettings.limitRenderArea = this.cacheAsBitmap;
			userSettings.limitRenderArea = !userSettings.limitRenderArea;
			this.scrollRect = null;
			mainStage.CharacterLayer.scrollRect = null;
			if (userSettings.limitRenderArea == true)
			{
				if (userSettings.showBackground)
				{
					this.scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
				}
				else
				{
					//If the diamond background isn't being shown, reduce the scrollRect so the character isn't outside the background sprite with the planet.
					mainStage.CharacterLayer.scrollRect = new Rectangle(0, 0, mainStage.CharacterLayer.getChildAt(0).width, stage.stageHeight);
				}
				
			}
		}
		
		private function ToggleBackLight(visible:Boolean, playFrameNum:int):void
		{
			//Do not make the light visible if the background isn't being shown
			if(!userSettings.showBackground && visible == true)
			{
				return;
			}
			userSettings.backlightOn = visible;
			//settingsSaveFile.flush();
			
			mainStage.BacklightBG.visible = visible;
			if(!visible)
			{
				mainStage.BacklightBG.stop();
			}
			else
			{
				if(playFrameNum < 1)
				{
					playFrameNum = 1;
				}
				mainStage.BacklightBG.gotoAndPlay(playFrameNum);
			}
		}
		
		private function ToggleHelpScreen():void
		{
			helpScreenMC.gotoAndStop(1);
			if(helpScreenMC.visible == false){UpdateKeyBindsForHelpScreen();}
			helpScreenMC.visible = !helpScreenMC.visible;
		}
		
		/*LOADER RELATED FUNCTIONS*/
		
		/*private function StartupLoadsComplete(e:LoaderEvent):void
		{
			//Add an event listener that'll allow for frame checking.
			//mainStage.addEventListener(Event.ENTER_FRAME, RunLoop);
			
			
			//mainStage.play();
			//lastRecordedTime = getTimer();
			
			startupLoadFreeze = false;
			//runTimer = new Timer(1000.0 / stage.frameRate);
			//runTimer.addEventListener(TimerEvent.TIMER, this.RunLoop);
			//runTimer.start();
			e.currentTarget.unload();
			e.currentTarget.dispose();
		}*/
		
		
		/*MODIFICATION SYSTEM RELATED FUNCTIONS*/
		
		
		private function StartupLoadComplete(e:LoaderEvent):void
		{
			FinalizeInitialization();
		}
		private function FinishedLoadingSWF(e:LoaderEvent):void
		{
			var mod:Mod = (e.target.content.rawContent as Mod);
			//Add the mod to the stage so the first frame function can get started, allowing the content to be ready to be used.
			addChild(mod);
			
			//A singular mod. Just need to process it.
			ProcessMod(mod);
			
			//remove the mod file.
			removeChild(mod);
			mod = null;
			//e.target.unload();
			//e.target.dispose();
		}
		
		/*Processes a mod and then adds it into ppppu. Returns true if mod was successfully added and false if a problem was encounter
		and the mod could not be added.*/
		private function ProcessMod(mod:Mod/*, modType:int*/):Boolean
		{
			if (mod == null)	{ return false; }
			
			var modType:int = mod.GetModType();
			
			if (modType == Mod.MOD_ANIMATION)
			{
				//Not used in interactive versions
			}
			else if (modType == Mod.MOD_ANIMATEDCHARACTER)
			{
				var animCharacterMod:AnimatedCharacterMod = mod as AnimatedCharacterMod;
				if (animCharacterMod)
				{
					var characterName:String = animCharacterMod.GetCharacter().GetName();
					if (characterManager.AddCharacter(animCharacterMod.GetCharacter()))
					{
						mainMenu.AddIconToCharacterMenu(animCharacterMod.GetCharacter().GetIcon());
						TryToLoadCharacterSettings(characterName);
					}
					
					//list.addItem();
					//animCharacterMod.parent = null;
				}
				
			}
			else if (modType == Mod.MOD_TEMPLATECHARACTER)
			{
				//Not used in interactive versions
			}
			else if (modType == Mod.MOD_MUSIC)
			{
				var music:MusicMod = mod as MusicMod;
				if (music)
				{
					//musicPlayer.AddMusic(music.GetMusicData(), music.GetName(), music.GetStartLoopTime(), music.GetEndLoopTime(), music.GetStartTime());
				}
			}
			else if (modType == Mod.MOD_ASSETS)
			{
				//Not used in interactive versions
			}
			//If the mod type is an archive we'll need to iterate through the mod list it has and process them seperately
			else if (modType == Mod.MOD_ARCHIVE)
			{
				var archive:ModArchive = mod as ModArchive;
				if (archive)
				{
					var archiveModList:Vector.<Mod> = archive.GetModsList();
					var childMod:Mod;
					for (var i:int = 0, l:int = archiveModList.length; i < l; ++i)
					{
						childMod = archiveModList[i];
						ProcessMod(childMod);
					}
				}
			}
			mod.Dispose();
			mod = null;
			return false;
		}
		
		/*SETTINGS RELATED FUNCTIONS*/
		public function SaveSettingsToDisk(e:events.SaveRequestEvent):void
		{
			if (helpScreenMC.visible)
			{
				UpdateKeyBindsForHelpScreen();
			}
			settingsSaveFile.flush();
		}
		
		private function LoadUserSettings():void
		{
			if (settingsSaveFile.data.ppppuSettings != null)
			{
				if (userSettings.SAVE_VERSION == settingsSaveFile.data.ppppuSettings.version)
				{
					userSettings.ConvertFromObject(settingsSaveFile.data.ppppuSettings);
					//Something went terribly wrong, recreate the user settings
					if (userSettings == null) { userSettings = new UserSettings(); }
				}
				else
				{
					settingsSaveFile.clear();
				}
				settingsSaveFile.data.ppppuSettings = userSettings;
			}
			if (userSettings.limitRenderArea == true) { ToggleDrawLimiter(); }
			ChangeBackgroundVisibility(userSettings.showBackground, 0);
			if (userSettings.showBackground == true)
			{
				mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = false;
			}
			ToggleBackLight(userSettings.backlightOn, 0);	
			
			//characterManager.GotoSelectedMenuCharacter(characterManager.GetCharacterIdByName(userSettings.currentCharacterName));
			characterManager.SetAllowingCharacterSwitching(userSettings.allowCharacterSwitches);
			characterManager.SetIfRandomlySelectingCharacter(userSettings.randomlySelectCharacter);
			//if (!userSettings.playMusic) { characterManager.ToggleMusicPlay(); }
			
			//characterManager.ChangeGlobalMusicForAllCharacters(userSettings.globalSongTitle);
			//if (userSettings.playOneSongForAllCharacters) { characterManager.MusicForEachOrAll();}
			//if (userSettings.showMenu == false) { characterManager.ToggleMenu(); }
			
			//characterManager.
			//if (userSettings. == false) { ; }	
			
		}
		
		private function TryToLoadCharacterSettings(characterName:String):void
		{
			if (userSettings.CheckIfCharacterHasSettings(characterName) == false)
			{
				userSettings.CreateSettingsForNewCharacter(characterName);
			}
			if(characterName in userSettings.characterSettings)
			{
				var charId:int = characterManager.GetCharacterIdByName(characterName);
				if (charId > -1)
				{
					//processing of character settings
					var charSettings:Object = userSettings.characterSettings[characterName];
					if (charSettings.locked == null) { charSettings.locked = false; }
					
					//Set up character to use those settings.
					characterManager.InitializeSettingsForCharacter(charId, charSettings);
					//Insert something here for menu to update
					mainMenu.SetupMenusForCharacter(charId, charSettings);
					
					trace(characterName + ": " + charSettings.locked);
					
					//var lockedAnimationsVector:Vector.<Boolean> = userSettings.characterSettings[characterName].animationLocks;
					/*var animLockObject:Object = charSettings.animationLocked;
					for (var animationNumberStr:String in animLockObject)
					{
						var animNum:int = int(animationNumberStr);
						characterManager.SetAnimationLockForCharacter(charId, animNum, animLockObject[animNum]);
					}*/
					
					/*if (charSettings.canSwitchTo == false)
					{
						//By default the character is unlocked. So if we can't switch to them, toggle to set true to false as needed.
						//mainMenu.ToggleCharacterLock(charId);
						mainMenu.SetInitialCharacterLock(charId, charSettings.canSwitchTo);
					}*/
					//characterManager.SetLockOnCharacter(charId, charSettings.canSwitchTo);
					/*if (charSettings.canSwitchTo == false)
					{
						characterManager.ToggleSelectedMenuCharacterLock(charId);
					}*/
					
					/*var animSelect:int = charSettings.animationSelect;
					if (animSelect == 0)
					{
						characterManager.GetCharacterById(charId).SetRandomizeAnimation(true);
					}
					else
					{
						characterManager.GetCharacterById(charId).SetRandomizeAnimation(false);
						characterManager.GetCharacterById(charId).ChangeAnimationIndexToPlay(animSelect);
					}*/
					//TODO: Make Music player handle this.
					//var musicId:int = musicPlayer.GetMusicIdByTitle(charSettings.playMusicTitle);
					//musicPlayer.ChangeSelectedMusicForCharacter(musicId);
					//characterManager.ChangeMusicForCharacter(charId, charSettings.playMusicTitle);
					if (characterName == userSettings.currentCharacterName)
					{
						mainMenu.SetCharacterSelectorAndUpdate(charId);
						//mainMenu.ChangeAnimationForCurrentCharacter();
					}
				}
				
			}
			
			
		}
		
		public function UpdateKeyBindsForHelpScreen():void
		{
			for (var i:int = 0, l:int = helpScreenMC.numChildren; i < l;++i)
			{
				var helpScreenChild:TextField = helpScreenMC.getChildAt(i) as TextField;
				if (helpScreenChild && helpScreenChild.type == TextFieldType.DYNAMIC)
				{
					GenerateKeybindTextFrom(helpScreenChild);
				}
			}
		}
		
		private function GenerateKeybindTextFrom(helpTextField:TextField):void
		{
			var textFieldName:String = helpTextField.name;
			var keybindingObj:Object;
			var txt:String = helpTextField.text;
			if (textFieldName == "CharCursorUpText")
			{
				keybindingObj = userSettings.keyBindings.CharCursorPrev;
			}
			else if (textFieldName == "CharCursorDownText")
			{
				keybindingObj = userSettings.keyBindings.CharCursorNext;
			}
			else if (textFieldName == "RandomCharText")
			{
				keybindingObj = userSettings.keyBindings.RandomChar;
			}
			else if (textFieldName == "AutoCharText")
			{
				keybindingObj = userSettings.keyBindings.AutoCharSwitch;
			}
			else if (textFieldName == "LockSelectedCharText")
			{
				keybindingObj = userSettings.keyBindings.LockChar;
			}
			else if (textFieldName == "SwitchToCharText")
			{
				keybindingObj = userSettings.keyBindings.GotoChar;
			}
			else if (textFieldName == "AnimationModeText")
			{
				keybindingObj = userSettings.keyBindings.AnimLockMode;
			}
			else if (textFieldName == "Prev9Text")
			{
				keybindingObj = userSettings.keyBindings.PrevAnimPage;
			}
			else if (textFieldName == "Next9Text")
			{
				keybindingObj = userSettings.keyBindings.NextAnimPage;
			}
			else if (textFieldName == "HelpText")
			{
				keybindingObj = userSettings.keyBindings.Help;
			}
			else if (textFieldName == "NextHelpPageText")
			{
				keybindingObj = userSettings.keyBindings.NextHelpPage;
			}
			else if (textFieldName == "MenuText")
			{
				keybindingObj = userSettings.keyBindings.Menu;
			}
			else if (textFieldName == "BacklightText")
			{
				keybindingObj = userSettings.keyBindings.Backlight;
			}
			else if (textFieldName == "DisplayLimitText")
			{
				keybindingObj = userSettings.keyBindings.DisplayLimit;
			}
			else if (textFieldName == "BackgroundText")
			{
				keybindingObj = userSettings.keyBindings.Background;
			}
			else if (textFieldName == "MusicText")
			{
				keybindingObj = userSettings.keyBindings.Music;
			}
			else if (textFieldName == "CharDefMusicText")
			{
				keybindingObj = userSettings.keyBindings.CharTheme;
			}
			else if (textFieldName == "PrevMusicText")
			{
				keybindingObj = userSettings.keyBindings.PrevMusic;
			}
			else if (textFieldName == "NextMusicText")
			{
				keybindingObj = userSettings.keyBindings.NextMusic;
			}
			else if (textFieldName == "MusicForAllText")
			{
				keybindingObj = userSettings.keyBindings.MusicForAll;
			}
			else if (textFieldName == "Activate")
			{
				keybindingObj = userSettings.keyBindings.Activate;
			}
			
			
			if (keybindingObj)
			{
				var mainKey:int = keybindingObj.main;
				var altKey:int = keybindingObj.alt;
				var returnString:String = "";
				if (mainKey >= 0)
				{
					returnString += (Config.keyDict[mainKey] as String).toLowerCase();
				}
				if (altKey >= 0)
				{
					if (returnString.length > 0)
					{
						returnString += " or ";
					}
					returnString += (Config.keyDict[altKey] as String).toLowerCase();
				}
				if (returnString.length > 0)
				{
					returnString += " ";
				}
				else
				{
					returnString = "not bound ";
				}
				helpTextField.replaceText(0, txt.indexOf(":"), returnString);
				AutosizeTextFont(helpTextField);
			}
		}
		
		private function AutosizeTextFont(txt:TextField):void 
		{
			//You set this according to your TextField's dimensions
			var maxTextWidth:int = txt.width; 
			var maxTextHeight:int = txt.height; 
			var defaultFormat:TextFormat = txt.defaultTextFormat;
			txt.setTextFormat(defaultFormat);
			var f:TextFormat = txt.getTextFormat();
			f.size = HELP_INITIAL_FONT_SIZE;
			txt.setTextFormat(f);
			
			//decrease font size until the text fits  
			while (txt.textWidth > maxTextWidth || txt.textHeight > maxTextHeight) 
			{
				f.size = int(f.size) - 1;
				txt.setTextFormat(f);
			}
		}
		
		/*Most animations run for 120 frames / 4 seconds. The mainstage movie clip has over 120 frames though, so some calculations
		 * are necessary to derive the frame number that an animation should be set to.*/
		[inline]
		private function GetFrameNumberToSetForAnimation():int
		{
			return (totalRunFrames % 120);
		}
		private function AnimationTransitionOccured(e:Event):void
		{
			StopBackgroundAnimations();
			addEventListener(ExitLinkedAnimationEvent.EXIT_LINKED_ANIMATION, ExitingLinkedAnimation, true);
		}
		
		private function ExitingLinkedAnimation(e:Event):void
		{
			removeEventListener(ExitLinkedAnimationEvent.EXIT_LINKED_ANIMATION, ExitingLinkedAnimation, true);
			PlayBackgroundAnimations(GetFrameNumberToSetForAnimation());
		}
		private function StopBackgroundAnimations():void
		{
			mainStage.OuterDiamondBG.stop();
			mainStage.InnerDiamondBG.stop();
			mainStage.TransitionDiamondBG.stop();
			mainStage.BacklightBG.stop();
			//Since making the backlight invisible is a user setting and that shouldn't be interfered with, alpha will be used to hide
			//the backlight.
			mainStage.BacklightBG.alpha = 0; 
		}
		
		[inline]
		private function PlayBackgroundAnimations(startFrame:int = 1):void
		{
			mainStage.OuterDiamondBG.gotoAndPlay(startFrame);
			mainStage.InnerDiamondBG.gotoAndPlay(startFrame);
			mainStage.TransitionDiamondBG.gotoAndPlay(startFrame);
			mainStage.BacklightBG.gotoAndPlay(startFrame);
			mainStage.BacklightBG.alpha = 1;
		}
		
		private function ChangeBackgroundColors(e:ChangeBackgroundEvent):void
		{
			var colors:Object = e.colorTransforms;
			mainStage.TransitionDiamondBG.TransitionDiamond.Color1.transform.colorTransform = 
				mainStage.InnerDiamondBG.InnerDiamond.Color1.transform.colorTransform = colors.inDiaTL;
			mainStage.TransitionDiamondBG.TransitionDiamond.Color2.transform.colorTransform = 
				mainStage.InnerDiamondBG.InnerDiamond.Color2.transform.colorTransform = colors.inDiaCen;
			mainStage.TransitionDiamondBG.TransitionDiamond.Color3.transform.colorTransform = 
				mainStage.InnerDiamondBG.InnerDiamond.Color3.transform.colorTransform = colors.inDiaBR;
			mainStage.TransitionDiamondBG.TransitionDiamond.Color4.transform.colorTransform = 
				mainStage.OuterDiamondBG.OuterDiamond.Color.transform.colorTransform = colors.outDia;
			mainStage.BacklightBG.Backlight.BacklightGfx.transform.colorTransform = colors.light;
		}
		
		[inline]
		private function ShowMenu(visible:Boolean):void
		{
			mainMenu.visible = visible;
		}
		
		/*private function AnimationTransitionHappened(e:Event):void
		{
			var i:int = 0;
		}*/
		
		/*private function RemoveTransitionLockoutHandler(e:Event):void
		{
			characterManager.RemoveTransitionLockout();
		}*/
	}
}