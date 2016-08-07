package  
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	import events.AnimationTransitionEvent;
	import events.ExitLinkedAnimationEvent;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import events.ChangeBackgroundEvent;
	import events.SaveRequestEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import CharacterManager;
	import menu.MainMenu;
	import modifications.*;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
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
		public var settingsSaveFile:SharedObject = SharedObject.getLocal("ppppuXi");
		
		public var userSettings:UserSettings = new UserSettings();
		
		//Loading
		private var contentLoader:LoaderMax = new LoaderMax({name:"Content loader"});
		
		//private var musicPlayer:MusicPlayer = new MusicPlayer();
		private var mainMenu:MainMenu;
		
		/*Timing*/
		/*The total amount of frames that the program has been running for. Due to being reliant on the enter frame event
		 * this number can end up being off from where it should be when slowdown happens.*/
		private var totalRunFrames:uint = 0;
		/*A correctional variable that keeps track of what frame the program should be on given its execution time.
		* When the intended run frame is ahead of the totalRunFrames, animation frame skipping will be done to keep
		* animations in sync with the music.*/
		private var intendedRunFrame:uint = 0;
		private var totalRunTime:Number = 0;
		private var lastUpdateTime:Number = 0;
		/*The maximum amount of frames an animation can fall out of sync behind the music
		* before any animations are jumped ahead to resync.*/
		private const ANIMATION_MAX_FRAMES_BEHIND_MUSIC:int = 2;
		private var updatesSinceLastSkip:int = 0;
		private const updatesUntilCompleteResync:int = 60;
		//private var runLoopTimer:Timer;
		
		//Music
		private var musicPlayer:MusicPlayer = new MusicPlayer();
		
		private const appName:String = "ppppuXi beta";
		
		//
		//private var Debug_runTime:Number = 0;
		
		/*The amount of frames to wait before the runloop can actually allow the animations to be added to the stage.
		* The intent is to give Flash time to "warm up", finish up any garbage collection and any other tasks that
		* could interfere with a smooth start for the animations.*/
		private var runloopDelayCountdown:int = 60;
		private var timeRunLoopDelayCountdown:Number = 60*33.3;
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
			//Multitouch.inputMode = MultitouchInputMode.NONE;
			//Add an event listener that'll allow for frame checking.
			mainStage.addEventListener(Event.ENTER_FRAME, RunLoop);
			mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = false;
			addEventListener(events.SaveRequestEvent.SAVE_SHARED_OBJECT, SaveSettingsToDisk);
			//settingsSaveFile.clear();
			
			//Debug_Timer.addEventListener(TimerEvent.TIMER, Debug_TimerHandler);
		}
		
		//Sets up the various aspects of the flash to get it ready for performing.
		public function Initialize(startupMods:Array = null):void
		{
			//var msBounds:Rectangle = mainStage.getBounds(mainStage);
			//var mainStagePlacementX:Number = ((mainStage.stage.stageWidth - msBounds.right));
			//mainStage.x = mainStagePlacementX;
			
			
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
			
			LoadUserSettings();
			
			mainMenu = new MainMenu(characterManager, musicPlayer, userSettings);
			mainMenu.visible = false;
			addChild(mainMenu);
			mainMenu.Initialize();
			
			mainStage.CharacterLayer.visible = false;
			//Movie clip initialization.
			helpScreenMC = new HelpScreen();
			//setup movie clips before we start using them.
			SetupHelpMovieClip();
			
			var bbsMusicMod:M_BeepBlockSkyway = new M_BeepBlockSkyway();
			addChild(bbsMusicMod);
			removeChild(bbsMusicMod);
			ProcessMod(bbsMusicMod);
			
			if (startupMods != null)
			{
				for (var i:int = 0, l:int = startupMods.length; i < l; ++i)
				{
					ProcessMod(startupMods[i]);
				}
			}
			System.pauseForGCIfCollectionImminent(0);
			//runLoopTimer = new Timer(1000 / stage.frameRate);
			//runLoopTimer.addEventListener(TimerEvent.TIMER, TimeBasedRunLoop);
			//runLoopTimer.start();
			mainStage.play();
			
			
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
			var hour:String = String( int(time.substring(0, time.indexOf(":"))) + (buildAfterNoon ? 12 : 0));
			if (hour.length == 1) { hour = 0 + hour; }
			var minute:String = time.substring(time.indexOf(":") + 1, time.indexOf(" "));
			if (minute.length == 1) {  minute = 0 + minute; }
			
			//format is YYYYMMDDHHmm (greatest to least significance)
			var finalBuildDate:String = year + month + day + hour + minute;
			
			helpScreenMC.BuildText.text = appName + " version " + Version.VERSION + " Build #" + 
			Version.BUILDNUMBER + " Build date: " + finalBuildDate;
		}

		//Modified "frame skipping" run loop.
		private function RunLoop(e:Event):void
		{
			//var frameNum:uint = totalRunFrames; //The current frame that the main stage is at.

			if(totalRunFrames == 0)
			{
				if (characterManager.GetTotalNumOfCharacters() == 0 || runloopDelayCountdown > 0)
				{
					mainStage.stopAllMovieClips();
					if(runloopDelayCountdown > 0){--runloopDelayCountdown;}
				}
				else
				{
					//Add the key listeners
					stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyPressCheck);
					stage.addEventListener(KeyboardEvent.KEY_UP, KeyReleaseCheck);
					
					if (userSettings.firstTimeRun == true)
					{
						UpdateKeyBindsForHelpScreen();
						ToggleHelpScreen(); //Show the help screen
						ShowMenu(true);
						userSettings.firstTimeRun = false;
						settingsSaveFile.data.ppppuSettings = userSettings;
						settingsSaveFile.flush();
					}
					else
					{
						if (userSettings.showMenu)
						{
							ShowMenu(userSettings.showMenu);
						}
					}
					
					mainStage.gotoAndStop("Start");
					ChangeBackgroundVisibility(userSettings.showBackground);
					SetBackLight(userSettings.backlightOn);
					PlayBackgroundAnimations();
					mainMenu.ChangeMusicMenuDisplayedInfo(musicPlayer.PlayMusic( -2, intendedRunFrame));
					lastUpdateTime = getTimer();
				}
			}
			
			if (mainStage.currentFrame == flashStartFrame)
			{
				var currentUpdateTime:Number = getTimer();
				var delta:Number = currentUpdateTime - lastUpdateTime;
				totalRunTime += delta;
				//trace("current: " + currentUpdateTime + ", last: " + lastUpdateTime + ", delta: " + delta + ", total: " + totalRunTime);
				lastUpdateTime = currentUpdateTime;
				
				++totalRunFrames;
				++updatesSinceLastSkip;
				intendedRunFrame = (totalRunTime / (1000.0 / stage.frameRate)) + 1;
				//character switch skip check
				var skippedCharacterSwitchFrame:Boolean = false;
				
				if (intendedRunFrame > totalRunFrames + ANIMATION_MAX_FRAMES_BEHIND_MUSIC && characterManager.CheckIfTransitionLockIsActive() == false)
				{
					//For when the animation falls too far behind and needs to be immediately resynced.
					trace(totalRunFrames + ", " + intendedRunFrame + "; Animation has fallen " + (intendedRunFrame - totalRunFrames) + " frames behind");
					if (intendedRunFrame - totalRunFrames > 120 - ((totalRunFrames-1) % 120)+1)
					{
						skippedCharacterSwitchFrame = true;
					}
					totalRunFrames = intendedRunFrame;
					SkipFramesForAnimations(totalRunFrames);
					updatesSinceLastSkip = 0;
				}
				else if (updatesSinceLastSkip >= updatesUntilCompleteResync && intendedRunFrame > totalRunFrames)
				{
					//If the animation is behind a bit but not enough to force an immediate resync.
					//After a period of time the animation will be resynced.
					trace("delayed resync");
					totalRunFrames = intendedRunFrame;
					SkipFramesForAnimations(totalRunFrames);
					updatesSinceLastSkip = 0;
				}
				var animationFrame:uint = GetFrameNumberToSetForAnimation(); //The frame that an animation should be on. Animations are typically 120 frames / 4 seconds long
				mainMenu.UpdateFrameForAnimationCounter(animationFrame);
				
				mainStage.CharacterLayer.visible = true;
				if (userSettings.showBackground == true)
				{
					mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = true;
				}
				//trace("Run time" + Debug_runTime + ", frame: " + totalRunFrames + ", expected run time: " + totalRunFrames *  33.3 +
				//", music position: " + musicPlayer.m_musicCollection[musicPlayer.m_currentlyPlayingMusicId].debug_currentTimePosition);
				//Use m_mainSoundChannel.position to get position, using the music object's sample position is way off in terms of accuracy (1.2 secs ahead).
				//trace(totalRunFrames + ", sound chan position: " + musicPlayer.m_mainSoundChannel.position + ", music currentPosition: " + musicPlayer.debug_CurrentMusic.debug_currentTimePosition);

				
				if(animationFrame == 1 || skippedCharacterSwitchFrame == true) //Add character clip
				{
					//trace(totalRunFrames + ", " + intendedRunFrame);
					//frameNum != 7 is so Peach is the first character displayed on start
					if(characterManager.AreCharacterSwitchesAllowed())
					{
						/* The first run frame should not have the character switch logic run.
						 * This is so the initial character set (which is the last character on screen the previous
						 * time the program was ran or the first character loaded if the settings save file wasn't found)
						 * isn't switch from and give them a chance to be seen as intended.*/
						if (totalRunFrames != 0)
						{
							characterManager.CharacterSwitchLogic();
							//trace("Switched at " + totalRunFrames);
						}
					}
					
					var charsWereSwitched:Boolean = characterManager.UpdateAndDisplayCurrentCharacter(animationFrame);
					if (charsWereSwitched == true)
					{
						
						userSettings.UpdateCurrentCharacterName(characterManager.GetCurrentCharacterName());
						mainMenu.SetCharacterSelectorAndUpdate(characterManager.GetIdOfCurrentCharacter());
						
					}
					/*Updates the menu to match the automatically selected animation. Do not call 
					MainMenu::SelectAnimation() as that is for user input and takes relative index of the list item,
					unlike the below code which uses the absolute index.*/
					var animId:int = characterManager.GetCurrentAnimationIdOfCharacter();
					//Need to get the index that targets the given animation id. 
					var currentCharacterIdTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
					var target:int = currentCharacterIdTargets.indexOf(animId);
					mainMenu.UpdateAnimationIndexSelected(target, charsWereSwitched);
				}
			}
		}
		
		//The "heart beat" of the flash. Ran every frame to monitor and react to certain, often frame sensitive, events
		//private function RunLoop(e:Event):void
		//{
			//var frameNum:uint = totalRunFrames; //The current frame that the main stage is at.
