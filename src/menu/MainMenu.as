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
		
		//consts
		public static const characterIconSize:Number = 35;
		
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
			characterMenu.AddEventListenerToCharList(events.LockEvent.LOCK, SetCharacterLock);
			
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
		
		public function SetupMenusForCharacter(charId:int, characterSettings:Object)
		{
			characterMenu.SetCharacterLock(charId, characterSettings.locked);
			
			//animationMenu.SetLockOnAnimation();
		}
		
		private function SelectHandler(e:Event):void
		{
			if (e.target.name == "Character Select List")
			{
				CharacterSelected(e);
			}
			else if (e.target.name == "Animation Select List")
			{
				AnimationSelected(e);
			}
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
		}
		
		/*Animation Menu*/
		//{
		//Need to access the current character to set or unset the lock the animation.
		private function SetAnimationLock(e:Event):void
		{
			var index:int = (e.target as AnimationList).rightClickedIndex;
			var listItemLock:Boolean = (e.target as AnimationList).selectedItem.locked;
			var newLock:Boolean = characterManager.SetLockOnAnimationForCurrentCharacter(index, listItemLock);
			//The animation's locked state could not be changed. Set the list item back to it's original lock state.
			if (listItemLock != newLock)
			{
				animationMenu.ChangeLockOnItem(index, newLock);
			}
			//var currentCharacterIdTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
			//var target:int = currentCharacterIdTargets[index];
			
		}
		
		/* Updates the animation select list to change the item index that should be selected)
		 * item index is the index that targets a specific animation id for a character. It can be obtained
		 * by searching for a given animation id in a characters idTargets vector.*/
		public function UpdateAnimationIndexSelected(itemIndex:int):void
		{
			animationMenu.ChangeSelectedItem(itemIndex);
		}
		
		public function GetTrueItemIndexFromRelativePosition(relativeIndex):int
		{
			if (relativeIndex == -1) { return -1; }
			var itemTrueIndex:int = animationMenu.GetTrueIndexOfItem(relativeIndex);
			return itemTrueIndex;
		}
		/*Changes the animation to play for the current character and updates the menus
		* Parameter relativeItemIndex: the index of the item currently on display. This index
		* does not correspond to the true index of the item, which requests knowing the value
		* of the vertical scroll bar.*/
		public function ChangeAnimationForCurrentCharacter(relativeItemIndex:int):void
		{
			if (relativeItemIndex == -1) { return; }
			var itemTrueIndex:int = animationMenu.GetTrueIndexOfItem(relativeItemIndex);
			characterManager.AllowChangeOutOfLinkedAnimation();
			ChangeAnimation(itemTrueIndex);
			
			//Need to update the menus since they only "auto" update when the mouse was clicked.
			var currentCharacterFrameTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
			var currentAnimFrame:int = characterManager.GetCurrentAnimationIdOfCharacter();
			var target:int = currentCharacterFrameTargets.indexOf(currentAnimFrame);
			animationMenu.ChangeSelectedItem(target);
			
			//animationMenu.ForceListRedraw();
		}
		/*Animation Menu Handlers (Mouse input)*/
		//{
		private function AnimationSelected(e:Event):void
		{
			if (e.target.selectedIndex == -1) { return; }
			ChangeAnimation(e.target.selectedIndex);
		}
		//}
		//Just changes the animation of the character and sets it to the proper time position
		[inline]
		private function ChangeAnimation(itemIndex:int):void
		{
			if (itemIndex == -1) { return;}
			var animationId:int = animationMenu.GetAnimationIdTargetOfItem(itemIndex);
			//var currentCharacter:AnimatedCharacter = characterManager.GetCurrentCharacter();
			characterManager.AllowChangeOutOfLinkedAnimation();
			//convert  animation frame to animation number (frame - 1 = number)
			characterManager.ChangeAnimationForCurrentCharacter(animationId);
			//currentCharacter.SetRandomizeAnimation(false);
			//currentCharacter.ChangeAnimationNumberToPlay();
			characterManager.ChangeFrameOfCurrentAnimation(currentFrameForAnimation);
			//currentCharacter.GotoFrameAndPlayForCurrentAnimation(currentFrameForAnimation);
			
		}
		//}
		
		/* Character Menu*/
		//{
		
		public function ToggleCharacterLock(indexOverride:int=-1):void
		{
			var index:int = (indexOverride == -1) ? characterMenu.ToggleLockOnMenuCursor() : indexOverride;
			var unlocked:Boolean = characterManager.ToggleLockOnCharacter(index);
			characterMenu.SetUnlockedStatus(index, unlocked);
			/*userSettings.ChangeCharacterLock(characterManager.GetCharacterById(e.target.rightClickedIndex).GetName(), 
				characterManager.GetCharacterLockById(e.currentTarget.rightClickedIndex));*/
		}
		
		//Keyboard Input
		//{
		[inline]
		public function SwitchToSelectedCharacter(indexOverride:int=-1):void
		{
			var selectedIndex:int = (indexOverride == -1) ? characterMenu.GetKeyboardMenuCursorIndex() : indexOverride;
			characterManager.AllowChangeOutOfLinkedAnimation();
			characterManager.SwitchToCharacter(selectedIndex);
			var currentCharacterFrameTargets:Vector.<int> = characterManager.GetIdTargetsOfCurrentCharacter();
			animationMenu.SetAnimationList(currentCharacterFrameTargets);
			animationMenu.ChangeSelectedItem(
				currentCharacterFrameTargets.indexOf(characterManager.GetCurrentAnimationIdOfCharacter()));
			//characterManager.GetCurrentCharacter()
			characterManager.ChangeFrameOfCurrentAnimation(currentFrameForAnimation);
		}
		//}
		
		
		//Positive number moves downward, negative moves upward.
		public function MoveCharacterSelector(indexMove:int):void
		{
			characterMenu.MoveListSelector(indexMove);
		}
		
		public function SetCharacterSelectorAndUpdate(index:int ):void
		{
			if (index < characterManager.GetTotalNumOfCharacters())
			{
				characterManager.AllowChangeOutOfLinkedAnimation();
				characterMenu.SetListSelectorPosition(index);
				
				SwitchToSelectedCharacter(index);
				//characterManager.SwitchToCharacter(index);
				//animationMenu.SetAnimationList(characterManager.GetFrameTargetsForCharacter(index));
			}
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
		/*Handler for when the select event is dispatched from the Character sub menu. Updates the character manager to let it know
		 * the character has changed.*/
		private function CharacterSelected(e:Event):void
		{
			SwitchToSelectedCharacter(e.target.selectedIndex);
			//characterManager.SwitchToCharacter(e.target.selectedIndex);
			//animationMenu.SetAnimationList(characterManager.GetFrameTargetsForCharacter(e.target.selectedIndex));
			//characterManager.ChangeFrameOfCurrentAnimation(currentFrameForAnimation);
			
		}
		
		private function SetCharacterLock(e:Event):void
		{
			//Ran into a bug where right clicking on an item still returned -1. Since it seems to be hard to replicate, just do a check
			//on rightClickedIndex.
			if (e.target.rightClickedIndex == -1) 
			{ 
				return;
			}
			ToggleCharacterLock(e.target.rightClickedIndex);
			/*characterManager.ToggleLockOnCharacter(e.target.rightClickedIndex);
			userSettings.ChangeCharacterLock(characterManager.GetCharacterById(e.target.rightClickedIndex).GetName(), 
				characterManager.GetCharacterLockById(e.currentTarget.rightClickedIndex));*/
		}
		
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