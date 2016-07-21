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
		private var charChangeModeButton:CharacterSelectModeButton;
		
		//consts
		public static const characterIconSize:Number = 35;
		public function CharacterMenu(initialCharacterSwitchMode:String="Normal") 
		{
			name = "Character Menu";
			characterList = new CharacterList(this);
			characterList.name = "Character Select List";
			characterList.listItemClass = CharacterListItem;
			characterList.listItemHeight = characterIconSize;
			characterList.setSize(characterIconSize+10,  characterIconSize * MAX_LIST_ITEMS_DISPLAYED);
			
			charChangeModeButton = new CharacterSelectModeButton(this, 0, characterList.y + characterList.height + 5);
			
			charChangeModeButton.normalIcon = new NormalRotationIcon();
			charChangeModeButton.randomIcon = new RandomRotationIcon;
			charChangeModeButton.singleIcon = new SingleCharIcon;
			charChangeModeButton.Initialize(initialCharacterSwitchMode);
			//charChangeModeButton.mode = 2;
			charChangeModeButton.setSize(characterIconSize+10,  characterIconSize+10);
			//characterList.addEventListener(Event.SELECT, CharacterSelected);
			//characterList.addEventListener(MouseEvent.RIGHT_CLICK, SetCharacterLock);
		}
		
		public function DisableScrollToSelectionForNextRedraw():void
		{
			characterList.DisableNextScrollToSelection();
		}
		
		public function AddEventListenerToCharList(eventType:String, func:Function):void
		{
			characterList.addEventListener(eventType, func);
		}
		
		public function ChangeModeOfCharacterChangeButton(modeString:String):void
		{
			charChangeModeButton.ChangeButtonMode(modeString);
		}
		
		/*Toggles the lock on the currently selected character on the menu. Used when the Keyboard is the input device.
		 * Returns the selected index of the character list.*/
		
		/*public function ToggleLockOnMenuCursor():int
		{
			if (characterList.menuCursorIndex > -1)
			{
				characterList.ToggleItemLock(characterList.menuCursorIndex);
			}
			return characterList.menuCursorIndex;
		}*/
		
		public function GetSelectedIndex():int
		{
			return characterList.selectedIndex;
		}
		
		public function GetKeyboardMenuCursorIndex():int
		{
			return characterList.menuCursorIndex;
		}
		
		public function MoveKeyboardListSelector(moveCount:int):void
		{
			var index:int = (characterList.menuCursorIndex + moveCount) % characterList.items.length;
			//trace("mouseOverIndex: " + characterList.menuCursorIndex);
			//trace("index: " + index);
			if (index < 0) { index = characterList.items.length -1;}
			//characterList.selectedIndex = index;
			characterList.menuCursorIndex = index;
		}
		
		public function SetListSelectorPosition(index:int):void
		{
			if (index > characterList.items.length) { index = characterList.items.length - 1; }
			characterList.selectedIndex = index;
			//characterList.menuCursorIndex = index;
		}
		
		/*public function ForceListRedraw():void
		{
			characterList.ForceRedraw();
		}*/
		
		
		public function SetCharacterLock(charIndex:int, locked:Boolean):void
		{
			characterList.items[charIndex].locked = locked;
			/*Force a redraw since the list will not update immediately if a keyboard related function 
			 * calls this ( those functions avoid calls to other functions that would lead to the list
			 * calling Invalidate() which normally would cause a redraw ).*/
			characterList.draw();
			//characterList.SetItemLock(charIndex, locked);
		}
		
		/*public function SetCharacterListLocks(locks:Vector.<Boolean>):void
		{
			characterList.SetItemLocks(locks);
		}*/
		
		public function AddIconToCharacterList(icon:DisplayObject):void
		{
			characterList.addItem({icon:icon, label:""});
		}
		
	}

}