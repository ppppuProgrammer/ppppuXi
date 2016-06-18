package menu 
{
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
		
		//consts
		public static const characterIconSize:Number = 35;
		
		public function MainMenu(charManager:CharacterManager, bgmPlayer:MusicPlayer, settings:UserSettings) 
		{
			characterManager = charManager;
			musicPlayer = bgmPlayer;
			userSettings = settings;
		}
		
		public function Initialize():void
		{
			characterMenu = new CharacterMenu();
			addChild(characterMenu);
			
			
			characterMenu.AddEventListenerToCharList(Event.SELECT, CharacterSelected);
			characterMenu.AddEventListenerToCharList(MouseEvent.RIGHT_CLICK, SetCharacterLock);
			
			//characterMenu
		}
		
		/* Character Menu*/
		//{
		
		//Positive number moves downward, negative moves upward.
		public function MoveCharacterSelector(indexMove:int):void
		{
			characterMenu.MoveListSelector(indexMove);
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
		
		//Event handlers
		//{
		/*Handler for when the select event is dispatched from the Character sub menu. Updates the character manager to let it know
		 * the character has changed.*/
		private function CharacterSelected(e:Event):void
		{
			characterManager.GotoSelectedMenuCharacter(e.target.selectedIndex);
			
		}
		
		private function SetCharacterLock(e:Event):void
		{
			//Ran into a bug where right clicking on an item still returned -1. Since it seems to be hard to replicate, just do a check
			//on rightClickedIndex.
			if (e.currentTarget.rightClickedIndex == -1) 
			{ 
				return;
			}
			characterManager.ToggleSelectedMenuCharacterLock(e.currentTarget.rightClickedIndex);
			userSettings.ChangeCharacterLock(characterManager.GetCharacterById(e.currentTarget.rightClickedIndex).GetName(), 
				characterManager.GetCharacterLockById(e.currentTarget.rightClickedIndex));
		}
		//}
		
		//}
		
	}

}