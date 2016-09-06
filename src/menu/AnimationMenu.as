package menu 
{
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.Label;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class AnimationMenu extends Panel
	{
		public const AnimationButtonSize:Number = 35;
		private const MAX_ITEMS_DISPLAYED:int = 9;
		
		//Text
		private var modeLabel:Label;
		
		//Animation List
		private var animationList:AnimationList;
		
		//Buttons
		private var randomAnimationButton:RandomAnimationButton;
		
		private var buttonYPos:Number = 10;
		//Used for functions that activate through keyboard input
		private var inChangeMode:Boolean = true;
		public function AnimationMenu(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0)
		{
			name = "Animation Menu";
			super(parent, xpos, ypos);
			
			
			//list
			animationList = new AnimationList(this, 0, 35);
			animationList.name = "Animation Select List";
			animationList.listItemClass = AnimationListItem;
			animationList.listItemHeight = AnimationButtonSize;
			//10 units are used for the scrollbar, so have to add 10 to the button size so the button will actually end up being the desired size.
			animationList.setSize(AnimationButtonSize + 10, AnimationButtonSize * MAX_ITEMS_DISPLAYED);
			
			//animationList.rolloverColor = 0xEEEEEE;
			
			randomAnimationButton = new RandomAnimationButton(this, 0, animationList.y + animationList.height, "?");
			randomAnimationButton.setSize(45, 45);
			randomAnimationButton.name = "Random Animation Button";
			modeLabel = new Label(this, 5, 0, "Mode:\nChange");
			
			setSize(45, randomAnimationButton.y + randomAnimationButton.height);
			/*anim1Button = new PushButton(this, 5, GetYPosForButton(), "1");
			anim1Button.setSize(AnimationButtonSize, AnimationButtonSize);
			anim1Button.label
			anim2Button = new PushButton(this, 5, GetYPosForButton(), "2");
			anim2Button.setSize(AnimationButtonSize, AnimationButtonSize);*/
		}
		
		//private function RandomAnimationButton
		
		public function GetLockOnItem(index:int):Boolean
		{
			return animationList.items[index].locked;
		}
		
		public function GetIfKeyboardModeIsInChangeMode():Boolean
		{
			return inChangeMode;
		}
		
		public function SetKeyboardMode(changeMode:Boolean):Boolean
		{
			if (changeMode == true)
			{
				modeLabel.text = "Mode:\nChange";
			}
			else
			{
				modeLabel.text = "Mode:\nLock";
			}
			inChangeMode = changeMode;
			return inChangeMode;
		}
		
		public function DisableScrollToSelectionForNextRedraw():void
		{
			animationList.DisableNextScrollToSelection();
		}
		
		//Mouse input
		public function SetSelectOnRandomAnimationButton(selected:Boolean):void
		{
			randomAnimationButton.selected = selected;
		}
		
		/*public function AddEventListenerToAnimList(eventType:String, func:Function):void
		{
			animationList.addEventListener(eventType, func);
		}*/
		
		/*public function ForceListRedraw():void
		{
			animationList.ForceRedraw();
		}*/
		
		public function GetTrueIndexOfItem(relativeIndex:int):int
		{
			return animationList.GetTrueAnimationIndex(relativeIndex);
		}
		
		public function SetAnimationList(locks:Vector.<Boolean>):void
		{
			animationList.ResetList(locks);
		}
		
		public function ChangePageForItemsDisplayedOnList(nextPage:Boolean = true):void
		{
			animationList.ChangeAnimationItemsShown(nextPage);
		}
		
		public function ChangeSelectedItem(index:int, moveScrollBar:Boolean=true):void
		{
			if (moveScrollBar == true)	
			{animationList.selectedIndex = index;}
			else
			{
				animationList.ChangeSelectedIndexWithoutMovingScrollBar(index);
				animationList.DisableNextScrollToSelection();
			}
			//Avoid a flicker caused by the list (and its items) taking too long to be redrawn.
			//animationList.draw();
			animationList.ForceItemRedrawThisFrame();
		}
		
		public function ChangeLockOnItem(index:int, lock:Boolean):void
		{
			animationList.items[index].locked = lock;
			animationList.draw();
			//animationList.SetItemLock(index, lock);
			//animationList.ForceItemRedrawThisFrame();
		}
	}

}