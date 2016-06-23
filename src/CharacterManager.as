package  {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	//import ppppu.Character;
	//import ppppu.MenuButton;
	//import ppppu.MusicManager;
	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	import flash.display.InteractiveObject;
	import flash.utils.getDefinitionByName;
	
	public class CharacterManager
	{
		private var m_charNamesDict:Dictionary; //Maps the character's name to an id number(int) (ie. "Peach" has an id of 0)
		private var m_Characters:Vector.<AnimatedCharacter>;
		//The main movie clip that will display pretty much everything in the flash.
		private var m_mainStage:MainStage = null;
		
		//private var m_showBacklight:Boolean = true;
		//private var m_showBackground:Boolean = true;
		
		private var m_canAddCharacters:Boolean = true;
		//Disables the char menu and hides both the char menu and the animation menu (though this menu is not disabled, so 
		private var m_menuEnabled:Boolean = true;
		
		private var m_addedCharactersCount:int = 0;
		private var m_currentCharacterId:int = 0;
		private var m_latestCharacterIdOnStage:int = -1;
		private var m_allowCharSwitches:Boolean = true;
		private var m_selectRandomChar:Boolean = false;
		private var m_canSwitchToCharacter:Vector.<Boolean>;
		private var m_characterMenuButton:Vector.<MenuButton>;
		public const MENUBUTTONSIZE:int = 32;
		private const MENUBUTTONMAXPOS_Y:int = 720;
		private var m_unswitchableCharactersNum:int = 0;
		private var m_randomButton:RandomButton = new RandomButton();
		private var m_menuCursor:Sprite;
		private var m_menuCursorPos:int = 0;
		private var m_lockedButtonColor:ColorTransform = new ColorTransform(1.0,1.0,1.0,.5);
		private var m_defaultLightColor:ColorTransform = new ColorTransform(.62,1.0,1.0,.5, -59, 22, 102,0); //For anything that needs to reset back to its default color
		private var m_charLockButton:CharLockButton = new CharLockButton();
		
		//"global" character and animation switch lock. Meant to be used for linked animation transitions so that they happen uninterrupted.
		private var transitionLockout:Boolean = false;
		
		private const CHARMENUCOMMAND_CHANGECHAR:String = "CharChange";
		private const CHARMENUCOMMAND_RANDOMCHAR:String = "RandomChar";
		private const CHARMENUCOMMAND_NOSWITCH:String = "NoSwitching";
		
		//animation menu 
		private const MAXANIMATIONSELECTBOXES:int = 9;
		
		private var m_animationMenu:Vector.<MenuButton> = new Vector.<MenuButton>(MAXANIMATIONSELECTBOXES, false);
		private const MENUBLOCKSIZE:int = 32;// 24;
		private const BLOCKTEXTFIELDNAME:String = "AnimNumber"; 
		private var m_animationLockMode:Boolean = false;
		private var m_animationPage:int = 0;
		private const ANIMMENUCOMMAND_CHANGEANIM:String = "AnimChange";
		private const ANIMMENUCOMMAND_MUSICVOLUME:String = "MusicVol";
		private const ANIMMENUCOMMAND_RANDOMANIM:String = "RandomAnim";
		private const ANIMMENUCOMMAND_DEFAULTMUSIC:String = "DefaultMusic";
		private const ANIMMENUCOMMAND_MUSIC_FOR_EACH_OR_ALL:String = "SongsForOneOrAll";
		private var randomBlock:QuestionBlockButton = new QuestionBlockButton();
		
		private var keyButton:KeySprite = new KeySprite();
		
		//font
		private var sm256Font:SuperMarioFont = new SuperMarioFont();
		
		//Music related
		public var musicPlayer:MusicPlayer = new MusicPlayer();
		private const MISCMENUCOMMAND_NEXTMUSIC:String = "NextMusic";
		private const MISCMENUCOMMAND_PREVMUSIC:String = "PrevMusic";
		private var musicInfoText:TextField;
		private var textBackground:Sprite;
		private var m_musicVolumeButton:MusicBlockButton = new MusicBlockButton();
		private var m_dynamicMusicButton:DynamicMusicBlockButton = new DynamicMusicBlockButton();
		private var nextMusicChangeButton:MusicChangeBlockButton;
		private var prevMusicChangeButton:MusicChangeBlockButton;
		private var musicForEachOrAllButton:SongForOneOrAllButton = new SongForOneOrAllButton();
		//Associates a Sound object with the given class name for it
		private var m_musicClassDictionary:Dictionary = new Dictionary();
		
		//Settings related
		private var m_settingsButton:SettingsButton = new SettingsButton();
		private const MISCMENUCOMMAND_SETTINGS:String = "Settings";
		private var keyConfig:Config;
		private var userSettings:UserSettings;
		
		//Mouse/Touch related
		//The button that mouse/touch device was over when the mouse down event was processed.
		private var m_initialButtonDown:MenuButton = null;
		//The latest button that was ran over by the mouse/touch device. Planned to be used for tooltips
		//private var m_latestButtonOver:MenuButton = null;
		private var MINIMUM_HORIZONTAL_SWIPE_DISTANCE:Number;
		private var MINIMUM_VERTICAL_SWIPE_DISTANCE:Number;
		public function CharacterManager(mainClip:MainStage, settings:UserSettings) :void
		{
			m_mainStage = mainClip;
			if(m_mainStage == null)
			{
				throw new Error("Unrecoverable error! Character manager was not given access to the movie clip that will display all the flash contents.");
			}
			userSettings = settings;
			//The vectors
			m_charNamesDict = new Dictionary();
			m_Characters = new Vector.<AnimatedCharacter>();
			m_canSwitchToCharacter = new Vector.<Boolean>();
			m_characterMenuButton = new Vector.<MenuButton>();
			//musicForEachOrAllButton.ButtonGraphic.gotoAndStop("One");
			
			MINIMUM_HORIZONTAL_SWIPE_DISTANCE = m_mainStage.stage.stageWidth * .20;
			MINIMUM_VERTICAL_SWIPE_DISTANCE = m_mainStage.stage.stageWidth * .15;
			/*if (Capabilities.touchscreenType != TouchscreenType.NONE)
			{
				m_systemHasTouchScreen = true;
			}*/
		}
		
		/*Adds a new character to be able to be shown. Returns true if the character was added successfully. Returns false if the
		character was missing necessary data or there was a character name conflict.*/
		public function AddCharacter(character:AnimatedCharacter):Boolean
		{
			//Make sure no character with this name already exists.
			for (var x:int = 0, y:int = m_Characters.length; x < y; ++x)
			{
				if (character.GetName() == m_Characters[x].GetName())
				{
					return false;
				}
			}
			
			if(character.HasNecessaryData() == true)
			{
				//Do some processing on the menu button to make standardize it for the menu.
				m_characterMenuButton[m_Characters.length] = character.GetButton(); 
				
				/*var characterAnimations:MovieClip = character.GetCharacterAnimations();
				if(characterAnimations)
				{
					characterAnimations.mouseEnabled = false;
					characterAnimations.mouseChildren = false;
				}*/
				m_charNamesDict[character.GetName()] = m_Characters.length;
				//m_charNames[charNames.length] = name;
				m_canSwitchToCharacter[m_Characters.length] = true;
				m_Characters[m_Characters.length] = character;
				++m_addedCharactersCount;
				
				/*var animationLockVector:Vector.<Boolean> = new Vector.<Boolean>();
				for (var i:int = 0, l:int = character.GetNumberOfAnimations(); i < l;++i)
				{
					animationLockVector[i] = false;
				}*/
				var charName:String = character.GetName();
				//userSettings.characterSettings[charName] = new Object();
				//userSettings.characterSettings[charName].animationLocked = new Object();
				//userSettings.characterSettings[charName].canSwitchTo = true;
				/*for (var i:int = 0, l:int = character.GetNumberOfAnimations(); i < l;++i)
				{
					userSettings.characterSettings[charName].animationLocked[i.toString()] = false;
				}
				userSettings.characterSettings[charName].playMusicTitle = character.GetDefaultMusicName();
				userSettings.characterSettings[charName].animationSelect = 0; //0 is randomly choose, value > 0 is a specific animation*/
				return true;
			}
			return false;
		}
		
		public function GetCharacterLockById(id:int):Boolean
		{
			return m_canSwitchToCharacter[id];
		}
		
		//Returns a vector of the can switch to status of all the characters
		public function GetAllCharacterLocks():Vector.<Boolean>
		{
			return m_canSwitchToCharacter;
		}
		
		public function ChangeGlobalMusicForAllCharacters(musicTitle:String):void
		{
			var musicId:int = musicPlayer.GetMusicIdByTitle(musicTitle);
			musicPlayer.ChangeGlobalMusic(musicId);
			if (musicId == -1)
			{
				musicTitle = musicPlayer.DEFAULTSONGTITLE;
			}
			userSettings.globalSongTitle = musicTitle;
		}
		public function ChangeMusicForCharacter(charId:int, musicTitle:String):void
		{
			/*if (charId > m_Characters.length || charId < 0) { return; }
			//If music title isn't found, the music played returns to the default. So just make sure that the music change was successful
			var musicId:int = musicPlayer.GetMusicIdByTitle(musicTitle);
			musicPlayer.ChangeSelectedMusicForCharacter(charId, musicId);
			
			if (musicId == -1)
			{
				musicTitle = musicPlayer.DEFAULTSONGTITLE;
			}
			
			if (musicPlayer.GetGlobalSongStatus() == false)
			{
				userSettings.characterSettings[GetCharacterById(charId).GetName()].playMusicTitle = musicTitle;
			}
			else
			{
				userSettings.globalSongTitle = musicTitle;
			}*/
		}
		
		/*public function SetupMusicForCharacters():void
		{
			for each(var character:AnimatedCharacter in m_Characters)
			{
				AddMusicForCharacter(character);
			}
		}*/
		
		/*public function AddMusicForCharacter(character:AnimatedCharacter):void
		{
			var charId:int; 
			var characterName:String = character.GetName();
			var musicClassName:String = character.GetMusicClassName();
			
			if (musicClassName == null || musicClassName.length == 0) { return;}
			
			var characterBGM:Sound = null;
			if (musicClassName in m_musicClassDictionary)
			{
				characterBGM = m_musicClassDictionary[musicClassName];
			}
			if (characterBGM == null)
			{
				//Get the as3 class for the Sound. Tries to get high quality version first
				var musicClass:Class;
				var musicName:String = character.GetMusicTitle();
				if (musicName == null || musicName.length == 0) { musicName = "Unknown"; }
				
				try
				{
					musicClass = getDefinitionByName(musicClassName) as Class;
				}
				catch (e:ReferenceError)
				{
					musicClass = null;
					trace("An error occured when attempting to access Class \"" + musicClassName + "\" for character \"" + character.GetName() + "\".\n Check that the Class was compiled into the swf and try again.");
				}
				if (musicClass)
				{
					characterBGM = new musicClass();
				}
			}
			if (characterBGM != null)
			{
				m_musicClassDictionary[musicClassName] = characterBGM;
				if(m_charNamesDict[characterName] != null)
				{
					charId = m_charNamesDict[characterName]
				}
				else
				{
					charId = -1;
				}
				if(characterBGM != null && charId >= 0)
				{
					musicManager.AddMusic(charId, characterBGM, musicName, character.GetMusicLoopStartPoint(), 
						character.GetMusicLoopEndPoint(), character.GetMusicStartPoint());
				}
			}
		}*/
		public function InitializeMusicManager(movieclipWithMusic:MovieClip, frameRate:Number):void
		{
			var menuContainingMovieclip:MovieClip = m_mainStage.MenuLayer;
			var stageHeight:int = menuContainingMovieclip.stage.stageHeight;
			var distanceFromStageEdge:Number = menuContainingMovieclip.x;
			//Create buttons for music changing
			prevMusicChangeButton = new MusicChangeBlockButton();
			prevMusicChangeButton.width = MENUBUTTONSIZE;
			prevMusicChangeButton.height = MENUBUTTONSIZE;
			prevMusicChangeButton.SetButtonFunction(MenuButton.TYPE_MISC, MISCMENUCOMMAND_PREVMUSIC);
			PrepareMenuButton(prevMusicChangeButton);
			//var buttonPoint:Point = new Point((prevMusicChangeButton.width/2), stageHeight-(prevMusicChangeButton.height/2));
			//ConvertGlobalToLocalPoint(clip, buttonPoint);
			//prevMusicChangeButton.x = distanceFromStageEdge+(prevMusicChangeButton.width/2);
			//prevMusicChangeButton.y = stageHeight-(prevMusicChangeButton.height/2);
			prevMusicChangeButton.x  = (prevMusicChangeButton.width/2);
			prevMusicChangeButton.y = stageHeight-(prevMusicChangeButton.height/2);
			prevMusicChangeButton.rotation = 180;
			prevMusicChangeButton.SetHitArea(new SquareBtnHitArea(prevMusicChangeButton.width, prevMusicChangeButton.height, -(prevMusicChangeButton.width/2), -(prevMusicChangeButton.height/2)));
			menuContainingMovieclip.addChild(prevMusicChangeButton); 
			
			nextMusicChangeButton = new MusicChangeBlockButton();
			nextMusicChangeButton.width = MENUBUTTONSIZE;
			nextMusicChangeButton.height = MENUBUTTONSIZE;
			nextMusicChangeButton.SetButtonFunction(MenuButton.TYPE_MISC, MISCMENUCOMMAND_NEXTMUSIC);
			PrepareMenuButton(nextMusicChangeButton);
			nextMusicChangeButton.x = menuContainingMovieclip.stage.stageWidth - (nextMusicChangeButton.width / 2);
			nextMusicChangeButton.y = stageHeight - (nextMusicChangeButton.height / 2);
			nextMusicChangeButton.SetHitArea(new SquareBtnHitArea(nextMusicChangeButton.width, nextMusicChangeButton.height, -(nextMusicChangeButton.width/2), -(nextMusicChangeButton.height/2)));
			menuContainingMovieclip.addChild(nextMusicChangeButton);
			
			//Create a white box for the text field
			var lineThickness:Number = 1.0;
			var textBG_Height:Number = 30.0; 
			var textBG_Width:Number = (nextMusicChangeButton.x - 4) - (prevMusicChangeButton.x + lineThickness + MENUBUTTONSIZE);
			var clipRect:Rectangle = menuContainingMovieclip.getRect(menuContainingMovieclip);
			textBackground = new Sprite();
			textBackground.graphics.lineStyle(lineThickness, 0x000000, 1, true);
			textBackground.graphics.beginFill(0xFFFFFF);
			textBackground.graphics.drawRect(0, 0, textBG_Width, textBG_Height+ lineThickness);
			textBackground.graphics.endFill();

			textBackground.x = prevMusicChangeButton.width + 2;
			textBackground.y = stageHeight - textBG_Height - (lineThickness*2);
			//textBackground.y = 720.5;
			menuContainingMovieclip.addChild(textBackground);
			//Create text field for music manager
			var musicInfoTxtFormat:TextFormat = new TextFormat();
			musicInfoTxtFormat.font = sm256Font.fontName;
			musicInfoTxtFormat.size=18;
			musicInfoTxtFormat.align=TextFormatAlign.CENTER;
			musicInfoTxtFormat.color = 0x000000;
			musicInfoText = new TextField();
			musicInfoText.embedFonts = true;
			musicInfoText.antiAliasType = AntiAliasType.ADVANCED;
			musicInfoText.selectable = false;
			musicInfoText.defaultTextFormat = musicInfoTxtFormat;
			musicInfoText.autoSize = TextFieldAutoSize.CENTER;
			//musicInfoText.width = textBG_Width - 10;
			//musicInfoText.height = textBG_Height;
			musicInfoText.x = (textBackground.width - musicInfoText.width)/2;
			musicInfoText.y = musicInfoText.height;
			//textBackground.x + 2.5;
			textBackground.addChild(musicInfoText);
			
			musicInfoText.text = "stopped";

			musicPlayer.SetupMusicManager(m_Characters.length, movieclipWithMusic, frameRate, musicInfoText);
		}
		
		public function UseDefaultMusicForCurrentCharacter():void
		{
			ChangeMusicForCharacter(m_currentCharacterId, GetCurrentCharacter().GetDefaultMusicName());
			musicPlayer.PlayMusic(m_currentCharacterId, GetTargetFrameNumberForAnimation());
			//ToggleMusicSelectionMode(m_currentCharacterId, GetTargetFrameNumberForAnimation());
			UpdateDefaultMusicButton();
		}
		
		/*Attempts to queue up a change into a linked frame containing an animation. Animations are linked through the use of frame labels. 
		 * The scene to change from should have a label that follows the naming scheme of "Into_"{labelNameOfLinkedFrame}. For example, 
		 * to accomplish a cum transition, one frame would be labeled "Into_Scene" and another would simple be labeled "Scene".
		 * In the actual animation movie clip, a frame label named "ActivateWindow" is expected. This indicates how many frames
		 * the user has to input the Activate command. The frame after the end of the ActivateWindow is when the transition will happen.*/
		public function ActivateAnimationChange():void
		{
			var animationQueued:Boolean = GetCurrentCharacter().CheckAndSetupLinkedTransition();
			if (animationQueued == true)
			{
				transitionLockout = true;
				
				//Do something here to lock character changes.
				//this.can
			}
		}
		
		private function RemoveTransitionLockout(e:Event):void
		{
			
		}
		//The logic for the normal switch that happens every 120 frames
		public function CharacterSwitchLogic():void
		{
			if (transitionLockout == true)
			{
				return;
			}
			if(!m_selectRandomChar)
			{
				if(m_currentCharacterId + 1 >= m_Characters.length)
				{
					m_currentCharacterId = 0;
				}
				else
				{
					++m_currentCharacterId;
				}
				//Make sure the character can be switched to. If not, cycle through until we find one we can switch to
				while(m_canSwitchToCharacter[m_currentCharacterId] == false)
				{
					if(m_currentCharacterId + 1 >= m_Characters.length)
					{
						m_currentCharacterId = 0;
					}
					else
					{
						++m_currentCharacterId;
					}
				}
			}
			else
			{
				/*Randomly select a character. If a disallowed switch occur, keep rerolling.*/
				var switchOk:Boolean = false;
				var charactersAllowed:int = 0;
				for(var i:int = 0, l:int = m_Characters.length; i < l; ++i)
				{
					if(m_canSwitchToCharacter[i] == true)
					{
						++charactersAllowed;
					}
				}
				if(charactersAllowed <= 1) //Too limited of a pool of characters to pick from. To avoid a potential error and waste of time, just bypass switching characters and stick with the current one.
				{
					switchOk = true;
				}
				else
				{
					while(!switchOk)
					{
						var randomCharId:int = Math.floor(Math.random() * m_Characters.length);
						
						if(m_canSwitchToCharacter[randomCharId] == true)
						{
							if(charactersAllowed == 2)
							{
								m_currentCharacterId = randomCharId;
								switchOk = true;
							}
							else
							{
								if(m_currentCharacterId != randomCharId)
								{
									m_currentCharacterId = randomCharId;
									switchOk = true;
								}
							}
						}
					}
				}
			}
		}
		
		//Creates the character menu and animation select/lock menu. Also locks the character manager from being able to add additional characters.
		public function CreateMenus(parentMC:MovieClip):void
		{
			m_mainStage.MenuLayer.addEventListener(MouseEvent.MOUSE_DOWN, MouseDownHandler, true);
			m_mainStage.addEventListener(MouseEvent.MOUSE_UP, MouseUpHandler, true);
			m_mainStage.addEventListener(MouseEvent.MOUSE_WHEEL, MouseWheelHandler, true);
			//m_mainStage.MenuLayer.addEventListener(MouseEvent.MOUSE_MOVE, SomeListener, true);
			//m_mainStage.addEventListener(MouseEvent.ROLL_OVER, SomeListenerOver, true);
			m_mainStage.addEventListener(MouseEvent.RIGHT_CLICK, MouseRightClickHandler, true);
			m_canAddCharacters = false;
			//Character Menu
			//Create the menu cursor
			m_menuCursor = new Sprite();
			//m_menuCursor = new MenuCursorSprite(); /* comment out the line that creates menuCursor as a sprite and uncomment this line if you want to use the menu cursor sprite that is in the library */
			
			//Draw a cursor using graphics functions
			m_menuCursor.graphics.lineStyle(MENUBUTTONSIZE/16,0xffffff, .75, true);
			var lineDistance:Number = MENUBUTTONSIZE * .25; //Lines are 12.5% the length of the menu button size
			//Top left part of the cursor
			m_menuCursor.graphics.moveTo(0,lineDistance);
			m_menuCursor.graphics.lineTo(0, 0);//up line
			m_menuCursor.graphics.lineTo(lineDistance, 0); //right line
			//Top right part of the cursor
			m_menuCursor.graphics.moveTo(MENUBUTTONSIZE-lineDistance,0);
			m_menuCursor.graphics.lineTo(MENUBUTTONSIZE, 0); //right line
			m_menuCursor.graphics.lineTo(MENUBUTTONSIZE, lineDistance);//down line
			//Bottom right part of the cursor
			m_menuCursor.graphics.moveTo(MENUBUTTONSIZE,MENUBUTTONSIZE-lineDistance); 
			m_menuCursor.graphics.lineTo(MENUBUTTONSIZE, MENUBUTTONSIZE); // down line
			m_menuCursor.graphics.lineTo(MENUBUTTONSIZE-lineDistance, MENUBUTTONSIZE); //left line
			//Bottom left part of the cursor
			m_menuCursor.graphics.moveTo(lineDistance,MENUBUTTONSIZE);
			m_menuCursor.graphics.lineTo(0, MENUBUTTONSIZE);
			m_menuCursor.graphics.lineTo(0, MENUBUTTONSIZE-lineDistance);
			m_menuCursor.x = 4;
			m_menuCursor.y = 4;
			
			var buttonColumn:int = 0;
			var buttonRow:int = 0;
			var buttonPoint:Point;
			var charBtnIndex:int=0;
			for(var l:int = m_characterMenuButton.length; charBtnIndex < l; ++charBtnIndex)
			{
				if(m_characterMenuButton[charBtnIndex] != null)
				{
					AddCharacterMenuButton(charBtnIndex, null, parentMC);			
					m_characterMenuButton[charBtnIndex].SetButtonFunction(MenuButton.TYPE_CHARACTER, CHARMENUCOMMAND_CHANGECHAR, charBtnIndex);
					PrepareMenuButton(m_characterMenuButton[charBtnIndex]);
				}
			}

			m_randomButton.transform.colorTransform = m_lockedButtonColor;
			m_randomButton.SetButtonFunction(MenuButton.TYPE_CHARACTER, CHARMENUCOMMAND_RANDOMCHAR);
			AddCharacterMenuButton(charBtnIndex, m_randomButton, parentMC);
			PrepareMenuButton(m_randomButton);
			m_randomButton.SetHitArea(new CircleBtnHitArea());
			++charBtnIndex;
			if(!m_selectRandomChar)
			{
				m_randomButton.transform.colorTransform = m_lockedButtonColor;
			}
			
			//character lock button
			//++charBtnIndex;
			//m_characterMenuButton[m_characterMenuButton.length] = m_charLockButton;
			m_charLockButton.SetButtonFunction(MenuButton.TYPE_CHARACTER, CHARMENUCOMMAND_NOSWITCH);
			AddCharacterMenuButton(charBtnIndex, m_charLockButton, parentMC);
			PrepareMenuButton(m_charLockButton);
			m_charLockButton.SetHitArea(new CircleBtnHitArea());
			++charBtnIndex
			if(m_allowCharSwitches)
			{
				m_charLockButton.transform.colorTransform = m_lockedButtonColor;
			}
			
			parentMC.addChild(m_menuCursor);
			//m_menuCursor.cacheAsBitmap = true;
			
			//Animation Menu
			//var sm256Font:SuperMarioFont = new SuperMarioFont();
			var txtFormat:TextFormat = new TextFormat();
			txtFormat.font = sm256Font.fontName;
			txtFormat.size=MENUBLOCKSIZE*0.60;
			txtFormat.align=TextFormatAlign.CENTER;
			txtFormat.color = 0xFFFFFF;
			var blockPoint:Point;
			var blockText:TextField;
			var buttonIndex:int;
			for(buttonIndex = 0; buttonIndex < MAXANIMATIONSELECTBOXES; ++buttonIndex)
			{
				var animationBlock:MenuButton = new AnimationBlockButton();
				AddNewAnimationMenuButton(buttonIndex, animationBlock, parentMC);
				
				blockText = new TextField();
				blockText.embedFonts = true;
				blockText.antiAliasType = AntiAliasType.ADVANCED;
				blockText.selectable = false;
				blockText.defaultTextFormat = txtFormat;
				//blockText.width = MENUBLOCKSIZE;
				//blockText.height = MENUBLOCKSIZE;
				blockText.autoSize = TextFieldAutoSize.CENTER;
				blockText.name = BLOCKTEXTFIELDNAME;
				blockText.text = ConvertAnimationNumberToString(buttonIndex + 1);
				blockText.x =  (animationBlock.width - blockText.width) / 2;
				blockText.y =   (animationBlock.height - blockText.height) / 2;
				m_animationMenu[buttonIndex].addChild(blockText);
				m_animationMenu[buttonIndex].SetButtonFunction(MenuButton.TYPE_ANIMATION, ANIMMENUCOMMAND_CHANGEANIM, buttonIndex);
				PrepareMenuButton( m_animationMenu[buttonIndex]);
			}

			
			{
				AddNewAnimationMenuButton(buttonIndex, randomBlock, parentMC);
				m_animationMenu[buttonIndex].SetButtonFunction(MenuButton.TYPE_ANIMATION, ANIMMENUCOMMAND_RANDOMANIM);
				m_animationMenu[buttonIndex].SetHitArea(new SquareBtnHitArea(MENUBUTTONSIZE, MENUBUTTONSIZE));
				PrepareMenuButton(m_animationMenu[buttonIndex]);
				++buttonIndex;
			}
			//Music volume Button
			{
				AddNewAnimationMenuButton(buttonIndex, m_musicVolumeButton, parentMC);
				m_animationMenu[buttonIndex].SetButtonFunction(MenuButton.TYPE_ANIMATION, ANIMMENUCOMMAND_MUSICVOLUME);
				m_animationMenu[buttonIndex].SetHitArea(new SquareBtnHitArea(MENUBUTTONSIZE, MENUBUTTONSIZE));
				PrepareMenuButton(m_animationMenu[buttonIndex]);
				++buttonIndex;
			}
			//Dynamic music button
			{
				AddNewAnimationMenuButton(buttonIndex, m_dynamicMusicButton, parentMC);
				m_animationMenu[buttonIndex].SetButtonFunction(MenuButton.TYPE_ANIMATION, ANIMMENUCOMMAND_DEFAULTMUSIC);
				m_animationMenu[buttonIndex].SetHitArea(new SquareBtnHitArea(MENUBUTTONSIZE, MENUBUTTONSIZE));
				PrepareMenuButton(m_animationMenu[buttonIndex]);
				++buttonIndex;
			}
			
			//One song for all or any song for all button (Also referred to as SongForOneOrAll button)
			{
				AddNewAnimationMenuButton(buttonIndex, musicForEachOrAllButton, parentMC);
				m_animationMenu[buttonIndex].SetButtonFunction(MenuButton.TYPE_ANIMATION, ANIMMENUCOMMAND_MUSIC_FOR_EACH_OR_ALL);
				m_animationMenu[buttonIndex].SetHitArea(new SquareBtnHitArea(MENUBUTTONSIZE, MENUBUTTONSIZE));
				PrepareMenuButton(m_animationMenu[buttonIndex]);
				++buttonIndex;
			}
			
			//Settings button
			{
				//Physically grouped with animation buttons but is actually a misc button
				AddNewAnimationMenuButton(buttonIndex, m_settingsButton, parentMC);
				m_animationMenu[buttonIndex].SetButtonFunction(MenuButton.TYPE_MISC, MISCMENUCOMMAND_SETTINGS);
				m_animationMenu[buttonIndex].SetHitArea(new SquareBtnHitArea(MENUBUTTONSIZE, MENUBUTTONSIZE));
				PrepareMenuButton(m_animationMenu[buttonIndex]);
				++buttonIndex;
			}
			
			{
				//This is not actually a button since right clicking takes place of the
				//keyboard function this is used for
				
				if(!m_animationLockMode)
				{
					keyButton.transform.colorTransform = m_lockedButtonColor;
				}
				AddNewAnimationMenuButton(buttonIndex, keyButton, parentMC);
				m_animationMenu[buttonIndex].SetButtonFunction(-1, null);
				PrepareMenuButton(m_animationMenu[buttonIndex]);
				++buttonIndex;
			}
		}
		
		//Updates the menus so they stay on top of the other display objects in the flash
		public function SetMenusOnTop(parentMC:MovieClip):void
		{
			var topIndex:int = parentMC.numChildren - 1;
			//character menu
			for(var i:int =0, l:int=m_characterMenuButton.length; i < l; ++i)
			{
				if(m_characterMenuButton[i] != null && parentMC.contains(m_characterMenuButton[i]))
				{
					parentMC.setChildIndex(m_characterMenuButton[i], topIndex);
				}
			}
			parentMC.setChildIndex(m_menuCursor, parentMC.numChildren - 1);
			
			//animation menu
			for(var blockIndex:int =0, length:int=m_animationMenu.length; blockIndex < length; ++blockIndex)
			{
				if(m_animationMenu[blockIndex] != null && parentMC.contains(m_animationMenu[blockIndex]))
				{
					parentMC.setChildIndex(m_animationMenu[blockIndex], topIndex);
				}
			}
		}
		
		private function ValidateCharacterId(characterId:int):Boolean
		{
			if (characterId < 0 || characterId > m_Characters.length)
			{
				return false;
			}
			return true;
		}
		
		public function GetCharacterById(characterId:int):AnimatedCharacter
		{
			if(characterId < 0)
			{
				throw new Error("Character ID can not be less than 0");
			}
			else if(characterId > m_Characters.length)
			{
				throw new Error("No Character was found for ID#" + characterId.toString());
			}
			else
				return m_Characters[characterId];
		}
		/*public function GetCharacterByName(characterName:String):Character
		{
			return GetCharacterById(m_charNamesDict[characterName]);
		}*/
		
		public function GetTotalNumOfCharacters():int
		{
			return m_Characters.length;
		}
		public function AddCurrentCharacter(/*clipToAddCharTo:MovieClip, abruptCharChange:Boolean=false,*/ abruptChangeFrameOffset:int=0):void
		{
			if (transitionLockout == true)
			{
				return;
			}
			var currentCharacter:AnimatedCharacter = GetCurrentCharacter();
			//If the current character selected is not the latest one being displayed, there needs to be some changes to get them on screen.
			if (m_latestCharacterIdOnStage != m_currentCharacterId)
			{
				//Stop the old character's movieclips from playing. Not doing this causes issues with garbage collection, massively slowing down the flash.
				var characterRemoving:AnimatedCharacter = ValidateCharacterId(m_latestCharacterIdOnStage) ? GetCharacterById(m_latestCharacterIdOnStage) : null;
				if (characterRemoving)
				{
					characterRemoving.StopAnimation();
				}
				//Remove the old character animation movie clip off the character layer
				while (m_mainStage.CharacterLayer.numChildren > 1) 
				{ m_mainStage.CharacterLayer.removeChildAt(m_mainStage.CharacterLayer.numChildren-1); }
				
				//Add the new character's animation movie clip
				currentCharacter.AddAnimationToDisplayObject(m_mainStage.CharacterLayer);
				//Change background stuff
				m_mainStage.TransitionDiamondBG.TransitionDiamond.Color1.transform.colorTransform = m_mainStage.InnerDiamondBG.InnerDiamond.Color1.transform.colorTransform = currentCharacter.GetTLDiamondColor();
				m_mainStage.TransitionDiamondBG.TransitionDiamond.Color2.transform.colorTransform = m_mainStage.InnerDiamondBG.InnerDiamond.Color2.transform.colorTransform = currentCharacter.GetCenterDiamondColor();
				m_mainStage.TransitionDiamondBG.TransitionDiamond.Color3.transform.colorTransform = m_mainStage.InnerDiamondBG.InnerDiamond.Color3.transform.colorTransform = currentCharacter.GetBRDiamondColor();
				m_mainStage.TransitionDiamondBG.TransitionDiamond.Color4.transform.colorTransform = m_mainStage.OuterDiamondBG.OuterDiamond.Color.transform.colorTransform = currentCharacter.GetBackgroundColor();
				m_mainStage.BacklightBG.Backlight.BacklightGfx.transform.colorTransform = currentCharacter.GetBacklightColor();
				
				//Other things
				//Play their selected music
				//musicPlayer.PlayMusic(GetCurrentCharID(), abruptChangeFrameOffset);
				//Update animation pages
				CheckAvailableAnimationPages();
				UpdateDefaultMusicButton();
				//Update user settings
				userSettings.currentCharacterName = GetCurrentCharacter().GetName();
				//Update latest char id 
				m_latestCharacterIdOnStage = m_currentCharacterId;
			}
			currentCharacter.RandomizePlayAnim();
			currentCharacter.PlayingLockedAnimCheck();
			currentCharacter.PlayAnimation(((m_mainStage.currentFrame - 2)% 120) + 1);
		}
		
		public function GetCurrentCharacter():AnimatedCharacter
		{
			return GetCharacterById(m_currentCharacterId);
		}
		
		public function GetCurrentCharID():int
		{
			return m_currentCharacterId;
		}
		public function SetCurrentCharID(charID:int):void
		{
			if(m_Characters.length == 0)
			{
				//throw new Error("Tried to set a character when no characters were added to the character manager.");
			}
			if(charID < 0 || charID >= m_Characters.length)
			{
				m_currentCharacterId = 0; //Return to the "default" character
			}
			else
			{
				m_currentCharacterId = charID;
			}
		}
		public function GetCharSwitchStatus():Boolean
		{
			return m_allowCharSwitches;
		}
		public function SetCharSwitchStatus(switchStatus:Boolean):void
		{
			m_allowCharSwitches = switchStatus;
			userSettings.allowCharacterSwitches = switchStatus;
			if(m_allowCharSwitches)
			{
				m_charLockButton.transform.colorTransform = m_lockedButtonColor;
			}
			else
			{
				m_charLockButton.transform.colorTransform = new ColorTransform();
				if(GetRandomSelectStatus())
				{
					SetRandomSelectStatus(false);
				}
			}
		}
		
		private function MouseDownHandler(event:MouseEvent):void
		{
			var button:MenuButton = event.target as MenuButton;
			if (button)
			{
				m_initialButtonDown = button;
			}
		}
		private function MouseUpHandler(event:MouseEvent):void
		{
			//If there was no button that the pointer device was over, there's no reason to continue
			var initialButtonDown:MenuButton = m_initialButtonDown; //localizing variable
			if (initialButtonDown != null)
			{
				var button:MenuButton = event.target as MenuButton; //For verification purposes
				var buttonType:int = initialButtonDown.GetType();
				var menuIndex:int = initialButtonDown.GetMenuIndex();
				var senderCommand:String = initialButtonDown.GetMenuCommand();
				var charAnimFrame:int = menuIndex+1 + (m_animationPage*MAXANIMATIONSELECTBOXES);
				if (button == initialButtonDown)
				{
					
					
					if (buttonType == MenuButton.TYPE_CHARACTER)
					{
						if(senderCommand == CHARMENUCOMMAND_NOSWITCH)//character switch lock button
						{SetCharSwitchStatus(!GetCharSwitchStatus());}
						else if(senderCommand == CHARMENUCOMMAND_RANDOMCHAR) //random button
						{SetRandomSelectStatus(!GetRandomSelectStatus());}
						else if(senderCommand == CHARMENUCOMMAND_CHANGECHAR)//characters
						{SwitchToCharacter(menuIndex);}
					}
					else if (buttonType == MenuButton.TYPE_ANIMATION)
					{
						if (senderCommand == ANIMMENUCOMMAND_CHANGEANIM)//animations
						{
							ChangeAnimForCurrentCharacter(charAnimFrame);
						}
						else if(senderCommand == ANIMMENUCOMMAND_RANDOMANIM) //random anim button
						{/*RandomizeCurrentCharacterAnim();*/}
						else if(senderCommand == ANIMMENUCOMMAND_MUSICVOLUME)
						{ToggleMusicPlay();}
						else if(senderCommand == ANIMMENUCOMMAND_DEFAULTMUSIC)
						{UseDefaultMusicForCurrentCharacter();}
						else if (senderCommand == ANIMMENUCOMMAND_MUSIC_FOR_EACH_OR_ALL)
						{MusicForEachOrAll();}
					}
					else if (buttonType == MenuButton.TYPE_MISC)
					{
						if(senderCommand == MISCMENUCOMMAND_PREVMUSIC) //Previous music button
						{
							musicPlayer.ChangeToPrevMusic(GetCurrentCharID(), GetTargetFrameNumberForAnimation());
							if (musicPlayer.GetGlobalSongStatus() == false)
							{
								userSettings.characterSettings[GetCurrentCharacter().GetName()].playMusicTitle = musicPlayer.GetCurrentlyPlayingMusicTitle();
							}
							else
							{
								userSettings.globalSongTitle = musicPlayer.GetCurrentlyPlayingMusicTitle();
							}
							UpdateDefaultMusicButton();
						}
						else if(senderCommand == MISCMENUCOMMAND_NEXTMUSIC) //Next music button
						{
							musicPlayer.ChangeToNextMusic(GetCurrentCharID(), GetTargetFrameNumberForAnimation());
							if (musicPlayer.GetGlobalSongStatus() == false)
							{
								userSettings.characterSettings[GetCurrentCharacter().GetName()].playMusicTitle = musicPlayer.GetCurrentlyPlayingMusicTitle();
							}
							else
							{
								userSettings.globalSongTitle = musicPlayer.GetCurrentlyPlayingMusicTitle();
							}
							
							UpdateDefaultMusicButton();
						}
						else if (senderCommand == MISCMENUCOMMAND_SETTINGS)
						{
							//The settings window hasn't been added yet, so add it to main stage
							if (keyConfig.parent == null)
							{
								m_mainStage.HelpLayer.visible = false;
								m_mainStage.addChild(keyConfig);
							}
						}
					}
				}
				else //Swipe test
				{
					//The target isn't a menu button. Likely a swipe motion for the character buttons
					if (buttonType == MenuButton.TYPE_CHARACTER)
					{
						if (senderCommand == CHARMENUCOMMAND_CHANGECHAR && event.stageX > initialButtonDown.x + MINIMUM_HORIZONTAL_SWIPE_DISTANCE)
						{
							ToggleLockOnCharacter(menuIndex);
						}
					}
					//The animation menu swipe test. Up/Down changes the selectable animations and towards center (un)locks the animation.
					else if (buttonType == MenuButton.TYPE_ANIMATION)
					{
						if (senderCommand == ANIMMENUCOMMAND_CHANGEANIM && event.stageX <= initialButtonDown.x - MINIMUM_HORIZONTAL_SWIPE_DISTANCE)
						{
							LockAnimForCurrentCharacter(charAnimFrame);
						}
						else if (event.stageY >= initialButtonDown.y + MINIMUM_VERTICAL_SWIPE_DISTANCE)
						{
							GotoNextAnimationPage();
						}
						else if (event.stageY <= initialButtonDown.y - MINIMUM_VERTICAL_SWIPE_DISTANCE)
						{
							GotoPrevAnimationPage();
						}
					}
				}
				
			}
			m_initialButtonDown = null;
			//m_latestButtonOver = null;
		}
		
		private function MouseWheelHandler(event:MouseEvent):void
		{
			var ppppuButton:MenuButton = event.target as MenuButton;
			if (ppppuButton)
			{
				var senderCommand:String = ppppuButton.GetMenuCommand();
				var menuIndex:int = ppppuButton.GetMenuIndex();
				if (senderCommand == CHARMENUCOMMAND_CHANGECHAR)
				{
					if(event.type == MouseEvent.MOUSE_WHEEL && event.delta > 0)
					{
						ScrollToPrevCharacter();
					}
					else if(event.type == MouseEvent.MOUSE_WHEEL && event.delta < 0)
					{
						ScrollToNextCharacter();
					}
				}
				else if (senderCommand == ANIMMENUCOMMAND_CHANGEANIM)
				{
					if(event.type == MouseEvent.MOUSE_WHEEL && event.delta < 0)
					{
						GotoNextAnimationPage();
					}
					else if(event.type == MouseEvent.MOUSE_WHEEL && event.delta > 0)
					{
						GotoPrevAnimationPage();
					}
				}
			}
		}
		/*private function SomeListenerOver(event:MouseEvent):void
		{
			var button:MenuButton = event.relatedObject as MenuButton;
			if (button)
			{
				m_latestButtonOver = button;
			}
		}*/
		private function MouseRightClickHandler(event:MouseEvent):void
		{
			var ppppuButton:MenuButton = event.target as MenuButton;
			if (ppppuButton)
			{
				var senderCommand:String = ppppuButton.GetMenuCommand();
				var menuIndex:int = ppppuButton.GetMenuIndex();
				if (senderCommand == CHARMENUCOMMAND_CHANGECHAR)//characters
				{
					ToggleLockOnCharacter(menuIndex);
				}
				else if (senderCommand == ANIMMENUCOMMAND_CHANGEANIM)
				{
					var charAnimFrame:int = menuIndex+1 + (m_animationPage*MAXANIMATIONSELECTBOXES);
					LockAnimForCurrentCharacter(charAnimFrame);
				}
			}
		}
		public function RandomizeCurrentCharacterAnim(playOnThisFrame:int):void
		{
			var currChar:AnimatedCharacter = GetCurrentCharacter();
			currChar.SetRandomizeAnimation(true);
			currChar.RandomizePlayAnim();
			userSettings.characterSettings[currChar.GetName()].animationSelect = 0;
			
			//currChar.PlayAnimation(((m_mainStage.currentFrame - 2) % 120) + 1);
			currChar.PlayAnimation(playOnThisFrame);
			randomBlock.transform.colorTransform = new ColorTransform();
		}
		
		public function HandleAnimActionForCurrentCharacter(characterAnimFrame:int):void
		{
			characterAnimFrame += m_animationPage*MAXANIMATIONSELECTBOXES;
			if(m_animationLockMode)
			{
				LockAnimForCurrentCharacter(characterAnimFrame);
			}
			else
			{
				//Is in goto mode, so change this animation for the current character
				ChangeAnimForCurrentCharacter(characterAnimFrame);
			}
		}
		public function ChangeAnimForCurrentCharacter(characterAnimFrame:int):void
		{
			if (transitionLockout == true)
			{
				return;
			}
			var currChar:AnimatedCharacter = GetCurrentCharacter();
			if(currChar.GetNumberOfAnimations() < characterAnimFrame)
			{
				return;
			}
			else if(currChar.GetAnimationLockedStatus(characterAnimFrame))
			{
				return;
			}
			currChar.SetRandomizeAnimation(false);
			currChar.SetPlayAnimation(characterAnimFrame);
			userSettings.characterSettings[currChar.GetName()].animationSelect = characterAnimFrame;
			
			currChar.PlayAnimation(((m_mainStage.currentFrame - 2)% 120) + 1);
			randomBlock.transform.colorTransform = m_lockedButtonColor;
		}
		
		public function LockAnimForCurrentCharacter(characterAnimFrame:int):void
		{
			var currChar:AnimatedCharacter = GetCurrentCharacter();
			//animation is locked, so unlock it.
			if(currChar.GetAnimationLockedStatus(characterAnimFrame))
			{
				currChar.SetAnimationLockedStatus(characterAnimFrame, false);
				userSettings.characterSettings[currChar.GetName()].animationLocked[characterAnimFrame] = false;
				m_animationMenu[(characterAnimFrame-1)%MAXANIMATIONSELECTBOXES].transform.colorTransform = new ColorTransform();
			}
			else //animation is unlocked, so lock it
			{
				//make sure that locking this animation will not lead to all animations being locked
				if(currChar.GetNumberOfLockedAnimations()+1 < currChar.GetNumberOfAnimations())
				{
					currChar.SetAnimationLockedStatus(characterAnimFrame, true);
					userSettings.characterSettings[currChar.GetName()].animationLocked[characterAnimFrame] = true;
					m_animationMenu[(characterAnimFrame-1)%MAXANIMATIONSELECTBOXES].transform.colorTransform = m_lockedButtonColor;
				}
			}
			
			UpdateAnimationMenuBlocks();
		}
		
		public function GetRandomSelectStatus():Boolean
		{
			return m_selectRandomChar;
		}
		
		public function SetRandomSelectStatus(selectStatus:Boolean):void
		{
			m_selectRandomChar = selectStatus;
			userSettings.randomlySelectCharacter = selectStatus;
			if(m_selectRandomChar == true)
			{
				m_randomButton.transform.colorTransform = new ColorTransform();
				if(!GetCharSwitchStatus())
				{
					SetCharSwitchStatus(true);
				}
			}
			else
			{
				m_randomButton.transform.colorTransform = m_lockedButtonColor;
			}
			
		}
		
		public function MoveMenuCursorToPrevPos():void
		{
			--m_menuCursorPos;
			if(m_menuCursorPos < 0)
			{
				m_menuCursorPos = m_Characters.length - 1;
			}
			m_menuCursor.x = m_characterMenuButton[m_menuCursorPos].x;
			m_menuCursor.y = m_characterMenuButton[m_menuCursorPos].y;
		}
		
		public function MoveMenuCursorToNextPos():void
		{
			++m_menuCursorPos;
			if(m_menuCursorPos >= m_Characters.length)
			{
				m_menuCursorPos = 0;
			}
			m_menuCursor.x = m_characterMenuButton[m_menuCursorPos].x;
			m_menuCursor.y = m_characterMenuButton[m_menuCursorPos].y;
		}
		
		public function SwitchToCharacter(charIndex:int=-1):void
		{
			//if(m_menuEnabled)
			//{
				//Undefined index, fall back to the first character
				if(charIndex == -1)
				{
					charIndex = 0;
				}
				if(m_canSwitchToCharacter[charIndex] == true && m_currentCharacterId != charIndex)
				{
					//var parentOfCharMC:MovieClip = GetCurrentCharacter().GetCharacterMC().parent as MovieClip;
					m_currentCharacterId = charIndex;
					AddCurrentCharacter(/*m_mainMovieClip,*/ GetTargetFrameNumberForAnimation());
					CheckAvailableAnimationPages();
					userSettings.currentCharacterName = GetCurrentCharacter().GetName();
					
				}
			//}
		}
		
		public function GetMenuCursorPosition():int
		{
			return m_menuCursorPos;
		}
		
		//For using the mouse wheel to change characters
		public function ScrollToNextCharacter():void
		{
			//if(m_menuEnabled)
			//{
				var startIndex:int = GetCurrentCharID();
				var currentIndex:int = startIndex+1;
				
				var switchOk:Boolean=false;
				while(currentIndex != startIndex && !switchOk)
				{
					if(currentIndex >= m_Characters.length)
					{
						currentIndex = 0;
					}
					if(m_canSwitchToCharacter[currentIndex] == true)
					{
						//var parentOfCharMC:MovieClip = GetCurrentCharacter().GetCharacterMC().parent as MovieClip;
						m_currentCharacterId = currentIndex;
						AddCurrentCharacter(/*m_mainMovieClip,*/ GetTargetFrameNumberForAnimation());
						CheckAvailableAnimationPages();
						switchOk = true;
					}
					++currentIndex;
				}
			//}
		}
		public function ScrollToPrevCharacter():void
		{
			//if(m_menuEnabled)
			//{
				var startIndex:int = GetCurrentCharID();
				var currentIndex:int = startIndex - 1;
				
				var switchOk:Boolean=false;
				while(currentIndex != startIndex && !switchOk)
				{
					if(currentIndex < 0)
					{
						currentIndex = m_Characters.length-1;
					}
					if(m_canSwitchToCharacter[currentIndex] == true)
					{
						//var parentOfCharMC:MovieClip = GetCurrentCharacter().GetCharacterMC().parent as MovieClip;
						m_currentCharacterId = currentIndex;
						AddCurrentCharacter(/*m_mainMovieClip,*/ GetTargetFrameNumberForAnimation());
						CheckAvailableAnimationPages();
						switchOk = true;
					}
					--currentIndex;
				}
			//}
		}
		public function SetLockOnCharacter(id:int, canSwitch:Boolean):void
		{
			if (id <= -1 || id > m_canSwitchToCharacter.length) { return; }
			
			m_canSwitchToCharacter[id] = canSwitch;
		}
		
		public function ToggleLockOnCharacter(charIndex:int=-1):void
		{
			if(charIndex == -1)	{charIndex = 0;}
			//Test if setting this character to be unselectable will result in no character being selectable
			if (m_canSwitchToCharacter[charIndex] && m_unswitchableCharactersNum + 1 >= m_Characters.length)
			{
				return; //Need to exit the function immediantly
			}
			m_canSwitchToCharacter[charIndex] = !m_canSwitchToCharacter[charIndex];
			userSettings.characterSettings[m_Characters[charIndex].GetName()].canSwitchTo = m_canSwitchToCharacter[charIndex];
			if (!m_canSwitchToCharacter[charIndex])
			{
				m_characterMenuButton[charIndex].transform.colorTransform = m_lockedButtonColor;
				++m_unswitchableCharactersNum;
			}
			else
			{
				m_characterMenuButton[charIndex].transform.colorTransform = new ColorTransform();
				--m_unswitchableCharactersNum;
			}
			
		}
		
		public function ToggleAnimationLockMode():void
		{
			m_animationLockMode = !m_animationLockMode;
			if(m_animationLockMode)
			{
				keyButton.transform.colorTransform = new ColorTransform();
			}
			else
			{
				keyButton.transform.colorTransform = m_lockedButtonColor;
			}
		}
		public function ChangeMusicForCurrentCharacter(nextSong:Boolean):void
		{
			/*if (musicManager.GetPlayCharacterMusicStatus(m_currentCharacterId) == true)
			{
				return;
			}*/
			if (nextSong == true)
			{
				musicPlayer.ChangeToNextMusic(this.GetCurrentCharID(), GetTargetFrameNumberForAnimation());
			}
			else 
			{
				musicPlayer.ChangeToPrevMusic(this.GetCurrentCharID(), GetTargetFrameNumberForAnimation());
			}
			userSettings.characterSettings[GetCurrentCharacter().GetName()].playMusicTitle = musicPlayer.GetCurrentlyPlayingMusicTitle();
			
		}
		/*//Obsolete due to the SongsForOneOrAll Function
		public function SetCurrentMusicForAllCharacters():void
		{
			musicManager.ChangeToCurrentMusicForAllCharacters();
			for (var i:int = 0, l:int = m_Characters.length; i < l;++i)
			{
				userSettings.characterSettings[m_Characters[i].GetName()].playMusicTitle = musicManager.GetCurrentlyPlayingMusicTitle();
			}
			
			this.UpdateDefaultMusicButton();
		}*/
		
		public function MusicForEachOrAll():void
		{
			//One means that each character can choose a song to play
			//All Means that the same song plays for all characters.
			if (musicForEachOrAllButton.ButtonGraphic.currentFrameLabel == "One")
			{
				musicForEachOrAllButton.ButtonGraphic.gotoAndStop("All");
				//Tell the music manager that one song is to be used for all characters
				musicPlayer.ChangePlayGlobalSongStatus(true);
				userSettings.playOneSongForAllCharacters = true;
				musicPlayer.PlayMusic(m_currentCharacterId, GetTargetFrameNumberForAnimation());
			}
			else if (musicForEachOrAllButton.ButtonGraphic.currentFrameLabel == "All")
			{
				musicForEachOrAllButton.ButtonGraphic.gotoAndStop("One");
				//Tell the music manager that a character can play their own selected music
				musicPlayer.ChangePlayGlobalSongStatus(false);
				userSettings.playOneSongForAllCharacters = false;
				musicPlayer.PlayMusic(m_currentCharacterId, GetTargetFrameNumberForAnimation());
			}
		}
		
		public function GotoNextAnimationPage():void
		{
			//if(m_menuEnabled)
			//{
				if(GetCurrentCharacter().GetNumberOfAnimations() > MAXANIMATIONSELECTBOXES*(m_animationPage+1))
				{
					++m_animationPage;
					
				}
				else //wrap around to the first page
				{
					m_animationPage=0;
				}
				UpdateAnimationMenuBlocks();
			//}
		}
		
		public function GotoPrevAnimationPage():void
		{
			//if(m_menuEnabled)
			//{
				if(m_animationPage > 0)
				{
					--m_animationPage;
				}
				else //wrap around to the highest possible page
				{
					m_animationPage = GetCurrentCharacter().GetNumberOfAnimations() / (MAXANIMATIONSELECTBOXES+1);
				}
				UpdateAnimationMenuBlocks();
			//}
			
		}
		public function ToggleMenu():void
		{
			m_menuEnabled = !m_menuEnabled;
			userSettings.showMenu = m_menuEnabled;
			//setting visibility for character menu objects
			for(var i:int = 0, l:int = m_characterMenuButton.length; i < l; ++i)
			{
				m_characterMenuButton[i].visible = m_menuEnabled;
			}
			for(var x:int = 0, length:int = m_animationMenu.length; x < length; ++x)
			{
				m_animationMenu[x].visible = m_menuEnabled;
			}
			musicInfoText.visible = m_menuEnabled;
			textBackground.visible = m_menuEnabled;
			nextMusicChangeButton.visible = m_menuEnabled;
			prevMusicChangeButton.visible = m_menuEnabled;
			
			m_menuCursor.visible = m_menuEnabled;
			
		}
		public function CheckAvailableAnimationPages():void
		{
			while(m_animationPage > 0 && (GetCurrentCharacter().GetNumberOfAnimations() < MAXANIMATIONSELECTBOXES*m_animationPage+1))
			{
				--m_animationPage;
			}
			//UpdateAnimationMenuBlocks();
		}
		
		public function ToggleMusicPlay():void
		{
			//ToggleGlobalPlayMusicStatus returns the value of m_playMusic
			if(musicPlayer.ToggleGlobalPlayMusicStatus())
			{
				musicPlayer.ControlGlobalVolume(1.0);
				m_musicVolumeButton.transform.colorTransform = new ColorTransform();
				userSettings.playMusic = true;
			}
			else
			{
				musicPlayer.ControlGlobalVolume(0.0);
				m_musicVolumeButton.transform.colorTransform = m_lockedButtonColor;
				userSettings.playMusic = false;
			}
			
		}
		
		/*public function AllowRandomAnimForCurrChar(allowRandom:Boolean)
		{
			GetCurrentCharacter().SetRandomizeAnimation(allowRandom);
		}*/
		private function ConvertGlobalToLocalPoint(clipMC:MovieClip, attachPoint:Point):void
		{
			if(clipMC.parent == null)
				return;
			attachPoint = clipMC.globalToLocal(attachPoint);
		}
		private function UpdateAnimationMenuBlocks():void
		{
			for(var i:int = 0; i < MAXANIMATIONSELECTBOXES; ++i)
			{
				var animationNum:int = i+(m_animationPage*MAXANIMATIONSELECTBOXES)+1;
				if(animationNum <= GetCurrentCharacter().GetNumberOfAnimations())
				{
					ModifyAnimBlockText(i, ConvertAnimationNumberToString(animationNum));
					if(GetCurrentCharacter().GetAnimationLockedStatus(animationNum) == true)
					{
						m_animationMenu[i].transform.colorTransform = m_lockedButtonColor;
					}
					else
					{
						m_animationMenu[i].transform.colorTransform = new ColorTransform();
					}
				}
				else
				{
					//No animation for this animationNum.
					ModifyAnimBlockText(i);
					//blockText.text = "";
					m_animationMenu[i].transform.colorTransform = m_lockedButtonColor;
				}
			}
			if(GetCurrentCharacter().GetRandomAnimStatus() == true)
			{
				randomBlock.transform.colorTransform = new ColorTransform();
			}
			else
			{
				randomBlock.transform.colorTransform = m_lockedButtonColor;
			}
		}
		private function UpdateDefaultMusicButton():void
		{
			var currentCharMusicTitle:String = GetCurrentCharacter().GetDefaultMusicName();
			if(currentCharMusicTitle == musicPlayer.GetCurrentlyPlayingMusicTitle() /*|| currentCharMusicTitle == undefined*/)
			{
				m_dynamicMusicButton.transform.colorTransform = m_lockedButtonColor;
			}
			else
			{
				m_dynamicMusicButton.transform.colorTransform = new ColorTransform();
			}
		}
		private function ConvertAnimationNumberToString(animationNum:int):String
		{
			var animNumAsString:String = "";
			if(animationNum < 10)
			{
				animNumAsString = "0";
			}
			animNumAsString += animationNum.toString();
			return animNumAsString;
		}
		private function ModifyAnimBlockText(index:int, newText:String=""):void
		{
			if(index < MAXANIMATIONSELECTBOXES)
			{
				var animBlockTextField:TextField = m_animationMenu[index].getChildByName(BLOCKTEXTFIELDNAME) as TextField;
				animBlockTextField.text = newText;
				//animBlockTextField.x = m_animationMenu[index].width/2 - animBlockTextField.width/2;
				//animBlockTextField.x = (m_animationMenu[index].width +  m_animationMenu[index].width*(animBlockTextFieldSPACING/100))/2 - animBlockTextField.width/2;
				//animBlockTextField.x = (animBlockTextField.width - animBlockTextField.width)/2;
				animBlockTextField.x =  (m_animationMenu[index].width - animBlockTextField.width) / 2;
				animBlockTextField.y =   (m_animationMenu[index].height - animBlockTextField.height) /2;
				//animBlockTextField.y = m_animationMenu[index].height/2 - Math.round((animBlockTextField.height - animBlockTextField.textHeight)/2);
			}
		}
		
		private function PrepareMenuButton(button:MenuButton):void
		{
			button.mouseEnabled = true;
			button.mouseChildren = false;
		}
		
		private function AddCharacterMenuButton(buttonIndex:int, button:MenuButton, mainMC:MovieClip):void
		{
			var buttonColumn:int = 0;
			var buttonRow:int = buttonIndex;
			while(MENUBUTTONSIZE*buttonRow >= MENUBUTTONMAXPOS_Y)
			{
				buttonRow -= MENUBUTTONMAXPOS_Y / MENUBUTTONSIZE;
				++buttonColumn;
			}
			if(button != null)
			{
				m_characterMenuButton[buttonIndex] = button;
			}
			m_characterMenuButton[buttonIndex].width = MENUBUTTONSIZE;
			m_characterMenuButton[buttonIndex].height = MENUBUTTONSIZE;
			var buttonPoint:Point = new Point(4 + buttonColumn*MENUBUTTONSIZE + 4*buttonColumn, 4 + MENUBUTTONSIZE*buttonRow + 4*buttonRow);
			ConvertGlobalToLocalPoint(mainMC, buttonPoint);
			m_characterMenuButton[buttonIndex].x = buttonPoint.x;
			m_characterMenuButton[buttonIndex].y = buttonPoint.y;
			m_characterMenuButton[buttonIndex].mouseEnabled = true;
			m_characterMenuButton[buttonIndex].mouseChildren = false;
			mainMC.addChild(m_characterMenuButton[buttonIndex]);
		}
		
		private function AddNewAnimationMenuButton(buttonIndex:int, button:MenuButton, mainMC:MovieClip):void
		{
			if(button != null)
			{
				m_animationMenu[buttonIndex] = button;
			}
			m_animationMenu[buttonIndex] = button;
			m_animationMenu[buttonIndex].width = MENUBLOCKSIZE;
			m_animationMenu[buttonIndex].height = MENUBLOCKSIZE;
			var blockPoint:Point = new Point(mainMC.stage.stageWidth - 7 - m_animationMenu[buttonIndex].width, 4 + MENUBLOCKSIZE*buttonIndex + 2*buttonIndex);
			ConvertGlobalToLocalPoint(mainMC, blockPoint);
			m_animationMenu[buttonIndex].x = blockPoint.x;
			m_animationMenu[buttonIndex].y = blockPoint.y;
			mainMC.addChild(m_animationMenu[buttonIndex]);
		}
		//Gets a number from 1-120 for any animations used (character, light, background, etc)  
		private function GetTargetFrameNumberForAnimation():int
		{
			return ((m_mainStage.currentFrame - 2) % 120) + 1;
		}
		
		public function GetCharacterIdByName(name:String):int
		{
			var id:int = -1;
			if (name in m_charNamesDict)
			{
				id = m_charNamesDict[name];
			}
			return id;
		}
		
		public function SetAnimationLockForCharacter(charId:int, animationNumber:int, locked:Boolean):void
		{
			if (charId < 0) { return;}
			m_Characters[charId].SetAnimationLockedStatus(animationNumber, locked);
		}
		
		public function IsSettingsWindowActive():Boolean
		{
			if (keyConfig.parent != null)
			{
				return true;
			}
			return false;
		}
		public function InitializeSettingsWindow():void
		{
			keyConfig = new Config(userSettings);
		}
		
		public function GetFrameTargetsForCharacter(id:int):Vector.<int>
		{
			var frameTargets:Vector.<int>;
			var character:AnimatedCharacter = GetCharacterById(id);
			if (character)
			{
				//character.GetCharacterAnimations
			}
			return frameTargets;
		}
		
		/*public function DEBUG_TestMusicLoop():void
		{
			musicManager.DEBUG_GoToMusicLastSection();
		}*/
	}
}