//
			//if(frameNum == 0)
			//{
				//if (characterManager.GetTotalNumOfCharacters() == 0 || runloopDelayCountdown > 0)
				//{
					//mainStage.stopAllMovieClips();
					//if(runloopDelayCountdown > 0){--runloopDelayCountdown;}
				//}
				//else
				//{
					////Add the key listeners
					//stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyPressCheck);
					//stage.addEventListener(KeyboardEvent.KEY_UP, KeyReleaseCheck);
					//
					//if (userSettings.firstTimeRun == true)
					//{
						//UpdateKeyBindsForHelpScreen();
						//ToggleHelpScreen(); //Show the help screen
						//ShowMenu(true);
						//userSettings.firstTimeRun = false;
						//settingsSaveFile.data.ppppuSettings = userSettings;
						//settingsSaveFile.flush();
					//}
					//else
					//{
						//if (userSettings.showMenu)
						//{
							//ShowMenu(userSettings.showMenu);
						//}
					//}
					//
					//mainStage.gotoAndStop("Start");
					//ChangeBackgroundVisibility(userSettings.showBackground);
					//SetBackLight(userSettings.backlightOn);
					//PlayBackgroundAnimations();
					//mainMenu.ChangeMusicMenuDisplayedInfo(musicPlayer.PlayMusic( -2, intendedRunFrame));
					//lastUpdateTime = getTimer();
				//}
			//}
			//
			//if (mainStage.currentFrame == flashStartFrame)
			//{
				//var currentUpdateTime:Number = getTimer();
				//var delta:Number = currentUpdateTime - lastUpdateTime;
				//totalRunTime += delta;
				//trace("current: " + currentUpdateTime + ", last: " + lastUpdateTime + ", delta: " + delta + ", total: " + totalRunTime);
				//lastUpdateTime = currentUpdateTime;
				//
				//++totalRunFrames;
				//var animationFrame:uint = GetFrameNumberToSetForAnimation(); //The frame that an animation should be on. Animations are typically 120 frames / 4 seconds long
				//mainMenu.UpdateFrameForAnimationCounter(animationFrame);
				//
				//mainStage.CharacterLayer.visible = true;
				//if (userSettings.showBackground == true)
				//{
					//mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = true;
				//}
				////trace("Run time" + Debug_runTime + ", frame: " + totalRunFrames + ", expected run time: " + totalRunFrames *  33.3 +
				////", music position: " + musicPlayer.m_musicCollection[musicPlayer.m_currentlyPlayingMusicId].debug_currentTimePosition);
				////Use m_mainSoundChannel.position to get position, using the music object's sample position is way off in terms of accuracy (1.2 secs ahead).
				//trace(totalRunFrames + ", sound chan position: " + musicPlayer.m_mainSoundChannel.position + ", music currentPosition: " + musicPlayer.debug_CurrentMusic.debug_currentTimePosition);
