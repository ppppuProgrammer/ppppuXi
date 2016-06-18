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
	public class CharacterMenu extends Sprite
	{
		private const MAX_LIST_ITEMS_DISPLAYED:int = 16;
		private const LIST_WIDTH:Number = 50;
		
		private var characterList:LockList;
		public function CharacterMenu() 
		{
			name = "Character Menu";
			characterList = new LockList(this);
			characterList.name = "Character Select List";
			characterList.listItemClass = LockListItem;
			characterList.listItemHeight = MainMenu.characterIconSize;
			characterList.setSize(LIST_WIDTH,  MainMenu.characterIconSize * MAX_LIST_ITEMS_DISPLAYED);
			//characterList.addEventListener(Event.SELECT, CharacterSelected);
			//characterList.addEventListener(MouseEvent.RIGHT_CLICK, SetCharacterLock);
		}
		
		public function AddEventListenerToCharList(eventType:String, func:Function):void
		{
			characterList.addEventListener(eventType, func);
		}
		
		public function MoveListSelector(moveCount:int):void
		{
			var index:int = (characterList.selectedIndex + moveCount) % characterList.items.length;
			if (index < 0) { index = 0;}
			characterList.selectedIndex = index;
		}
		
		public function SetCharacterListLocks(locks:Vector.<Boolean>):void
		{
			characterList.SetItemLocks(locks);
		}
		
		public function AddIconToCharacterList(icon:DisplayObject):void
		{
			characterList.addItem(icon);
		}
		
	}

}