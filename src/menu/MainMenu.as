package menu 
{
	import com.bit101.components.PushButton;
	import events.LockEvent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class MainMenu extends Sprite
	{
		//ppppu systems
		private var characterManager:CharacterManager;
		private var musicPlayer:MusicPlayer;
		private var userSettings:UserSettings;
		
		//private var characterSubmenu:LockList;
		
		
		private var characterMenu:CharacterMenu;
		private var animationMenu:AnimationMenu;
		
		/*Tells what frame the currently playing animation should be on. The only exception to this are animations that require a 
		 * transition to be accessed.*/
		private var currentFrameForAnimation:int = 0;
		
		private var settingsButton:PushButton;
		private var keyConfig:Config;
		
		
		
		public function MainMenu(charManager:CharacterManager, bgmPlayer:MusicPlayer, settings:UserSettings) 
		{
			characterManager = charManager;
			musicPlayer = bgmPlayer;
			userSettings = settings;
			keyConfig = new Config(userSettings);
		}
		
		public function Initialize():void
		{
			characterMenu = new CharacterMenu();
			addChild(characterMenu);
			
			addEventListener(Event.SELECT, SelectHandler, true);
			addEventListener(LockEvent.LOCK, LockHandler, true);
			
			//characterMenu.AddEventListenerToCharList(Event.SELECT, CharacterSelected);
			//characterMenu.AddEventListenerToCharList(events.LockEvent.LOCK, SetCharacterLock);
			
			settingsButton = new PushButton(this, 0, 640, "", OpenSettingsWindow);
			settingsButton.setSize(32, 32);
			var settingsIcon:SettingsIcon = new SettingsIcon();
			//settingsIcon.width = settingsIcon.height = 24;
			
			settingsButton.addChild(settingsIcon);
			
			animationMenu = new AnimationMenu(this, 550);
			animationMenu.x = stage.stageWidth - animationMenu.width;
			//animationMenu.AddEventListenerToAnimList(Event.SELECT, AnimationSelected);
			//characterMenu
		}
		
		public function SetupMenusForCharacter(charId:int, characterSettings:Object):void
		{
			characterMenu.SetCharacterLock(charId, characterSettings.locked);
			
			//animationMenu.SetLockOnAnimation();
		}
		
		/* Mouse event Handlers */
		//{
		private function SelectHandler(e:Event):void
		{
			switch(e.target.name)
			{
				case "Character Select List": SelectCharacter(e); break;
				case "Animation Select List": SelectAnimation(e); break;
				case "Random Animation Button": SelectAnimation(null, -1); break;
			}
			/*if (e.target.name == "Character Select List")
			{
				SelectCharacter(e);
			}
			else if (e.target.name == "Animation Select List")
			{
				SelectAnimation(e);
			}*/
			e.stopPropagation();
		}
		
		private function LockHandler(e:Event):void
		{
			if (e.target.name == "Character Select List")
			{
				SetCharacterLock(e);
			}
			else if (e.target.name == "Animation Select List")
			{
				SetAnimationLock(e);
			}
			e.stopPropagation();
		}
		//}
		
		/*Handler for when the select event is dispatched from the Character sub menu. Updates the character manager to let it know
		 * the character has changed.*/
		public function SelectCharacter(e:Event=null):void
		{
			var index:int = -1;
			if (e != null)
			{
				index = e.target.selectedIndex;
			}
			else
			{
				index = characterMenu.GetKeyboardMenuCursorIndex();
			}
			
			if (characterManager.DoesCharacterHaveAnimations(index) == true)
			{
				characterManager.AllowChangeOutOfLinkedAnimation();
				var newCharId:int = characterManager.SwitchToCharacter(index);
				if (newCharId != index)	{ return; }
				
				characterManager.UpdateAndDisplayCurrentCharacter();
				var currentCharacterFrameTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
				var currentCharacterLockedAnimations:Vector.<Boolean> = characterManager.GetAnimationLocksOnCharacter();
				animationMenu.SetAnimationList(currentCharacterLockedAnimations);
				animationMenu.ChangeSelectedItem(
					currentCharacterFrameTargets.indexOf(characterManager.GetCurrentAnimationIdOfCharacter()));
				
				var animationsPickRandomly:Boolean = characterManager.AreAnimationsRandomlyPickedForCurrentCharacter();
				animationMenu.SetSelectOnRandomAnimationButton(animationsPickRandomly);
				characterManager.ChangeFrameOfCurrentAnimation(currentFrameForAnimation);
				userSettings.UpdateCurrentCharacterName(characterManager.GetCurrentCharacterName());
			}
			else
			{
				characterMenu.SetListSelectorPosition(characterManager.GetIdOfCurrentCharacter());
			}
			/*if (e == null)
			{
				
			}*/
			
		}
		
		/*Animation Menu Handlers (Mouse input)*/
		//{
		//e - Event sent if a button was clicked to select an animation
		//relativeListIndex - The index of the animation list the user wishes to select with keyboard.
		//-2 means to pick no animation, -1 means to select a random animation, 0 and greater pick a value that is
		//relativeListIndex's value + the animation list's scrollbar offset and that is used to determine which accessible animation to use
		public function SelectAnimation(e:Event=null, relativeListIndex:int=-2):void
		{
			var index:int = -1;
			if (e != null)
			{
				index = e.target.selectedIndex;
			}
			else
			{
				//Random select
				if (relativeListIndex == -1)
				{
					index = characterManager.RandomizeCurrentCharacterAnimation(currentFrameForAnimation);
					//var currentCharacterIdTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
					//var target:int = currentCharacterIdTargets.indexOf(index); 
					UpdateAnimationIndexSelected(index);
					//Update the random animation button to be selected.
					animationMenu.SetSelectOnRandomAnimationButton(true);
					userSettings.UpdateSettingForCharacter_SelectedAnimation(characterManager.GetCharacterNameById(characterMenu.GetSelectedIndex()), 0);
					return;
				}
				else if (relativeListIndex > -1)
				{
					index = GetTrueItemIndexFromRelativePosition(relativeListIndex);
				}
			}
			if (index == -1) { return; }
			
			
			//Animation menu is in "lock animation mode" for key inputs
			if (e == null && animationMenu.GetIfKeyboardModeIsInChangeMode() == false) 
			{
				SetAnimationLock(null, index);	
			}
			else //Animation Menu is either in "change animation mode" for key inputs or there was mouse input.
			{
				var currentCharacterIdTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
				characterManager.AllowChangeOutOfLinkedAnimation();
				//Need to get the index that targets the given animation id.
				var target:int = currentCharacterIdTargets.indexOf(index);
				
				var switchSuccessful:Boolean = characterManager.ChangeAnimationForCurrentCharacter(target);
				if (switchSuccessful == true)	
				{ 
					characterManager.ChangeFrameOfCurrentAnimation(currentFrameForAnimation); 
					//For keyboard input the animation items need to be manually updated to reflect any changes.
					if (e == null)
					{
						UpdateAnimationIndexSelected(index); 
					}
					else
					{
						userSettings.UpdateSettingForCharacter_SelectedAnimation(characterManager.GetCharacterNameById(characterMenu.GetSelectedIndex()), index);
					}
				}
				//Update the random animation button to no longer be selected.
				animationMenu.SetSelectOnRandomAnimationButton(false);
			}
		}
		
		/*private function RandomAnimationButtonHandler(e:Event):void
		{
			
		}*/
		//}
		
		/* Keyboard functions */
		//{
		public function SetCharacterLock(e:Event = null):void
		{
			var index:int;
			index = (e != null) ? e.target.rightClickedIndex : GetIndexOfCharacterKeyboardMenuCursor();

			if (index != -1)
			{
				characterMenu.DisableScrollToSelectionForNextRedraw();
				var locked:Boolean = characterManager.ToggleLockOnCharacter(index);
				characterMenu.SetCharacterLock(index, locked);
				userSettings.UpdateSettingForCharacter_Lock(characterManager.GetCharacterNameById(index), locked);
			}
		}
		//}
		
		/*Animation Menu*/
		//{
		//Need to access the current character to set or unset the lock the animation.
		private function SetAnimationLock(e:Event = null, animationIndex:int = -1):void
		{
			animationMenu.DisableScrollToSelectionForNextRedraw();
			var index:int;
			if (e != null) 
			{ index = (e.target as AnimationList).rightClickedIndex; } 
			else 
			{ index = animationIndex;}
			
			var listItemLock:Boolean = animationMenu.GetLockOnItem(index);
			
			var newLock:Boolean;
			//Keyboard doesn't initially change the lock on the item like when clicking it, so that has to be done manually.
			if (e == null) 
			{ newLock = characterManager.SetLockOnAnimationForCurrentCharacter(index, !listItemLock); }
			else
			{ newLock = characterManager.SetLockOnAnimationForCurrentCharacter(index, listItemLock); }
			
			//The animation's locked state could not be changed. Set the list item back to it's original lock state.
			if (listItemLock != newLock)
			{
				animationMenu.ChangeLockOnItem(index, newLock);
			}
			userSettings.UpdateSettingForCharacter_AnimationLock(
				characterManager.GetCharacterNameById(characterMenu.GetSelectedIndex()), index, newLock);
			
		}
		
		/* Updates the animation select list to change the item index that should be selected)
		 * item index is the index that targets a specific animation id for a character. It can be obtained
		 * by searching for a given animation id in a characters idTargets vector.*/
		public function UpdateAnimationIndexSelected(itemIndex:int, moveScrollBar:Boolean = true):void
		{
			animationMenu.ChangeSelectedItem(itemIndex, moveScrollBar);
		}
		
		public function GetTrueItemIndexFromRelativePosition(relativeIndex:int):int
		{
			if (relativeIndex == -1) { return -1; }
			var itemTrueIndex:int = animationMenu.GetTrueIndexOfItem(relativeIndex);
			return itemTrueIndex;
		}
		
		
		/* Character Menu*/
		//{
		[inline]
		public function UpdateAnimationMenuForCharacter(/*charId:int*/):void
		{
			var currentCharacterFrameTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
			var currentCharacterLockedAnimations:Vector.<Boolean> = characterManager.GetAnimationLocksOnCharacter();
			animationMenu.SetAnimationList(currentCharacterLockedAnimations);
			/*animationMenu.ChangeSelectedItem(
				currentCharacterFrameTargets.indexOf(characterManager.GetCurrentAnimationIdOfCharacter()));*/	
		}
		
		[inline]
		public function GetIndexOfCharacterKeyboardMenuCursor():int
		{
			return characterMenu.GetKeyboardMenuCursorIndex();
		}
		
		
		//Positive number moves downward, negative moves upward.
		public function MoveCharacterSelector(indexMove:int):void
		{
			characterMenu.MoveKeyboardListSelector(indexMove);
		}
		
		public function SetCharacterSelectorAndUpdate(index:int ):void
		{
			if (index < characterManager.GetTotalNumOfCharacters())
			{
				if (characterManager.DoesCharacterHaveAnimations(index) == false)
				{
					return;
				}
				//characterManager.AllowChangeOutOfLinkedAnimation();
				characterMenu.SetListSelectorPosition(index);
				UpdateAnimationMenuForCharacter();
			}
		}
		
		public function ToggleAnimationMenuKeyboardMode():Boolean
		{
			var changeMode:Boolean = animationMenu.GetIfKeyboardModeIsInChangeMode();
			return animationMenu.SetKeyboardMode(!changeMode);
		}
		
		/*public function SetInitialCharacterLock(charId:int, unlocked:Boolean):void
		{
			characterMenu.SetCharacterLock(charId, unlocked);
		}*/
		
		/*public function SetupCharacterLocks():void
		{
			//the get all character locks answers the question "Can I switch to this character?"
			var locks:Vector.<Boolean> = characterManager.GetAllCharacterLocks();
			//The lock list item answers the question "Is this character locked?"
			characterMenu.SetCharacterListLocks(locks);
		}*/
		
		public function AddIconToCharacterMenu(icon:DisplayObject):void
		{
			characterMenu.AddIconToCharacterList(icon);
		}
		
		//Event handlers (Mouse input)
		//{
		
		
		public function UpdateFrameForAnimationCounter(frame:int):void
		{
			currentFrameForAnimation = frame;
		}
		
		public function OpenSettingsWindow(e:MouseEvent):void
		{
			addChild(keyConfig);
		}
		//}
		
		//}
		
	}

}