//
				//if(frameNum % 120 == 0) //Add character clip
				//{
					//
					////frameNum != 7 is so Peach is the first character displayed on start
					//if(characterManager.AreCharacterSwitchesAllowed())
					//{
						///* The first run frame should not have the character switch logic run.
						 //* This is so the initial character set (which is the last character on screen the previous
						 //* time the program was ran or the first character loaded if the settings save file wasn't found)
						 //* isn't switch from and give them a chance to be seen as intended.*/
						//if (frameNum != 0)
						//{
							//characterManager.CharacterSwitchLogic();
							////trace("Switched at " + totalRunFrames);
						//}
					//}
					//
					//var charsWereSwitched:Boolean = characterManager.UpdateAndDisplayCurrentCharacter();
					//if (charsWereSwitched == true)
					//{
						//
						//userSettings.UpdateCurrentCharacterName(characterManager.GetCurrentCharacterName());
						//mainMenu.SetCharacterSelectorAndUpdate(characterManager.GetIdOfCurrentCharacter());
						//
					//}
					///*Updates the menu to match the automatically selected animation. Do not call 
					//MainMenu::SelectAnimation() as that is for user input and takes relative index of the list item,
					//unlike the below code which uses the absolute index.*/
					//var animId:int = characterManager.GetCurrentAnimationIdOfCharacter();
					////Need to get the index that targets the given animation id. 
					//var currentCharacterIdTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
					//var target:int = currentCharacterIdTargets.indexOf(animId);
					//mainMenu.UpdateAnimationIndexSelected(target, charsWereSwitched);
				//}
			//}
		//}
		
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
					mainMenu.SelectAnimation(null, -1);
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
					mainMenu.SelectAnimation(null, animationIndex);
					//characterManager.HandleAnimActionForCurrentCharacter(animationFrame);
				}
				else if(keyPressed == keyBindings.AutoCharSwitch.main || keyPressed == keyBindings.AutoCharSwitch.alt)
				{
					var charSwitchingAllowed:Boolean = characterManager.SetAllowingCharacterSwitching(!characterManager.AreCharacterSwitchesAllowed());
					mainMenu.UpdateModeForCharacterSwitchButton(charSwitchingAllowed ? "Normal" : "Single" );
					userSettings.UpdateCharacterSwitching(charSwitchingAllowed);
					userSettings.UpdateRandomCharacterSelecting(characterManager.IsRandomlySelectingCharacter());
					//if(characterManager.GetRandomSelectStatus() && !characterManager.GetCharSwitchStatus())
					//{
						//characterManager.SetRandomSelectStatus(false);
					//}
				}
				else if(keyPressed == keyBindings.PrevAnimPage.main || keyPressed == keyBindings.PrevAnimPage.alt)
				{
					//Try to go to the previous page of animations
					mainMenu.ChangeThe9ItemsDisplayedForAnimations(false);
				}
				else if(keyPressed == keyBindings.NextAnimPage.main || keyPressed == keyBindings.NextAnimPage.alt)
				{
					//Try to go to the next page of animations
					mainMenu.ChangeThe9ItemsDisplayedForAnimations(true);
				}
				else if(keyPressed == keyBindings.AnimLockMode.main || keyPressed == keyBindings.AnimLockMode.alt)
				{
					//toggle animation lock/goto mode
					mainMenu.ToggleAnimationMenuKeyboardMode();					
				}
				else if(keyPressed == keyBindings.LockChar.main || keyPressed == keyBindings.LockChar.alt)
				{
					//(Un)lock the character who the menu cursor is on
					mainMenu.SetCharacterLock();
				}
				else if(keyPressed == keyBindings.GotoChar.main || keyPressed == keyBindings.GotoChar.alt)
				{
					//Go to the character who the menu cursor is on
					mainMenu.SelectCharacter();
				}
				else if(keyPressed == keyBindings.CharCursorPrev.main || keyPressed == keyBindings.CharCursorPrev.alt)
				{
					//Move menu cursor to the character above
					mainMenu.MoveCharacterSelector(-1);
				}
				else if(keyPressed == keyBindings.CharCursorNext.main || keyPressed == keyBindings.CharCursorNext.alt)
				{
					//Move menu cursor to the character below
					mainMenu.MoveCharacterSelector(1);
				}
				else if(keyPressed == keyBindings.RandomChar.main || keyPressed == keyBindings.RandomChar.alt)
				{
					//Toggles random character switching
					var randomCharSelect:Boolean = characterManager.SetIfRandomlySelectingCharacter(!characterManager.IsRandomlySelectingCharacter());
					mainMenu.UpdateModeForCharacterSwitchButton(randomCharSelect ? "Random" : "Normal");
					userSettings.UpdateCharacterSwitching(characterManager.AreCharacterSwitchesAllowed());
					userSettings.UpdateRandomCharacterSelecting(randomCharSelect);
					
				}
				else if(keyPressed == keyBindings.Menu.main || keyPressed == keyBindings.Menu.alt)
				{
					//characterManager.ToggleMenu();
					mainMenu.visible = !mainMenu.visible;
					userSettings.UpdateMenuVisibility(mainMenu.visible);
				}
				else if(keyPressed == keyBindings.Help.main || keyPressed == keyBindings.Help.alt)
				{	
					ToggleHelpScreen();
				}
				else if(keyPressed == keyBindings.Backlight.main || keyPressed == keyBindings.Backlight.alt)
				{
					SetBackLight(!userSettings.backlightOn);
				}
				else if(keyPressed == keyBindings.Background.main || keyPressed == keyBindings.Background.alt)
				{
					ChangeBackgroundVisibility(!userSettings.showBackground);
				}
				else if(keyPressed == keyBindings.Music.main || keyPressed == keyBindings.Music.alt)
				{
					var musicEnabled:Boolean = musicPlayer.SetIfMusicIsEnabled(!musicPlayer.IsMusicPlaying());
					mainMenu.UpdateMusicEnabledButtonForMusicMenu(musicEnabled);
					userSettings.playMusic = musicEnabled;
					var displayText:String = musicPlayer.PlayMusic( -2, intendedRunFrame);
					mainMenu.ChangeMusicMenuDisplayedInfo(displayText);
					//characterManager.ToggleMusicPlay();
				}
				else if(keyPressed == keyBindings.CharPreferredMusic.main || keyPressed == keyBindings.CharPreferredMusic.alt)
				{
					var musicId:int = musicPlayer.GetMusicIdByName(characterManager.GetPreferredMusicForCurrentCharacter());
					if (musicId > -1)
					{
						var musicDisplayInfo:String = musicPlayer.PlayMusic(musicId, intendedRunFrame);
						mainMenu.ChangeMusicMenuDisplayedInfo(musicDisplayInfo);
						userSettings.globalSongTitle = musicPlayer.GetNameOfCurrentMusic();
					}
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
					mainMenu.ChangeMusicMenuDisplayedInfo(musicPlayer.ChangeToPrevMusic(totalRunFrames));
					userSettings.globalSongTitle = musicPlayer.GetNameOfCurrentMusic();
					//characterManager.ChangeMusicForCurrentCharacter(false);
					//trace(Debug_runTime);
				}
				else if(keyPressed == keyBindings.NextMusic.main || keyPressed == keyBindings.NextMusic.alt)
				{
					mainMenu.ChangeMusicMenuDisplayedInfo(musicPlayer.ChangeToNextMusic(totalRunFrames));
					userSettings.globalSongTitle = musicPlayer.GetNameOfCurrentMusic();
					//trace(Debug_runTime);
					//characterManager.ChangeMusicForCurrentCharacter(true);
				}
				/*else if(keyPressed == keyBindings.MusicForAll.main || keyPressed == keyBindings.MusicForAll.alt)
				{
					//characterManager.SetCurrentMusicForAllCharacters();
					//characterManager.MusicForEachOrAll();
				}*/
				else if(keyPressed == keyBindings.Activate.main || keyPressed == keyBindings.Activate.alt)
				{
					//characterManager.SetCurrentMusicForAllCharacters();
					characterManager.ActivateAnimationChange();
				}
				else if(keyPressed == Keyboard.END)
				{
					musicPlayer.DEBUG_GoToMusicLastSection();
				}
				keyDownStatus[keyPressed] = true;
			}
			keyDownStatus[keyEvent.keyCode] = true;
		}
		[inline]
		public function ChangeBackgroundVisibility(visible:Boolean):void
		{
			userSettings.UpdateShowBackground(visible);
			mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = visible;
			if (!visible)
			{
				mainStage.CharacterLayer.scrollRect = new Rectangle(0, 0, mainStage.CharacterLayer.getChildAt(0).width, stage.stageHeight);
					
				StopBackgroundAnimations();
			}
			else
			{
				mainStage.CharacterLayer.scrollRect = null;
				//mainStage.CharacterLayer.scrollRect = null;
				PlayBackgroundAnimations(GetFrameNumberToSetForAnimation());
				/*if (userSettings.backlightOn)
				{
					SetBackLight(userSettings.backlightOn);
				}*/
			}
			
		}
		
		private function SetBackLight(visible:Boolean):void
		{
			userSettings.UpdateShowingBacklight(visible);
			//settingsSaveFile.flush();
			
			//Do not make the light visible if the background isn't being shown
			if (!userSettings.showBackground && visible)
			{
				mainStage.BacklightBG.visible = false;
				return;
			}
			if(!visible)
			{
				mainStage.BacklightBG.stop();
			}
			else
			{
				mainStage.BacklightBG.gotoAndPlay(GetFrameNumberToSetForAnimation());
			}
			mainStage.BacklightBG.visible = visible;
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
		}
		
		/*Processes a mod and then adds it into ppppu. Returns true if mod was successfully added and false if a problem was encounter
		and the mod could not be added.*/
		private function ProcessMod(mod:Mod/*, modType:int*/):Boolean
		{
			if (mod == null)	{ return false; }
			
			var modType:int = mod.GetModType();
			
			if (modType == Mod.MOD_ANIMATEDCHARACTER)
			{
				var animCharacterMod:AnimatedCharacterMod = mod as AnimatedCharacterMod;
				if (animCharacterMod)
				{
					var characterData:Object = animCharacterMod.GetCharacterData();
					var character:AnimatedCharacter = new AnimatedCharacter(characterData);
					//var characterName:String = characterData;
					if (characterManager.AddCharacter(character))
					{
						mainMenu.AddIconToCharacterMenu(characterData.icon);
						TryToLoadCharacterSettings(characterData.name);
					}
				}
				
			}
			else if (modType == Mod.MOD_ANIMATION)
			{
				var animationMod:AnimationMod = mod as AnimationMod;
				if (animationMod != null)
				{
					characterManager.AddAnimationsToCharacter(animationMod.GetTargetCharacterName(), 
						animationMod.GetAnimationContainer());
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
					musicPlayer.AddMusic(music.GetMusicData(), music.GetName(), music.GetDisplayInformation(), music.GetStartLoopTime(), music.GetEndLoopTime(), music.GetStartTime());
					if (music.GetName() == userSettings.globalSongTitle)
					{
						var chosenMusicId:int = musicPlayer.GetMusicIdByName(music.GetName());
						if (chosenMusicId > -1)
						{ 
							//If totalRunFrames is 0 then the RunLoop has no started yet. This means that
							//the music player should not have been told to play music yet, so use the SetInitialMusicToPlay function.
							if (totalRunFrames == 0)
							{
								musicPlayer.SetInitialMusicToPlay(chosenMusicId);
							}
							else
							{
								musicPlayer.PlayMusic(chosenMusicId, intendedRunFrame); 
							}
							
						}
					}	
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
			//if (userSettings.limitRenderArea == true) { ToggleDrawLimiter(); }
			
			/*if (userSettings.showBackground == true)
			{
				mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = false;
			}*/
				
			
			//characterManager.GotoSelectedMenuCharacter(characterManager.GetCharacterIdByName(userSettings.currentCharacterName));
			characterManager.SetAllowingCharacterSwitching(userSettings.allowCharacterSwitches);
			characterManager.SetIfRandomlySelectingCharacter(userSettings.randomlySelectCharacter);
			musicPlayer.SetIfMusicIsEnabled(userSettings.playMusic);
			var chosenMusicId:int = musicPlayer.GetMusicIdByName(userSettings.globalSongTitle);
			if (chosenMusicId > -1) { musicPlayer.SetInitialMusicToPlay(chosenMusicId);}
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

			var charId:int = characterManager.GetCharacterIdByName(characterName);
			if (charId > -1)
			{
				//processing of character settings
				var charSettings:Object = userSettings.GetSettingsForCharacter(characterName);
				
				//Set up character to use those settings.
				characterManager.InitializeSettingsForCharacter(charId, charSettings);
				//Insert something here for menu to update
				mainMenu.SetupMenusForCharacter(charId, charSettings);
				//TODO: Make Music player handle this.
				//var musicId:int = musicPlayer.GetMusicIdByTitle(charSettings.playMusicTitle);
				//musicPlayer.ChangeSelectedMusicForCharacter(musicId);
				//characterManager.ChangeMusicForCharacter(charId, charSettings.playMusicTitle);
				if (characterName == userSettings.currentCharacterName)
				{
					var characterId:int = characterManager.SwitchToCharacter(charId);
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
			else if (textFieldName == "BackgroundText")
			{
				keybindingObj = userSettings.keyBindings.Background;
			}
			else if (textFieldName == "MusicText")
			{
				keybindingObj = userSettings.keyBindings.Music;
			}
			else if (textFieldName == "CharPrefMusicText")
			{
				keybindingObj = userSettings.keyBindings.CharPreferredMusic;
			}
			else if (textFieldName == "PrevMusicText")
			{
				keybindingObj = userSettings.keyBindings.PrevMusic;
			}
			else if (textFieldName == "NextMusicText")
			{
				keybindingObj = userSettings.keyBindings.NextMusic;
			}
			/*else if (textFieldName == "MusicForAllText")
			{
				keybindingObj = userSettings.keyBindings.MusicForAll;
			}*/
			else if (textFieldName == "ActivateText")
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
		private function GetFrameNumberToSetForAnimation():uint
		{
			return ((intendedRunFrame-1) % 120)+1;
		}
		private function AnimationTransitionOccured(e:Event):void
		{
			
			StopBackgroundAnimations();
			addEventListener(ExitLinkedAnimationEvent.EXIT_LINKED_ANIMATION, ExitingLinkedAnimation, true);
			musicPlayer.StopMusic(intendedRunFrame);
		}
		
		private function ExitingLinkedAnimation(e:Event):void
		{
			removeEventListener(ExitLinkedAnimationEvent.EXIT_LINKED_ANIMATION, ExitingLinkedAnimation, true);
			PlayBackgroundAnimations(GetFrameNumberToSetForAnimation());
			musicPlayer.PlayMusic( -2, intendedRunFrame);
		}
		[inline]
		private function StopBackgroundAnimations():void
		{
			mainStage.OuterDiamondBG.stop();
			mainStage.InnerDiamondBG.stop();
			mainStage.TransitionDiamondBG.stop();
			mainStage.BacklightBG.stop();
			//Since making the backlight invisible is a user setting and that shouldn't be interfered with, alpha will be used to hide
			//the backlight.
			mainStage.BacklightBG.visible = false;
		}
		
		[inline]
		private function PlayBackgroundAnimations(startFrame:int = 1):void
		{
			if (userSettings.showBackground == true)
			{
				mainStage.OuterDiamondBG.gotoAndPlay(startFrame);
				mainStage.InnerDiamondBG.gotoAndPlay(startFrame);
				mainStage.TransitionDiamondBG.gotoAndPlay(startFrame);
				mainStage.BacklightBG.gotoAndPlay(startFrame);
				if (userSettings.backlightOn == true)
				{
					mainStage.BacklightBG.visible = true;
				}
			}
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
		
		/*Used to make sure that the animation is synced up with the music. If the animation falls behind by more than
		2 frames then it is pushed forward to the approximate frame it should be on given the music's position.*/
		private function SkipFramesForAnimations(trueTotalRunFrame:uint):void
		{
			var frameAnimationsShouldBeOn:uint = (trueTotalRunFrame) % 120;
			if (frameAnimationsShouldBeOn == 0) { frameAnimationsShouldBeOn == 120; }
			mainStage.OuterDiamondBG.gotoAndPlay(frameAnimationsShouldBeOn);
			mainStage.InnerDiamondBG.gotoAndPlay(frameAnimationsShouldBeOn);
			mainStage.TransitionDiamondBG.gotoAndPlay(frameAnimationsShouldBeOn);
			mainStage.BacklightBG.gotoAndPlay(frameAnimationsShouldBeOn);
			characterManager.ChangeFrameOfCurrentAnimation(frameAnimationsShouldBeOn);
		}
		
		/*private function Debug_TimerHandler(e:TimerEvent):void
		{
			Debug_runTime += Debug_Timer.delay;
		}*/
	}
}