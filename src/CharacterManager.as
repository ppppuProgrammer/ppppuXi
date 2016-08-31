package 
{
	import events.AnimationTransitionEvent;
	import events.ChangeBackgroundEvent;
	import events.ExitLinkedAnimationEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import mx.logging.*;
	import flash.events.UncaughtErrorEvent;
	/**
	 * ...
	 * @author 
	 */
	public class CharacterManager extends Sprite
	{
		private var m_charNamesDict:Dictionary = new Dictionary(); //Maps the character's name to an id number(int) (ie. "Peach" has an id of 0)
		private var m_Characters:Vector.<AnimatedCharacter> = new Vector.<AnimatedCharacter>();
		
		//Holds the id of the character to switch to next time a automatic character switch occurs.
		private var m_nextCharacterId:int = 0;
		//The character that is being managed.
		private var m_currentCharacter:AnimatedCharacter = null;
		//The character that is being displayed on the stage.
		//private var m_latestCharacter:AnimatedCharacter = null;
		
		//Controls whether the user wants character switching to be allowed or not.
		private var m_allowCharSwitches:Boolean = true;
		//Controls whether the user wants a character to be randomly picked when it's switching time.
		private var m_selectRandomChar:Boolean = false;
		//Indicates if a character is locked, meaning they can't be switched to. The index of the vector correspondes to the character's id.
		private var m_characterLocks:Vector.<Boolean> = new Vector.<Boolean>();
		//Keep a tally of how many characters are not able to be switched to.
		private var m_unswitchableCharactersNum:int = 0;
		
		//"global" character and animation switch lock. Meant to be used for linked animation transitions so that they happen uninterrupted.
		private var transitionLockout:Boolean = false;
		
		//The logging object for this class
		private var logger:ILogger;
		
		public function CharacterManager() 
		{
			//Create the logger object that's used by this class to output messages.
			logger = Log.getLogger("CharacterManager");
			
			logger.info("Initializing Character Manager");
		}
		
		/*Adds a new character to be able to be shown. Returns the character's id if the character was added successfully. Returns -1 if the
		character was missing necessary data or there was a character name conflict.*/
		public function AddCharacter(character:AnimatedCharacter):int
		{
			
			
			//var charAdded:Boolean = false;
			var charName:String = character.GetName();
			//Make sure no character with this name already exists.
			for (var x:int = 0, y:int = m_Characters.length; x < y; ++x)
			{
				if (charName == m_Characters[x].GetName())
				{
					logger.warn("A character with the name \"" + charName + "\" was already added");
					return -1;
				}
			}
			
			if (character.IsValidCharacter())
			{
				m_charNamesDict[charName] = m_Characters.length;
				m_characterLocks[m_Characters.length] = false;
				m_Characters[m_Characters.length] = character;
				return m_Characters.length - 1;
				//charAdded = true;
			}
			else
			{
				return -1;
			}
		}
		
		public function AddAnimationsToCharacter(characterName:String, animationContainer:MovieClip):void
		{
			if (animationContainer == null) { return; }
			var characterId:int = GetCharacterIdByName(characterName);
			if (characterId > -1)
			{
				var character:AnimatedCharacter = m_Characters[characterId];
				if (animationContainer.numChildren > 1)
				{
					character.AddAnimation(animationContainer);
				}
				else if(animationContainer.numChildren == 1)
				{
					character.AddAnimationsFromMovieClip(animationContainer);
				}
			}
			else
			{
				logger.warn("Unable to add animations to " + characterName + " as the character was not found.");
			}
			animationContainer.stopAllMovieClips();			
		}
		
		//The logic for the normal switch that happens every 120 frames
		public function CharacterSwitchLogic():void
		{
			if (m_currentCharacter != null && CheckIfTransitionLockIsActive())	{ return; }
			
			//Sequential character changing
			if(!m_selectRandomChar)
			{
				//character list wrap around
				if(m_nextCharacterId + 1 >= m_Characters.length)
				{
					m_nextCharacterId = 0;
				}
				else
				{
					//go to next character
					++m_nextCharacterId;
				}
				//Make sure the character can be switched to. If not, cycle through until we find one we can switch to
				while(m_characterLocks[m_nextCharacterId] == true || DoesCharacterHaveAnimations(m_nextCharacterId) == false)
				{
					if(m_nextCharacterId + 1 >= m_Characters.length)
					{
						m_nextCharacterId = 0;
					}
					else
					{
						++m_nextCharacterId;
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
					if(m_characterLocks[i] == false)	{++charactersAllowed;}
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
						
						if(m_characterLocks[randomCharId] == false && DoesCharacterHaveAnimations(randomCharId) == true)
						{
							if(charactersAllowed == 2)
							{
								m_nextCharacterId = randomCharId;
								switchOk = true;
							}
							else
							{
								if(m_nextCharacterId != randomCharId)
								{
									m_nextCharacterId = randomCharId;
									switchOk = true;
								}
							}
						}
					}
				}
			}
		}
		
		//Returns true if there was an actual character switch. Returns false otherwise
		public function UpdateAndDisplayCurrentCharacter(setFrameForAnimation:int=1):Boolean
		{
			var charSwitchOccured:Boolean = false;
			if (m_currentCharacter != null && CheckIfTransitionLockIsActive())	{return charSwitchOccured; }
			
			var currentCharacter:AnimatedCharacter = m_Characters[m_nextCharacterId];//m_currentCharacter;
			//If the current character selected is not the latest one being displayed, there needs to be some changes to get them on screen.
			if (m_currentCharacter != currentCharacter)
			{
				//Stop the old character's movieclips from playing. Not doing this causes issues with garbage collection, massively slowing down the flash.
				var characterRemoving:AnimatedCharacter = m_currentCharacter;
				if (characterRemoving)
				{
					characterRemoving.StopAnimation();
					characterRemoving.RemoveFromDisplay();
				}
				//var ThisisthefurtherestIgotinthisbeforestopping. ResumeFromHere.:2 = new String();
				//Remove the old character animation movie clip off the character layer
				//while (m_mainStage.CharacterLayer.numChildren > 1) 
				//{ m_mainStage.CharacterLayer.removeChildAt(m_mainStage.CharacterLayer.numChildren-1); }
				
				//Add the new character's animation movie clip
				currentCharacter.AddToDisplay(this);
				dispatchEvent(new ChangeBackgroundEvent(ChangeBackgroundEvent.CHANGE_BACKGROUND, currentCharacter.GetBackgroundColors()));
				
				//Update user settings
				//userSettings.currentCharacterName = GetCurrentCharacter().GetName();
				//Update latest char id 
				m_currentCharacter = currentCharacter;
				charSwitchOccured = true;
			}
			currentCharacter.RandomizePlayAnim();
			currentCharacter.PlayingLockedAnimCheck();
			currentCharacter.ChangeAnimationIndexToPlay();
			currentCharacter.GotoFrameAndPlayForCurrentAnimation(setFrameForAnimation);
			return charSwitchOccured;
		}
		
		public function GetIdOfCurrentCharacter():int
		{
			return GetCharacterIdByName(m_currentCharacter.GetName());
		}
		
		public function InitializeSettingsForCharacter(charId:int, settings:Object):void
		{
			var animLockObject:Object = settings.animationLocked;
			var character:AnimatedCharacter = m_Characters[charId];
			var lockedAnimationCount:int = 0;
			
			var accessibleAnimationsCount:int = character.GetNumberOfAccessibleAnimations();
			
			//If character has no animations then lock them.
			if (accessibleAnimationsCount == 0)
			{
				m_characterLocks[charId] = true;
				settings.locked = true;
				return;
			}
			
			//var animationSettingsIsEmpty:Boolean = true;
			/*Check to make sure that all loaded animations for the character are not locked. If they are
			* then they all need to be unlocked*/ 
			for (var name:String in settings.animationLocked) 
			{
				//animationSettingsIsEmpty = false;
				//If animation by the given name exists and the animation is not locked
				if(character.GetIdOfAnimationName(name) > -1 && settings.animationLocked[name] == true)
				{
					//Flag that all animations are not locked and break out the for loop
					++lockedAnimationCount;
				}
			}
			if (lockedAnimationCount >= accessibleAnimationsCount /*&& settings.animationLocked*/)
			{
				logger.warn("All animations for " + character.GetName() + " were locked. Unlocking all their animations.");
				//All animations were locked, so unlock them all to be safe.
				for (var i:int = 0; i < accessibleAnimationsCount; i++) 
				{
					character.SetLockOnAnimation(i, false);
					settings.animationLocked[character.GetNameOfAnimationById(i)] = false;
				}
			}
			else
			{
				for (var animationName:String in animLockObject)
				{
					var animId:int = character.GetIdOfAnimationName(animationName);
					character.SetLockOnAnimation(animId, animLockObject[animationName]);
				}
			}
			m_characterLocks[charId] = settings.locked;
			if (settings.locked == true)
			{
				++m_unswitchableCharactersNum;
			}
			var animSelect:int = character.GetIdOfAnimationName(settings.animationSelect);
			
			if (animSelect < 0 || character.GetAnimationLockedStatus(animSelect) == true)
			{
				//No id was found or the animation was locked, so go random instead.
				character.SetRandomizeAnimation(true);
			}
			else
			{
				character.SetRandomizeAnimation(false);
				character.ChangeAnimationIndexToPlay(animSelect);
			}
		}
		
		/*Attempts to queue up a change into a linked frame containing an animation. Animations are linked through the use of frame labels. 
		 * The scene to change from should have a label that follows the naming scheme of "Into_"{labelNameOfLinkedFrame}. For example, 
		 * to accomplish a cum transition, one frame would be labeled "Into_Scene" and another would simple be labeled "Scene".
		 * In the actual animation movie clip, a frame label named "ActivateWindow" is expected. This indicates how many frames
		 * the user has to input the Activate command. The frame after the end of the ActivateWindow is when the transition will happen.*/
		public function ActivateAnimationChange():void
		{
			//Already doing a transition or already is in the end part of a linked animation.
			if (transitionLockout == true || m_currentCharacter.IsStillInLinkedAnimation() == true) { return; } 
			
			var animationQueued:Boolean = m_currentCharacter.CheckAndSetupLinkedTransition();
			if (animationQueued == true)
			{
				transitionLockout = true;
				
				//Used to listen for when an activate animation transition has occured, to then allow character and animation changes to occur. 
				addEventListener(AnimationTransitionEvent.ANIMATION_TRANSITIONED, RemoveTransitionLockout, true);
			}
		}
		
		private function RemoveTransitionLockout(e:Event):void
		{
			removeEventListener(AnimationTransitionEvent.ANIMATION_TRANSITIONED, RemoveTransitionLockout);
			transitionLockout = false;
		}
		
		[inline]
		public function GetTotalNumOfCharacters():int
		{
			return m_Characters.length;
		}
		
		[inline]
		public function AreCharacterSwitchesAllowed():Boolean
		{
			return m_allowCharSwitches;
		}
		
		public function SetAllowingCharacterSwitching(canSwitch:Boolean):Boolean
		{
			m_allowCharSwitches = canSwitch;
			//userSettings.allowCharacterSwitches = switchStatus;
			if(!m_allowCharSwitches)
			{
				if(IsRandomlySelectingCharacter())	{SetIfRandomlySelectingCharacter(false);}
			}
			return m_allowCharSwitches;
		}
		
		/*Has the current character randomly select one of their animations and starts playing it from the
		 * specified frame. Returns the id of the animation that will play.*/
		public function RandomizeCurrentCharacterAnimation(playFromThisFrame:int):int
		{
			var currChar:AnimatedCharacter = m_currentCharacter;
			currChar.SetRandomizeAnimation(true);
			currChar.RandomizePlayAnim();
			//userSettings.characterSettings[currChar.GetName()].animationSelect = 0;
			
			currChar.GotoFrameAndPlayForCurrentAnimation(playFromThisFrame);
			return currChar.GetCurrentAnimationId();
		}
		
		//Returns true if the animation could be switched. false if the switch failed.
		public function ChangeAnimationForCurrentCharacter(characterAnimIndex:int):Boolean
		{
			var currChar:AnimatedCharacter = m_currentCharacter;
			if (CheckIfTransitionLockIsActive() || currChar.GetTotalNumberOfAnimations() < characterAnimIndex || 
				currChar.GetAnimationLockedStatus(characterAnimIndex))
			{
				return false;
			}
			currChar.SetRandomizeAnimation(false);
			currChar.ChangeAnimationIndexToPlay(characterAnimIndex);
			return true;
			//userSettings.characterSettings[currChar.GetName()].animationSelect = characterAnimFrame;
		}
		
		public function GetAnimationLocksOnCharacter():Vector.<Boolean>
		{
			return m_currentCharacter.GetAnimationLocks();
		}
		
		public function SetLockOnAnimationForCurrentCharacter(targetIndex:int, lock:Boolean):Boolean
		{
			m_currentCharacter.SetLockOnAnimation(targetIndex, lock);
			return m_currentCharacter.GetAnimationLockedStatus(targetIndex);
		}
		
		[inline]
		public function IsRandomlySelectingCharacter():Boolean
		{
			return m_selectRandomChar;
		}
		
		public function SetIfRandomlySelectingCharacter(randomSelect:Boolean):Boolean
		{
			m_selectRandomChar = randomSelect;
			//userSettings.randomlySelectCharacter = selectStatus;
			if(m_selectRandomChar == true)
			{
				//character switching needs to be allowed if we are to randomly select a character.
				if(!AreCharacterSwitchesAllowed())
				{
					SetAllowingCharacterSwitching(true);
				}
			}
			return m_selectRandomChar;
			
		}
		
		public function AreAnimationsRandomlyPickedForCurrentCharacter():Boolean
		{
			return m_currentCharacter.GetRandomAnimStatus();
		}
		
		public function SwitchToCharacter(charIndex:int=-1):int
		{
			//Undefined index, fall back to the first character
			if(charIndex == -1)
			{
				charIndex = 0;
			}
			if(m_characterLocks[charIndex] == false && m_currentCharacter != m_Characters[charIndex])
			{
				//m_currentCharacter = m_Characters[charIndex];
				m_nextCharacterId = charIndex;
				//UpdateAndDisplayCurrentCharacter();
				//userSettings.currentCharacterName = GetCurrentCharacter().GetName();
				
			}
			return m_nextCharacterId;
		}
		
		public function IsCharacterLocked(characterId:int):Boolean
		{
			return m_characterLocks[characterId];
		}
		
		public function ToggleLockOnCharacter(charIndex:int=-1):Boolean
		{
			if(charIndex == -1)	{charIndex = 0;}
			//Test if setting this character to be unselectable will result in all characters being unselectable
			if (m_characterLocks[charIndex] == false && m_unswitchableCharactersNum + 1 >= m_Characters.length)
			{
				return false; //Need to exit the function immediantly, 1 character must always be selectable.
			}
			m_characterLocks[charIndex] = !m_characterLocks[charIndex];
			//userSettings.characterSettings[m_Characters[charIndex].GetName()].canSwitchTo = m_canSwitchToCharacter[charIndex];
			if (m_characterLocks[charIndex] == true)
			{
				++m_unswitchableCharactersNum;
			}
			else
			{
				--m_unswitchableCharactersNum;
			}
			return m_characterLocks[charIndex];
		}
		
		[inline]
		public function GetCharacterNameById(charId:int):String
		{
			var name:String = null;
			if (charId > -1 && charId < m_Characters.length)
			{
				name = m_Characters[charId].GetName();
			}
			return name;
		}
		
		[inline]
		public function GetCharacterIdByName(name:String):int
		{
			var id:int = -1;
			if (name in m_charNamesDict)
			{
				id = m_charNamesDict[name];
			}
			return id;
		}
		
		public function GetCurrentCharacterName():String
		{
			var name:String= null;
			return m_currentCharacter.GetName();
		}
		
		public function GetIdOfAnimationNameForCharacter(charId:int, animationName:String):int
		{
			return m_Characters[charId].GetIdOfAnimationName(animationName);
		}
		
		public function GetNameOfAnimationByIdForCharacter(charId:int, animationId:int):String
		{
			return m_Characters[charId].GetNameOfAnimationById(animationId);
		}
		
		public function ChangeFrameOfCurrentAnimation(frame:int):void
		{
			m_currentCharacter.GotoFrameAndPlayForCurrentAnimation(frame);
		}
		
		[inline]
		public function CheckIfTransitionLockIsActive():Boolean
		{
			if (m_currentCharacter == null) { return false;}
			return transitionLockout == true || m_currentCharacter.IsStillInLinkedAnimation();
		}
		
		public function AllowChangeOutOfLinkedAnimation():void
		{
			var currentCharacter:AnimatedCharacter = m_currentCharacter;
			if (currentCharacter == null)	{ return; }
			
			if (transitionLockout == false && currentCharacter.IsStillInLinkedAnimation())
			{
				currentCharacter.ChangeInLinkedAnimationStatus(false);
				var idToRandomlySelect:int = -1; 
				var idTargets:Vector.<int> = currentCharacter.GetAnimationIdTargets();
				
				while (idToRandomlySelect < 0 && currentCharacter.GetAnimationLockedStatus(idToRandomlySelect) == false)
				{
					var index:int = Math.floor(Math.random() * idTargets.length)
					idToRandomlySelect = idTargets[index];
				}
				dispatchEvent(new Event(ExitLinkedAnimationEvent.EXIT_LINKED_ANIMATION));
				currentCharacter.ChangeAnimationIndexToPlay(idToRandomlySelect);
			}
		}
		
		public function GetCurrentAnimationIdOfCharacter():int
		{
			return m_currentCharacter.GetCurrentAnimationId();
		}
		
		public function GetIdTargetsOfCurrentCharacter():Vector.<int>
		{
			return m_currentCharacter.GetAnimationIdTargets();
		}
		
		public function IsCharacterSet():Boolean
		{
			return m_currentCharacter != null;
		}
		
		//Tests if the character of the given id has animations.
		public function DoesCharacterHaveAnimations(charId:int):Boolean
		{
			if (charId > -1 && charId < GetTotalNumOfCharacters())
			{
				return (m_Characters[charId].GetTotalNumberOfAnimations() > 0) ? true : false;
			}
			//Invalid id, so technically the char id given does not have any animations.
			return false;
		}
		
		public function GetPreferredMusicForCurrentCharacter():String
		{
			return m_currentCharacter.GetPreferredMusicName();
		}
		
		//Checks the character's animations to make sure at least 1 animation that is not an end link animation is accessible.
		//If there are none, unlock every animation that is not an end link.
		public function CheckLocksForCurrentCharacter():void
		{
			var currCharacter:AnimatedCharacter = m_currentCharacter;
			var accessibleAnimationCount:int = currCharacter.GetNumberOfAccessibleAnimations();
			if (accessibleAnimationCount == 0)
			{
				for (var i:int = 0; i < accessibleAnimationCount; ++i)
				{
					currCharacter.SetLockOnAnimation(i, false);
				}
				
			}
		}
		
		/*public function DEBUG_CharacterAnimationFrameCheck():void
		{
			if (m_currentCharacter)
			{
				m_currentCharacter.DEBUG_TraceCurrentFrame();
			}
		}*/
	}

}