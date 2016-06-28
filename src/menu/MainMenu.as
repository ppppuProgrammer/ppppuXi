package menu 
{
	import com.bit101.components.PushButton;
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
			
			characterMenu.AddEventListenerToCharList(Event.SELECT, CharacterSelected);
			characterMenu.AddEventListenerToCharList(RightClickedEvent.RIGHT_CLICKED, SetCharacterLock);
			
			settingsButton = new PushButton(this, 0, 640, "", OpenSettingsWindow);
			settingsButton.setSize(32, 32);
			var settingsIcon:SettingsIcon = new SettingsIcon();
			//settingsIcon.width = settingsIcon.height = 24;
			
			settingsButton.addChild(settingsIcon);
			
			animationMenu = new AnimationMenu(this, 550);
			animationMenu.AddEventListenerToAnimList(Event.SELECT, AnimationSelected);
			//characterMenu
		}
		
		/*Animation Menu*/
		//{
		/*Changes the animation to play for the current character and updates the menus
		* Parameter relativeItemIndex: the index of the item currently on display. This index
		* does not correspond to the true index of the item, which requests knowing the value
		* of the vertical scroll bar.*/
		public function ChangeAnimationForCurrentCharacter(relativeItemIndex:int):void
		{
			if (relativeItemIndex == -1) { return; }
			var currentCharacter:AnimatedCharacter = characterManager.GetCurrentCharacter();
			var itemTrueIndex:int = animationMenu.GetTrueIndexOfItem(relativeItemIndex);
			ChangeAnimation(itemTrueIndex);
			
			//Need to update the menus since they only "auto" update when the mouse was clicked.
			var currentCharacterFrameTargets:Vector.<int> = currentCharacter.GetFrameTargets();
			var currentAnimFrame:int = currentCharacter.GetCurrentAnimationFrame();
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
			var animationFrame:int = animationMenu.GetAnimationFrameTargetOfItem(itemIndex);
			var currentCharacter:AnimatedCharacter = characterManager.GetCurrentCharacter();
			//convert  animation frame to animation number (frame - 1 = number)
			characterManager.ChangeAnimForCurrentCharacter(animationFrame-1);
			//currentCharacter.SetRandomizeAnimation(false);
			//currentCharacter.ChangeAnimationNumberToPlay();
			currentCharacter.GotoFrameAndPlayForCurrentAnimation(currentFrameForAnimation);
			
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
			characterManager.SwitchToCharacter(selectedIndex);
			var currentCharacterFrameTargets:Vector.<int> = characterManager.GetCurrentCharacter().GetFrameTargets();
			animationMenu.SetAnimationList(currentCharacterFrameTargets);
			animationMenu.ChangeSelectedItem(
				currentCharacterFrameTargets.indexOf(characterManager.GetCurrentCharacter().GetCurrentAnimationFrame()));
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
				characterMenu.SetListSelectorPosition(index);
				SwitchToSelectedCharacter(index);
				//characterManager.SwitchToCharacter(index);
				//animationMenu.SetAnimationList(characterManager.GetFrameTargetsForCharacter(index));
			}
		}
		
		public function SetupCharacterLocks():void
		{
			//the get all character locks answers the question "Can I switch to this character?"
			var locks:Vector.<Boolean> = characterManager.GetAllCharacterLocks();
			//The lock list item answers the question "Is this character locked?"
			characterMenu.SetCharacterListLocks(locks);
		}
		
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