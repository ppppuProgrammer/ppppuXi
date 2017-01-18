package  
{
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	import events.AnimationTransitionEvent;
	import events.ExitLinkedAnimationEvent;
	import events.FadeToBlackTransitionEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
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
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	import mx.logging.*;
	/**
	 * Responsible for managing all the various aspects of ppppuNX (and interactive). 
	 * @author ppppuProgrammer
	 */
	public class AppCore extends MovieClip
	{
		public var mainStage:MainStage;
		//Keeps track of what keys were pressed and/or held down
		private var keyDownStatus:Array = [];
		
		/*A function lookup table that holds keycodes as the key and various Keypress_ functions as the value.
		* Used to execute the appropriate function in the event of a key press.*/
		private var keypressFunctionLookup:Dictionary;
		
		private var characterManager:CharacterManager;
		
		private const flashStartFrame:int = 2;
		private static var FadeToBlackDuration:int = 0; 
		//Main menu for the program.
		//private var charVoiceSystem:SoundEffectSystem;
		
		private var playSounds:Boolean = false;
		
		private var helpScreenMC:HelpScreen;
		private const HELP_INITIAL_FONT_SIZE:int = 14;
		
		private var displayWidthLimit:int;
		private var mainStageLoopStartFrame:int;
		
		//Settings related
		public var settingsSaveFile:SharedObject = SharedObject.getLocal("ppppuXi_Settings", "/");
		
		public var userSettings:UserSettings = new UserSettings();
		
		//Loading
		private var contentLoader:LoaderMax = new LoaderMax({name:"Content loader"});
		
		private var mainMenu:MainMenu;
		
		/*Timing*/
		/*The total amount of frames that the program has been running for. Due to being reliant on the enter frame event
		 * this number can end up being off from where it should be when slowdown happens. Should not be used
		 * for timing sensitive functions but to be used as reference for how far behind Flash is from where it should be.
		 * Think of this as "How many frames has Flash handled?"*/
		private var totalRunFrames:uint = 0;
		/*A correctional variable that keeps track of what frame the program should be on given its execution time.
		* When the intended run frame is ahead of the totalRunFrames, animation frame skipping will be done to keep
		* animations in sync with the music. Should be used for any timing sensitive functions.
		* Think of this as "How many frames should have been handled by Flash at this point given locked framerate?"*/
		private var intendedRunFrame:uint = 0;
		/*The latest intended run frame known to the program. Used to make sure that character switches won't be
		* missed due to Flash falling behind.*/
		private var lastIntendedRunFrame:uint = 0;
		private var totalRunTime:Number = 0;
		//Holds the value of how long the AVM was running from the latest completed run Loop execution 
		private var lastUpdateTime:Number = 0;
		/*The maximum amount of frames an animation can fall out of sync behind the music
		* before any animations are jumped ahead to resync.*/
		private const ANIMATION_MAX_FRAMES_BEHIND_MUSIC:int = 2;
		
		//Music
		private var musicPlayer:MusicPlayer = new MusicPlayer();
		
		private const appName:String = "ppppuXi beta";
		
		//The logging object for this class
		private var logger:ILogger;
		
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
			//Create the logger object that's used by this class to output messages.
			logger = Log.getLogger("AppCore");
			
			//Create the "main stage" that holds the character template and various other movieclips such as the transition and backlight 
			mainStage = new MainStage();
			mainStage.stop();
			addChild(mainStage);
			
			contentLoader.autoLoad = true;
			
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
			logger.info("Initializing ppppuXi");
			//Allow any uncaught errors be caught so they can be logged.
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, ErrorCatcher, false, 0);
			addEventListener(ChangeBackgroundEvent.CHANGE_BACKGROUND, ChangeBackgroundColors, true);
			addEventListener(AnimationTransitionEvent.ANIMATION_TRANSITIONED, AnimationTransitionOccured, true);
			mainStage.mouseChildren = true;
			mainStage.MenuLayer.mouseEnabled = false;
			mainStage.MenuLayer.mouseChildren = true;
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
			mainStage.FadeBlackScreen.mouseChildren = false;
			mainStage.FadeBlackScreen.mouseEnabled = false;
			mainStage.FadeBlackScreen.stop();
			FadeToBlackDuration = mainStage.FadeBlackScreen.totalFrames;
			characterManager = new CharacterManager(/*mainStage, userSettings*/);
			mainStage.x = (stage.stageWidth - mainStage.CharacterLayer.width /*- characterManager.MENUBUTTONSIZE/2*/) / 2;
			mainStage.CharacterLayer.addChild(characterManager);
			mainStage.FadeBlackScreen.addFrameScript(mainStage.FadeBlackScreen.totalFrames-1, FadeToBlackTransitionEnded);
			LoadUserSettings();
			
			
			SetupKeyFunctionLookupTable();
			
			mainMenu = new MainMenu(characterManager, musicPlayer, userSettings);
			mainMenu.visible = false;
			mainStage.MenuLayer.addChild(mainMenu);
			mainMenu.Initialize();
			mainMenu.x = -(mainStage.MenuLayer.localToGlobal(new Point).x);
			mainStage.CharacterLayer.visible = false;
			//Movie clip initialization.
			helpScreenMC = new HelpScreen();
			//setup movie clips before we start using them.
			SetupHelpMovieClip();
			
			var bbsMusicMod:M_BeepBlockSkyway = new M_BeepBlockSkyway();
			addChild(bbsMusicMod);
			removeChild(bbsMusicMod);
			ProcessMod(bbsMusicMod);
			bbsMusicMod.Dispose();
			bbsMusicMod = null;

			if (startupMods != null)
			{
				for (var i:int = 0, l:int = startupMods.length; i < l; ++i)
				{
					try
					{
						var successfulModAdd:Boolean = ProcessMod(startupMods[i]);
						if (successfulModAdd == false)
						{
							logger.warn("Mod that could not be added: " + startupMods[i].UrlLoadedFrom);
						}
					}
					catch (e:Error)
					{
						logger.error("Failed to load " + getQualifiedClassName(startupMods[i]) + "\nCall stack:\n" + e.getStackTrace());
					}
					finally
					{
						startupMods[i] = null;
					}
				}
			}
			startupMods = null;
			//Load the settings for all loaded characters
			logger.info("Applying settings to added characters");
			InitializeSettingsForCharactersLoadedAtStartup();
			logger.info("Finish applying character settings");
			//Set the first character that is to be picked according to the settings save file
			var charactersCount:int = characterManager.GetTotalNumOfCharacters();
			if ("currentCharacterName" in userSettings && userSettings.currentCharacterName.length > 0 && charactersCount > 0)
			{
				var characterId:int = characterManager.GetCharacterIdByName(userSettings.currentCharacterName);
				if (characterId > -1 && characterManager.IsCharacterLocked(characterId) == true) { characterId = -1;}
				//If the character wasn't found then iterate through the character list to find an unlocked character to pick.
				if (characterId == -1) 
				{ 
					
					var needToUnlockAllCharacters:Boolean = false;
					for (var id:int = 0; id < charactersCount; ++id)
					{
						//Initial run of the for loop to see if there is an unlocked character to use
						if (needToUnlockAllCharacters == false)
						{
							if (characterManager.IsCharacterLocked(id) == false)
							{
								characterId = id;
								break;
							}
							//Got to the end and an unlocked character was not found, so unlock all characters.
							if (id + 1 == charactersCount)
							{
								logger.warn("All loaded characters were locked. Unlocking all loaded characters.");
								needToUnlockAllCharacters = true;
								id = -1;
							}
						}
						else //2nd run of the for loop to unlock all characters.
						{
							//Toggle the lock on the character to false and update the user settings to reflect this.
							var characterName:String = characterManager.GetCharacterNameById(id);
							userSettings.UpdateSettingForCharacter_Lock(characterName, characterManager.ToggleLockOnCharacter(id));
							//Update the menu to have it show that the character is locked.
							mainMenu.SetupMenusForCharacter(id, userSettings.characterSettings[characterName]);
							//Got to the end and unlocked all characters, set the id of the first character displayed to set to 0.
							if (id + 1 == charactersCount)
							{
								characterId = 0;
							}
						}	
					}
					
				}
				characterManager.SwitchToCharacter(characterId);
			}
			logger.info("Finished initialization.");
			System.pauseForGCIfCollectionImminent(0);

			//Allow sounds to be played again (the sound mixer was silenced in the preloader)
			SoundMixer.soundTransform = new SoundTransform(1);
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

		////The "heart beat" of the flash. Ran every frame to monitor and react to certain, often frame sensitive, events.
		private function RunLoop(e:Event):void
		{

			if(totalRunFrames == 0)
			{
				if (characterManager.GetTotalNumOfCharacters() == 0 || runloopDelayCountdown > 0)
				{
					mainStage.stopAllMovieClips();
					if (runloopDelayCountdown > 0) {--runloopDelayCountdown; }
					//If no characters were loaded then the program can't run.
					if (runloopDelayCountdown == 0 && characterManager.GetTotalNumOfCharacters() == 0)
					{
						if (this.getChildByName("ErrorMsgPanel") == null)
						{
							//Need to tell the user why the program will not run.
							var errorMessage:String = "There must be one character mod loaded in order to start." + 
							"\nEnsure that ModsList.txt is in the same folder" +
							"\nppppuXi.swf is in and that there is at least" +
							"\none Animated Character mod set to be loaded.";
							var errorPanel:Panel = new Panel(this);
							errorPanel.name = "ErrorMsgPanel";
							var errorTextLabel:Label = new Label(errorPanel, 5, 5, errorMessage);
							
							var tf:TextFormat = errorTextLabel.textField.getTextFormat();
							tf.size = 14;
							tf.color = 0x000000;

							errorTextLabel.textField.defaultTextFormat = tf;
							errorTextLabel.draw();
							errorPanel.setSize(errorTextLabel.textField.textWidth + 10, errorTextLabel.textField.textHeight + 10);
							errorPanel.x = (stage.stageWidth - errorPanel.width)/2;
							errorPanel.y = (stage.stageHeight - errorPanel.height) / 2;
							
							//Log a concise version of the error message.
							logger.error("There were no characters mods loaded. ppppuXi needs at least one (1) character mod to run.");
						}
					}
				}
				else
				{
					var msgPanel:DisplayObject = this.getChildByName("ErrorMsgPanel");
					if (msgPanel != null)
					{
						this.removeChild(msgPanel);
						msgPanel = null;
					}
					//Add the key listeners
					stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyPressCheck);
					stage.addEventListener(KeyboardEvent.KEY_UP, KeyReleaseCheck);
					
					if (userSettings.firstTimeRun == true)
					{
						logger.info("A new save file for settings is being used.");
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
					mainMenu.ChangeMusicMenuDisplayedInfo(musicPlayer.PlayMusic( -2, GetCompletionTimeForAnimation()));
					lastUpdateTime = getTimer();
				}
			}
			
			if (mainStage.currentFrame == flashStartFrame)
			{
				var currentUpdateTime:Number = getTimer();
				/*The latest intended run frame known to the program. Used to make sure that character switches won't be
				* missed due to Flash falling behind.*/
				totalRunTime += (currentUpdateTime - lastUpdateTime);
				//trace("current: " + currentUpdateTime + ", last: " + lastUpdateTime + ", delta: " + delta + ", total: " + totalRunTime);
				lastUpdateTime = currentUpdateTime;
				
				++totalRunFrames;
				//++updatesSinceLastSkip;
				intendedRunFrame = (totalRunTime / (1000.0 / stage.frameRate)) + 1;
				//character switch skip check
				var skippedCharacterSwitchFrame:Boolean = false;

				//Frame skipping can only happen if an end link animation is not playing.
				if (characterManager.CheckIfTransitionLockIsActive() == false)
				{
					if (intendedRunFrame > totalRunFrames + ANIMATION_MAX_FRAMES_BEHIND_MUSIC )
					{
						//For when the animation falls too far behind and needs to be immediately resynced.
						
						if (int((intendedRunFrame - 1) / 120) > int((lastIntendedRunFrame - 1) / 120))
						{
							skippedCharacterSwitchFrame = true;
						}
						SkipFramesForAnimations(intendedRunFrame);
						totalRunFrames = intendedRunFrame;
						//updatesSinceLastSkip = 0;
					}
					else if ((intendedRunFrame - 1) % 120 != 0 && int((intendedRunFrame - 1) / 120) > int((lastIntendedRunFrame - 1) / 120))
					{
						//Flash fell behind and the intended run frame has now jumped over a designated character switch frame (every 121 frames)
						//Force a frame skip and set it so it's known that a character switch was skipped
						skippedCharacterSwitchFrame = true;
						SkipFramesForAnimations(intendedRunFrame);
						totalRunFrames = intendedRunFrame;
						//updatesSinceLastSkip = 0;
					}
				}

				var animationFrame:uint = GetFrameNumberToSetForAnimation(); //The frame that an animation should be on. Animations are typically 120 frames / 4 seconds long
				mainMenu.UpdateTimingsForAnimation(animationFrame, GetCompletionTimeForAnimation());
				
				mainStage.CharacterLayer.visible = true;
				if (userSettings.showBackground == true)
				{
					mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = true;
				}
				
				if(animationFrame == 1 || skippedCharacterSwitchFrame == true) //Add character clip
				{
					if(characterManager.AreCharacterSwitchesAllowed())
					{
						/* The first run frame should not have the character switch logic run.
						 * This is so the initial character set (which is the last character on screen the previous
						 * time the program was ran or the first character loaded if the settings save file wasn't found)
						 * isn't switch from and give them a chance to be seen as intended.*/
						if (totalRunFrames != 1) {characterManager.CharacterSwitchLogic();}
					}
					
					var charsWereSwitched:Boolean = characterManager.UpdateAndDisplayCurrentCharacter(animationFrame);
					if (charsWereSwitched == true)
					{
						
						//userSettings.UpdateCurrentCharacterName(characterManager.GetCurrentCharacterName());
						//Make sure that there is no way for all accessible animations to be locked.
						characterManager.CheckLocksForCurrentCharacter();
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
				lastIntendedRunFrame = intendedRunFrame;
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
			if(keyPressed in keypressFunctionLookup && (keyDownStatus[keyPressed] == undefined || keyDownStatus[keyPressed] == false || (keyPressed == 48 || keyPressed == 96)))
			{
				keypressFunctionLookup[keyPressed](keyPressed);
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
				PlayBackgroundAnimations(GetFrameNumberToSetForAnimation());
			}
			
		}
		
		private function SetBackLight(visible:Boolean):void
		{
			userSettings.UpdateShowingBacklight(visible);
			
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
		
		/*MODIFICATION SYSTEM RELATED FUNCTIONS*/
		
		/*private function FinishedLoadingSWF(e:LoaderEvent):void
		{
			var mod:Mod = (e.target.content.rawContent as Mod);
			//Add the mod to the stage so the first frame function can get started, allowing the content to be ready to be used.
			addChild(mod);
			
			//A singular mod. Just need to process it.
			ProcessMod(mod);
			
			//remove the mod file.
			removeChild(mod);
			mod = null;
		}*/
		
		/*Processes a mod and then adds it into ppppu. Returns true if mod was successfully added and false if a problem was encounter
		and the mod could not be added.*/
		private function ProcessMod(mod:Mod/*, modType:int*/):Boolean
		{
			var modClassName:String = getQualifiedClassName(mod);
			var addedMod:Boolean = false;
			if (mod == null)
			{
				logger.warn(modClassName + " is not a ppppuXi mod!");
				return addedMod;
			}
			
			var modType:int = mod.GetModType();
			
			if (modType == Mod.MOD_ANIMATEDCHARACTER)
			{
				var animCharacterMod:AnimatedCharacterMod = mod as AnimatedCharacterMod;
				animCharacterMod.ValidateData();
				if (animCharacterMod)
				{
					var characterData:Object = animCharacterMod.GetCharacterData();
					var character:AnimatedCharacter = new AnimatedCharacter(characterData);

					/*To avoid a situation where character isn't added then their icon fails to be added, first a character
					 * is verified if they can be added then the icon is added. If both these tasks are completed successfully then
					 * the character is added.*/
					var characterCanBeAdded:Boolean = characterManager.CheckIfCharacterCanBeAdded(character);
					if (characterCanBeAdded == true)
					{
						mainMenu.AddIconToCharacterMenu(characterData.icon);
						var addedCharacterId:int = characterManager.AddCharacter(character);
						addedMod = true;
						logger.info("Successfully added character: " +  character.GetName());
						if(totalRunFrames > 0)	{TryToLoadCharacterSettings(addedCharacterId);}
					}
					else
					{
						logger.warn("Failed to add character: " + character.GetName());
					}
				}
				else
				{
					logger.error(modClassName + " was not a valid animated character mod.");
				}
			}
			else if (modType == Mod.MOD_ANIMATION)
			{
				var animationMod:AnimationMod = mod as AnimationMod;
				if (animationMod != null)
				{
					//logger.info("Processing Animation Mod: " + modClassName);
					
					var targetCharacterGroup:String = animationMod.GetTargetCharacterName();
					var modifiedCharactersString:String = "";
					var targetCharacter:String;
					for (var x:int = 0, y:int = characterManager.GetTotalNumOfCharacters(); x < y; ++x)
					{
						targetCharacter = characterManager.GetCharacterNameById(x);
						//Check if the character belongs to the targetted group
						if (characterManager.GetGroupNameForCharacter(x) == targetCharacterGroup)
						{
							characterManager.AddAnimationsToCharacter(targetCharacter, 
						animationMod.GetAnimationContainer());
							modifiedCharactersString += (modifiedCharactersString.length == 0 ? targetCharacter : ", " + targetCharacter);
						}
					}
					
					addedMod = true;
					logger.info("Added animations to group {0} ({1}) from {2}", targetCharacterGroup, modifiedCharactersString, modClassName);
				}
				else
				{
					logger.error(modClassName + " was not a valid animation mod.");
				}
			}
			else if (modType == Mod.MOD_TEMPLATECHARACTER)
			{
				//Not used in interactive versions
				logger.error("TemplateCharacter mods are only to be loaded by ppppuNX");
			}
			else if (modType == Mod.MOD_MUSIC)
			{
				var music:MusicMod = mod as MusicMod;
				if (music)
				{
					//logger.info("Processing Music Mod: " + modClassName);
					if (musicPlayer.AddMusic(music.GetMusicData(), music.GetName(), music.GetDisplayInformation(), music.GetStartLoopTime(), music.GetEndLoopTime(), music.GetStartTime()))
					{
						addedMod = true;
						logger.info("Music " + music.GetName() + " was successfully added");
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
									musicPlayer.PlayMusic(chosenMusicId, GetCompletionTimeForAnimation()); 
								}
								
							}
						}	
					}
					else
					{
						logger.info("Failed to add music: " + music.GetName());
					}
				}
				else
				{
					logger.error(modClassName + " was not a valid archive mod.");
				}
			}
			else if (modType == Mod.MOD_ASSETS)
			{
				//Not used in interactive versions
				logger.error("Asset mods are only to be loaded by ppppuNX");
			}
			//If the mod type is an archive we'll need to iterate through the mod list it has and process them seperately
			else if (modType == Mod.MOD_ARCHIVE)
			{
				var archive:ModArchive = mod as ModArchive;
				if (archive)
				{
					
					logger.info("\t* Processing archive mod: " + modClassName + "*");
					var archiveModList:Vector.<Mod> = archive.GetModsList();
					var childMod:Mod;
					for (var i:int = 0, l:int = archiveModList.length; i < l; ++i)
					{
						childMod = archiveModList[i];
						ProcessMod(childMod);
					}
					addedMod = true;
					logger.info("\t* Finished processing archive mod " + modClassName + "*");
				}
				else 
				{
					logger.error(modClassName + " was not a valid archive mod.");
				}
			}
			else
			{
				logger.error(modClassName + " was an unrecognized ppppuXi mod.");
			}
			mod.Dispose();
			mod = null;
			return addedMod;
		}
		
		/*SETTINGS RELATED FUNCTIONS*/
		public function SaveSettingsToDisk(e:events.SaveRequestEvent):void
		{
			if (helpScreenMC.visible)
			{
				UpdateKeyBindsForHelpScreen();
			}
			settingsSaveFile.flush();
			//Need to update the key function lookup table for the new keycodes
			SetupKeyFunctionLookupTable();
		}
		
		private function LoadUserSettings():void
		{
			logger.info("Loading user settings");
			if (settingsSaveFile.data.ppppuSettings != null)
			{
				if (userSettings.SAVE_VERSION == settingsSaveFile.data.ppppuSettings.version)
				{
					userSettings.ConvertFromObject(settingsSaveFile.data.ppppuSettings);
					//Something went terribly wrong, recreate the user settings
					
					if (userSettings == null) 
					{ 
						logger.warn("Settings were not loaded correctly. Recreating user settings.");
						userSettings = new UserSettings(); 
					}
					else
					{
						logger.info("User Settings were loaded successfully.");
					}
				}
				else
				{
					logger.warn("Out of date settings version found, settings have been reset to their default values.");
					settingsSaveFile.clear();
				}
				settingsSaveFile.data.ppppuSettings = userSettings;
			}
			
			characterManager.SetAllowingCharacterSwitching(userSettings.allowCharacterSwitches);
			characterManager.SetIfRandomlySelectingCharacter(userSettings.randomlySelectCharacter);
			musicPlayer.SetIfMusicIsEnabled(userSettings.playMusic);
			var chosenMusicId:int = musicPlayer.GetMusicIdByName(userSettings.globalSongTitle);
			if (chosenMusicId > -1) { musicPlayer.SetInitialMusicToPlay(chosenMusicId);}			
		}
		[inline]
		private function TryToLoadCharacterSettings(characterId:int):void
		{
			if (characterId < 0 || characterId >= characterManager.GetTotalNumOfCharacters()) { return; }
			
			var characterName:String = characterManager.GetCharacterNameById(characterId);
			if (userSettings.CheckIfCharacterHasSettings(characterName) == false)
			{
				userSettings.CreateSettingsForNewCharacter(characterName);
			}

			var charId:int = characterManager.GetCharacterIdByName(characterName);
			//processing of character settings
			var charSettings:Object = userSettings.GetSettingsForCharacter(characterName);
			
			//Set up character to use those settings.
			characterManager.InitializeSettingsForCharacter(charId, charSettings);
			//Insert something here for menu to update
			mainMenu.SetupMenusForCharacter(charId, charSettings);
		}
		
		private function InitializeSettingsForCharactersLoadedAtStartup():void
		{
			var charSettings:Object;
			var characterName:String;
			for (var i:int = 0, l:int = characterManager.GetTotalNumOfCharacters(); i < l; i++) 
			{
				TryToLoadCharacterSettings(i);
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
		
		[inline]
		private function GetCompletionTimeForAnimation():Number
		{
			return totalRunTime % 4000;
		}
		
		private function AnimationTransitionOccured(e:Event):void
		{
			StopBackgroundAnimations();
			addEventListener(ExitLinkedAnimationEvent.EXIT_LINKED_ANIMATION, ExitingLinkedAnimation, true);
			addEventListener(FadeToBlackTransitionEvent.FADETOBLACK_TRANSITION, StartFadeToBlackTransition, true);
			
			musicPlayer.StopMusic();
		}
		
		private function ExitingLinkedAnimation(e:Event):void
		{
			removeEventListener(ExitLinkedAnimationEvent.EXIT_LINKED_ANIMATION, ExitingLinkedAnimation, true);
			PlayBackgroundAnimations(GetFrameNumberToSetForAnimation());
			mainStage.FadeBlackScreen.gotoAndStop(1);
			musicPlayer.PlayMusic( -2, GetCompletionTimeForAnimation());
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
		
		//Catches all errors not caught by another handler and has the logger record the error and the call stack
		private function ErrorCatcher(e:UncaughtErrorEvent):void
		{
			logger.error(e.error.message + "\n" + e.error.getStackTrace());
		}
		
		/**/
		private function StartFadeToBlackTransition(e:Event):void
		{
			removeEventListener(FadeToBlackTransitionEvent.FADETOBLACK_TRANSITION, StartFadeToBlackTransition, true);
			mainStage.FadeBlackScreen.play();
		}
		
		private function FadeToBlackTransitionEnded():void
		{
			//After an animation transition, a random animation of the character is selected.
			mainMenu.SelectAnimation(null, -1);
			//Actually allow 
			//characterManager.AllowChangeOutOfLinkedAnimation();
			
			
			//mainStage.FadeBlackScreen.gotoAndStop(1);
		}
		
		public static function GetFadeToBlackTransitionDuration():int
		{
			return FadeToBlackDuration;
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
			//Done so the range that'll be selected is 1-120.
			var frameAnimationsShouldBeOn:uint = ((trueTotalRunFrame-1) % 120) + 1;
			
			mainStage.OuterDiamondBG.gotoAndPlay(frameAnimationsShouldBeOn);
			mainStage.InnerDiamondBG.gotoAndPlay(frameAnimationsShouldBeOn);
			mainStage.TransitionDiamondBG.gotoAndPlay(frameAnimationsShouldBeOn);
			mainStage.BacklightBG.gotoAndPlay(frameAnimationsShouldBeOn);
			characterManager.ChangeFrameOfCurrentAnimation(frameAnimationsShouldBeOn);
		}
		
		/* Key Press Functions*/
		
		/*Setups the key function lookup table, which is used by the keypressCheck function to execute the appropriate
		 * keypress_ function based on the key pressed. This must be called whenever the keybinds are changed or the
		 * lookup table will not reflect the changes made to the keybinds.*/
		private function SetupKeyFunctionLookupTable():void
		{
			keypressFunctionLookup = new Dictionary();
			var keyBindings:Object = userSettings.keyBindings;
			keypressFunctionLookup[Keyboard.NUMBER_0] = keypressFunctionLookup[Keyboard.NUMPAD_0] = KeyPress_RandomChangeAnimation;
			for (var i:int = 0, l:int = 9; i < l; ++i)
			{
				keypressFunctionLookup[Keyboard.NUMBER_1+i] = keypressFunctionLookup[Keyboard.NUMPAD_1+i] = KeyPress_ChangeAnimation;
			}
			keypressFunctionLookup[keyBindings.AutoCharSwitch.main] = keypressFunctionLookup[keyBindings.AutoCharSwitch.alt] = KeyPress_AutomaticCharacterSwitch;
			keypressFunctionLookup[keyBindings.PrevAnimPage.main] = keypressFunctionLookup[keyBindings.PrevAnimPage.alt] = KeyPress_PreviousAnimationPage;
			keypressFunctionLookup[keyBindings.NextAnimPage.main] = keypressFunctionLookup[keyBindings.NextAnimPage.alt] = KeyPress_NextAnimationPage;
			keypressFunctionLookup[keyBindings.AnimLockMode.main] = keypressFunctionLookup[keyBindings.AnimLockMode.alt] = KeyPress_AnimationLockMode;
			keypressFunctionLookup[keyBindings.LockChar.main] = keypressFunctionLookup[keyBindings.LockChar.alt] = KeyPress_LockCharacter;
			keypressFunctionLookup[keyBindings.GotoChar.main] = keypressFunctionLookup[keyBindings.GotoChar.alt] = KeyPress_SwitchToCharacter;
			keypressFunctionLookup[keyBindings.CharCursorPrev.main] = keypressFunctionLookup[keyBindings.CharCursorPrev.alt] = KeyPress_MoveCharacterCursorBack;
			keypressFunctionLookup[keyBindings.CharCursorNext.main] = keypressFunctionLookup[keyBindings.CharCursorNext.alt] = KeyPress_MoveCharacterCursorForward;
			keypressFunctionLookup[keyBindings.RandomChar.main] = keypressFunctionLookup[keyBindings.RandomChar.alt] = KeyPress_SelectRandomCharacter;
			keypressFunctionLookup[keyBindings.Menu.main] = keypressFunctionLookup[keyBindings.Menu.alt] = KeyPress_Menu;
			keypressFunctionLookup[keyBindings.Help.main] = keypressFunctionLookup[keyBindings.Help.alt] = KeyPress_Help;
			keypressFunctionLookup[keyBindings.Backlight.main] = keypressFunctionLookup[keyBindings.Backlight.alt] = KeyPress_Backlight;
			keypressFunctionLookup[keyBindings.Background.main] = keypressFunctionLookup[keyBindings.Background.alt] = KeyPress_Background;
			keypressFunctionLookup[keyBindings.Music.main] = keypressFunctionLookup[keyBindings.Music.alt] = KeyPress_Music;
			keypressFunctionLookup[keyBindings.CharPreferredMusic.main] = keypressFunctionLookup[keyBindings.CharPreferredMusic.alt] = KeyPress_CharacterPreferredMusic;
			keypressFunctionLookup[keyBindings.NextHelpPage.main] = keypressFunctionLookup[keyBindings.NextHelpPage.alt] = KeyPress_NextHelpPage;
			keypressFunctionLookup[keyBindings.PrevMusic.main] = keypressFunctionLookup[keyBindings.PrevMusic.alt] = KeyPress_ChangeToPrevMusic;
			keypressFunctionLookup[keyBindings.NextMusic.main] = keypressFunctionLookup[keyBindings.NextMusic.alt] = KeyPress_ChangeToNextMusic;
			keypressFunctionLookup[keyBindings.Activate.main] = keypressFunctionLookup[keyBindings.Activate.alt] = KeyPress_ActivateAnimationTransition;
			
			//Debug test key functions
			CONFIG::debug
			{
				keypressFunctionLookup[Keyboard.END] = KeyPressDEBUG_GotoLastSectionForMusic;
			}
			
		}
		private function KeyPress_RandomChangeAnimation(keycode:int):void
		{
			mainMenu.SelectAnimation(null, -1);
		}
		
		private function KeyPress_ChangeAnimation(keycode:int):void
		{
			//keypress of 1 has a keycode of 49
			if(keycode > 96)
			{
				keycode = keycode - 48;
			}
			//AnimationIndex 
			
			var animationIndex:int = keycode - 49; 
			mainMenu.SelectAnimation(null, animationIndex);
		}
		private function KeyPress_AutomaticCharacterSwitch(keycode:int):void
		{
			var charSwitchingAllowed:Boolean = characterManager.SetAllowingCharacterSwitching(!characterManager.AreCharacterSwitchesAllowed());
			mainMenu.UpdateModeForCharacterSwitchButton(charSwitchingAllowed ? "Normal" : "Single" );
			userSettings.UpdateCharacterSwitching(charSwitchingAllowed);
			userSettings.UpdateRandomCharacterSelecting(characterManager.IsRandomlySelectingCharacter());
		}
		private function KeyPress_PreviousAnimationPage(keycode:int):void
		{
			//Try to go to the previous page of animations
			mainMenu.ChangeThe9ItemsDisplayedForAnimations(false);
		}
		private function KeyPress_NextAnimationPage(keycode:int):void
		{
			//Try to go to the next page of animations
			mainMenu.ChangeThe9ItemsDisplayedForAnimations(true);
		}
		private function KeyPress_AnimationLockMode(keycode:int):void
		{
			//toggle animation lock/goto mode
			mainMenu.ToggleAnimationMenuKeyboardMode();
		}
		private function KeyPress_LockCharacter(keycode:int):void
		{
			//(Un)lock the character who the menu cursor is on
			mainMenu.SetCharacterLock();
		}
		private function KeyPress_SwitchToCharacter(keycode:int):void
		{
			//Go to the character who the menu cursor is on
			mainMenu.SelectCharacter();
		}
		private function KeyPress_MoveCharacterCursorBack(keycode:int):void
		{
			//Move menu cursor to the character above
			mainMenu.MoveCharacterSelector(-1);
		}
		private function KeyPress_MoveCharacterCursorForward(keycode:int):void
		{
			//Move menu cursor to the character below
			mainMenu.MoveCharacterSelector(1);
		}
		private function KeyPress_SelectRandomCharacter(keycode:int):void
		{
			//Toggles random character switching
			var randomCharSelect:Boolean = characterManager.SetIfRandomlySelectingCharacter(!characterManager.IsRandomlySelectingCharacter());
			mainMenu.UpdateModeForCharacterSwitchButton(randomCharSelect ? "Random" : "Normal");
			userSettings.UpdateCharacterSwitching(characterManager.AreCharacterSwitchesAllowed());
			userSettings.UpdateRandomCharacterSelecting(randomCharSelect);
		}
		private function KeyPress_Menu(keycode:int):void
		{
			mainMenu.visible = !mainMenu.visible;
			userSettings.UpdateMenuVisibility(mainMenu.visible);
		}
		private function KeyPress_Help(keycode:int):void
		{
			ToggleHelpScreen();
		}
		private function KeyPress_Backlight(keycode:int):void
		{
			SetBackLight(!userSettings.backlightOn);
		}
		private function KeyPress_Background(keycode:int):void
		{
			ChangeBackgroundVisibility(!userSettings.showBackground);
		}
		private function KeyPress_Music(keycode:int):void
		{
			var musicEnabled:Boolean = musicPlayer.SetIfMusicIsEnabled(!musicPlayer.IsMusicPlaying());
			mainMenu.UpdateMusicEnabledButtonForMusicMenu(musicEnabled);
			userSettings.playMusic = musicEnabled;
			var displayText:String = musicPlayer.PlayMusic( -2, GetCompletionTimeForAnimation());
			mainMenu.ChangeMusicMenuDisplayedInfo(displayText);
		}
		private function KeyPress_CharacterPreferredMusic(keycode:int):void
		{
			var musicId:int = musicPlayer.GetMusicIdByName(characterManager.GetPreferredMusicForCurrentCharacter());
			if (musicId > -1)
			{
				var musicDisplayInfo:String = musicPlayer.PlayMusic(musicId, GetCompletionTimeForAnimation());
				mainMenu.ChangeMusicMenuDisplayedInfo(musicDisplayInfo);
				userSettings.globalSongTitle = musicPlayer.GetNameOfCurrentMusic();
			}
		}
		private function KeyPress_NextHelpPage(keycode:int):void
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
		private function KeyPress_ChangeToPrevMusic(keycode:int):void
		{
			mainMenu.ChangeMusicMenuDisplayedInfo(musicPlayer.ChangeToPrevMusic(GetCompletionTimeForAnimation()));
			userSettings.globalSongTitle = musicPlayer.GetNameOfCurrentMusic();
		}
		private function KeyPress_ChangeToNextMusic(keycode:int):void
		{
			mainMenu.ChangeMusicMenuDisplayedInfo(musicPlayer.ChangeToNextMusic(GetCompletionTimeForAnimation()));
			userSettings.globalSongTitle = musicPlayer.GetNameOfCurrentMusic();
		}
		private function KeyPress_ActivateAnimationTransition(keycode:int):void
		{
			characterManager.ActivateAnimationChange();
		}
		CONFIG::debug
		{
			private function KeyPressDEBUG_GotoLastSectionForMusic(keycode:int):void
			{
				musicPlayer.DEBUG_GoToMusicLastSection(GetCompletionTimeForAnimation());
			}
		}
		
	}
}