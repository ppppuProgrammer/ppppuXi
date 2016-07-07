package 
{
	import events.AnimationTransitionEvent;
	import events.ChangeBackgroundEvent;
	import events.ExitLinkedAnimationEvent;
	import flash.display.Sprite;
	import flash.events.DRMReturnVoucherCompleteEvent;
	import flash.events.Event;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author 
	 */
	public class CharacterManager extends Sprite
	{
		private var m_charNamesDict:Dictionary = new Dictionary(); //Maps the character's name to an id number(int) (ie. "Peach" has an id of 0)
		private var m_Characters:Vector.<AnimatedCharacter> = new Vector.<AnimatedCharacter>();
		
		private var m_currentCharacterId:int = 0;
		//The character that is being managed.
		private var m_currentCharacter:AnimatedCharacter = null;
		//The character that is being displayed on the stage.
		private var m_latestCharacter:AnimatedCharacter = null;
		
		//Controls whether the user wants character switching to be allowed or not.
		private var m_allowCharSwitches:Boolean = true;
		//Controls whether the user wants a character to be randomly picked when it's switching time.
		private var m_selectRandomChar:Boolean = false;
		//Indicates if a character can be switched to. The index of the vector correspondes to the character's id.
		private var m_characterLocks:Vector.<Boolean> = new Vector.<Boolean>();
		//Keep a tally of how many characters are not able to be switched to.
		private var m_unswitchableCharactersNum:int = 0;
		
		//"global" character and animation switch lock. Meant to be used for linked animation transitions so that they happen uninterrupted.
		private var transitionLockout:Boolean = false;
		
		public function CharacterManager() {}
		
		/*Adds a new character to be able to be shown. Returns true if the character was added successfully. Returns false if the
		character was missing necessary data or there was a character name conflict.*/
		public function AddCharacter(character:AnimatedCharacter):Boolean
		{
			var charAdded:Boolean = false;
			var charName:String = character.GetName();
			//Make sure no character with this name already exists.
			for (var x:int = 0, y:int = m_Characters.length; x < y; ++x)
			{
				if (charName == m_Characters[x].GetName())
				{
					return charAdded;
				}
			}
			
			if (character.IsValidCharacter())
			{
				m_charNamesDict[charName] = m_Characters.length;
				m_characterLocks[m_Characters.length] = false;
				m_Characters[m_Characters.length] = character;
				charAdded = true;
			}
			return charAdded;
		}
		
		//The logic for the normal switch that happens every 120 frames
		public function CharacterSwitchLogic():void
		{
			if (m_currentCharacter != null && CheckIfTransitionLockIsActive())	{ return; }
			
			//Sequential character changing
			if(!m_selectRandomChar)
			{
				//character list wrap around
				if(m_currentCharacterId + 1 >= m_Characters.length)
				{
					m_currentCharacterId = 0;
				}
				else
				{
					//go to next character
					++m_currentCharacterId;
				}
				//Make sure the character can be switched to. If not, cycle through until we find one we can switch to
				while(m_characterLocks[m_currentCharacterId] == true)
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
						
						if(m_characterLocks[randomCharId] == false)
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
		
		//Returns true if there was an actual character switch. Returns false otherwise
		public function DisplayAndUpdateCurrentCharacter(setFrameForAnimation:int=1):Boolean
		{
			var charSwitchOccured:Boolean = false;
			if (m_currentCharacter != null && CheckIfTransitionLockIsActive())	{return charSwitchOccured; }
			
			var currentCharacter:AnimatedCharacter = m_currentCharacter;
			//If the current character selected is not the latest one being displayed, there needs to be some changes to get them on screen.
			if (m_latestCharacter != currentCharacter)
			{
				//Stop the old character's movieclips from playing. Not doing this causes issues with garbage collection, massively slowing down the flash.
				var characterRemoving:AnimatedCharacter = m_latestCharacter;
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
				m_latestCharacter = currentCharacter;
				charSwitchOccured = true;
			}
			currentCharacter.RandomizePlayAnim();
			currentCharacter.PlayingLockedAnimCheck();
			currentCharacter.ChangeAnimationIndexToPlay();
			currentCharacter.GotoFrameAndPlayForCurrentAnimation(setFrameForAnimation);
			return charSwitchOccured;
		}
		
		public function InitializeSettingsForCharacter(charId:int, settings:Object):void
		{
			var animLockObject:Object = settings.animationLocked;
			var character:AnimatedCharacter = m_Characters[charId];
			for (var animationFrameStr:String in animLockObject)
			{
				var animFrame:int = int(animationFrameStr);
				character.SetLockOnAnimation(animFrame, animLockObject[animFrame]);
			}
			m_characterLocks[charId] = settings.locked;
			var animSelect:int = settings.animationSelect;
			if (animSelect == 0)
			{
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
		
		public function SetAllowingCharacterSwitching(canSwitch:Boolean):void
		{
			m_allowCharSwitches = canSwitch;
			//userSettings.allowCharacterSwitches = switchStatus;
			if(!m_allowCharSwitches)
			{
				if(IsRandomlySelectingCharacter())	{SetIfRandomlySelectingCharacter(false);}
			}
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
		
		public function SetIfRandomlySelectingCharacter(randomSelect:Boolean):void
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
			
		}
		
		public function SwitchToCharacter(charIndex:int=-1):void
		{
			//Undefined index, fall back to the first character
			if(charIndex == -1)
			{
				charIndex = 0;
			}
			if(m_characterLocks[charIndex] == false && m_currentCharacter != m_Characters[charIndex])
			{
				m_currentCharacter = m_Characters[charIndex];
				DisplayAndUpdateCurrentCharacter();
				//userSettings.currentCharacterName = GetCurrentCharacter().GetName();
				
			}
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
		
		public function GetCharacterIdByName(name:String):int
		{
			var id:int = -1;
			if (name in m_charNamesDict)
			{
				id = m_charNamesDict[name];
			}
			return id;
		}
		
		public function ChangeFrameOfCurrentAnimation(frame:int):void
		{
			m_currentCharacter.GotoFrameAndPlayForCurrentAnimation(frame);
		}
		
		[inline]
		private function CheckIfTransitionLockIsActive():Boolean
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
	}

}