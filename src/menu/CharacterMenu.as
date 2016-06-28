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
	public class CharacterMenu extends Sprite
	{
		private const MAX_LIST_ITEMS_DISPLAYED:int = 16;
		private const LIST_WIDTH:Number = 50;
		
		private var characterList:CharacterList;
		
		public function CharacterMenu() 
		{
			name = "Character Menu";
			characterList = new CharacterList(this);
			characterList.name = "Character Select List";
			characterList.listItemClass = CharacterListItem;
			characterList.listItemHeight = MainMenu.characterIconSize;
			characterList.setSize(LIST_WIDTH,  MainMenu.characterIconSize * MAX_LIST_ITEMS_DISPLAYED);
			
			//characterList.addEventListener(Event.SELECT, CharacterSelected);
			//characterList.addEventListener(MouseEvent.RIGHT_CLICK, SetCharacterLock);
		}
		
		public function AddEventListenerToCharList(eventType:String, func:Function):void
		{
			characterList.addEventListener(eventType, func);
		}
		
		public function SetUnlockedStatus(index:int, unlocked:Boolean):void
		{
			characterList.items[index].unlocked = unlocked;
		}
		
		/*Toggles the lock on the currently selected character on the menu. Used when the Keyboard is the input device.
		 * Returns the selected index of the character list.*/
		
		public function ToggleLockOnMenuCursor():int
		{
			if (characterList.menuCursorIndex > -1)
			{
				characterList.ToggleItemLock(characterList.menuCursorIndex);
			}
			return characterList.menuCursorIndex;
		}
		
		public function GetSelectedIndex():int
		{
			return characterList.selectedIndex;
		}
		
		public function GetKeyboardMenuCursorIndex():int
		{
			return characterList.menuCursorIndex;
		}
		
		public function MoveListSelector(moveCount:int):void
		{
			var index:int = (characterList.menuCursorIndex + moveCount) % characterList.items.length;
			trace("mouseOverIndex: " + characterList.menuCursorIndex);
			trace("index: " + index);
			if (index < 0) { index = characterList.items.length -1;}
			//characterList.selectedIndex = index;
			characterList.menuCursorIndex = index;
		}
		
		public function SetListSelectorPosition(index:int):void
		{
			if (index > characterList.items.length) { index = characterList.items.length - 1; }
			characterList.selectedIndex = index;
			characterList.menuCursorIndex = index;
		}
		
		/*public function ForceListRedraw():void
		{
			characterList.ForceRedraw();
		}*/
		
		public function SetCharacterListLocks(locks:Vector.<Boolean>):void
		{
			characterList.SetItemLocks(locks);
		}
		
		public function AddIconToCharacterList(icon:DisplayObject):void
		{
			characterList.addItem({icon:icon, label:""});
		}
		
	}

}