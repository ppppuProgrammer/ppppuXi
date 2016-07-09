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
		public const AnimationButtonSize:Number = 30;
		private const MAX_ITEMS_DISPLAYED:int = 9;
		
		//Text
		private var modeLabel:Label;
		
		//Animation List
		private var animationList:AnimationList;
		
		//Buttons
		private var randomAnimationButton:PushButton;
		
		private var buttonYPos:Number = 10;
		//Used for functions that activate through keyboard input
		private var inChangeMode:Boolean = true;
		public function AnimationMenu(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0)
		{
			name = "Animation Menu";
			super(parent, xpos, ypos);
			setSize(40, 440);
			
			//list
			animationList = new AnimationList(this, 0, 40);
			animationList.name = "Animation Select List";
			animationList.listItemClass = AnimationListItem;
			animationList.setSize(40, AnimationButtonSize * MAX_ITEMS_DISPLAYED);
			animationList.listItemHeight = AnimationButtonSize;
			//animationList.rolloverColor = 0xEEEEEE;
			
			randomAnimationButton = new PushButton(this, 0, animationList.y + animationList.height + 5, "?");
			randomAnimationButton.setSize(40, 40);
			//randomAnimationButton.
			modeLabel = new Label(this, 5, 0, "Key Mode:\nChange");
			
			/*anim1Button = new PushButton(this, 5, GetYPosForButton(), "1");
			anim1Button.setSize(AnimationButtonSize, AnimationButtonSize);
			anim1Button.label
			anim2Button = new PushButton(this, 5, GetYPosForButton(), "2");
			anim2Button.setSize(AnimationButtonSize, AnimationButtonSize);*/
		}
		
		//private function RandomAnimationButton
		
		public function SetKeyboardMode(changeMode:Boolean):void
		{
			if (changeMode == true)
			{
				modeLabel.text = "Key Mode:\nChange";
			}
			else
			{
				modeLabel.text = "Key Mode:\nLock";
			}
			inChangeMode = changeMode;
		}
		
		public function DisableScrollToSelectionForNextRedraw():void
		{
			animationList.DisableNextScrollToSelection();
		}
		
		//Mouse input
		public function RandomAnimationButtonSelected(e:Event = null):void
		{
			
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
		
		public function GetAnimationIdTargetOfItem(itemIndex:int):int
		{
			//itemIndex parameter should be 0 - (MAX_ITEMS_DISPLAYED -1)
			
			if (itemIndex > -1 && itemIndex < animationList.items.length)
			{
				return animationList.items[itemIndex].frameTarget;
			}
			return -1;
		}
		
		public function SetAnimationList(idTargets:Vector.<int>, locks:Vector.<Boolean>):void
		{
			animationList.ResetList(idTargets, locks);
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
		
		private function GetYPosForButton():Number
		{
			var _retYPos:Number = buttonYPos;
			buttonYPos += AnimationButtonSize + 2;
			return _retYPos;
		}
		
		public function ChangeModeLabelToChange():void
		{
			modeLabel.text = "Keyboard Mode:\nChange";
		}
		
		public function ChangeModeLabelToLock():void
		{
			modeLabel.text = "Keyboard Mode:\nLock";
		}
		
		public function ChangeLockOnItem(index:int, lock:Boolean):void
		{
			animationList.items[index].locked = lock;
		}
	}

}