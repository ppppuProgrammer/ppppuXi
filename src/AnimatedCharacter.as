package  {
	import flash.display.FrameLabel;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.display.MovieClip;
	
	
	/*AnimatedCharacter is a class that is intended for use in interactive versions of ppppu. The intention is that this type of character
	 * holds a movie clip with all the various animations to be used.*/
	public class AnimatedCharacter 
	{
		protected var m_charAnimations:MovieClip = null; //The movie clip that contains all the animations of the character. Expects the first frame to be used for a placement marker shape, every other frame is to be an animation. 
		//private var m_ColorTransform:ColorTransform = null;
		//Background
		protected var m_topLeftDiamondColor:ColorTransform = null;
		protected var m_centerDiamondColor:ColorTransform = null; //For the top right and bottom left sections of the diamond
		protected var m_bottomRightDiamondColor:ColorTransform = null;
		protected var m_backgroundColor:ColorTransform = null;
		protected var m_backlightColor:ColorTransform = null;
		//Music
		//protected var m_musicClassName:String = null; 
		//The name of the music to play for the character.
		protected var m_defaultMusicName:String= "Beep Block Skyway";
		//protected var m_musicTitle:String = "Beep Block Skyway";
		//protected var m_musicStartPoint:Number = 0;
		//protected var m_musicLoopStartPoint:Number = m_musicStartPoint;
		//protected var m_musicLoopEndPoint:Number= -1;
		//Animation
		private var m_playAnimationFrame:int = 0;
		private var m_randomizePlayAnim:Boolean = true;
		private var m_lockedAnimation:Vector.<Boolean>; //Keeps track if an animation can be switched to.
		//Menu button
		protected var m_menuButton:MenuButton = null;
		protected var m_name:String = null;
		
		//private var m_numOfLockedAnimations:int = 0;
		
		private var frameToTransitionToLinkedAnimation:int = -1;
		private var queuedLinkedAnimationNumber:int = -1;
		public function AnimatedCharacter()
		{
			//m_charAnimations.x = -227.3;
			//m_charAnimations.y = 214;
			m_topLeftDiamondColor = new ColorTransform();
			m_centerDiamondColor = new ColorTransform();
			m_bottomRightDiamondColor = new ColorTransform();
			m_backgroundColor = new ColorTransform();
			m_backlightColor = new ColorTransform();
			/*m_CharMC = charMC;
			m_InDiamondMC = inDiamondMC;
			m_ColorTransform = characterColorTransform;
			m_OutDiamondMC = outDiamondMC;
			m_TransitionDiamondMC = transitionDiamondMC;
			m_defOutDiaMC = defOutDiaMC;
			m_defInDiaMC = defInDiaMC;
			m_defTransDiaMC = defTransDiaMC;
			m_BacklightColorTransform = BacklightColorTransform;
			m_useBacklight = useLight;*/
		}
		/*Checks if a clip has the needed data to be usable. Needed movie clips are: charMC(the one with 9+ animations)
		and the color transform to be applied to the various diamond movie clips. The actual diamond movie clips are not
		required as the default one (peach/rosalina) will be used and have the color transform applied to it.*/
		public function HasNecessaryData():Boolean
		{
			if(m_charAnimations && m_charAnimations.totalFrames > 1 && m_name != null && m_menuButton != null)
			{
				m_lockedAnimation = new Vector.<Boolean>(GetNumberOfAnimations());
				return true;
			}
			else
			{
				return false;
			}
		}
		public function GetCharacterAnimations():MovieClip
		{
			return m_charAnimations;
		}
		
		/*Function that should only be called by the animated character mod base class. This stops all movieclips contained
		 * in m_charAnimations, preventing performance issues due to all the animations playing by default when a new MovieClip is created.
		*/
		public function InitializeAfterLoad():void
		{
			m_charAnimations.stopAllMovieClips();
		}
		
		public function GetName():String
		{
			return m_name;
		}
		public function GetButton():MenuButton
		{
			return m_menuButton;
		}
		public function GetDefaultMusicName():String
		{
			return m_defaultMusicName;
		}
		/*public function GetMusicStartPoint():Number
		{
			return m_musicStartPoint;
		}
		public function GetMusicLoopStartPoint():Number
		{
			return m_musicLoopStartPoint;
		}
		public function GetMusicLoopEndPoint():Number
		{
			return m_musicLoopEndPoint;
		}
		public function GetMusicClassName():String
		{
			return m_musicClassName;
		}*/
		public function GetTLDiamondColor():ColorTransform
		{
			return m_topLeftDiamondColor;
		}
		public function GetCenterDiamondColor():ColorTransform
		{
			return m_centerDiamondColor; //For the top right and bottom left sections of the diamond
		}
		public function GetBRDiamondColor():ColorTransform
		{
			return m_bottomRightDiamondColor;
		}
		public function GetBackgroundColor():ColorTransform
		{
			return m_backgroundColor;
		}
		public function GetBacklightColor():ColorTransform
		{
			return m_backlightColor;
		}
		public function RandomizePlayAnim():void
		{
			//15 frame movie clip has 14 actual animations
			//array[0-13]
			// movieclip frame setting: 2 - 15
			if(m_randomizePlayAnim)
			{
				//generates a number from 0 to (totalFrames - 1)
				var randomAnimIndex:int = Math.floor(Math.random() * GetNumberOfAnimations() + 1);
				if((GetNumberOfAnimations() - GetNumberOfLockedAnimations()) > 2)
				{
					//To clarify this, indexes start from 0 and frames start from 1. So to convert frames->index, subtract 1 from the frame number.
					//To convert index->frame, add 1 to the index number.
					while(randomAnimIndex == m_playAnimationFrame-1 || GetAnimationLockedStatus(randomAnimIndex))
					{
						randomAnimIndex = Math.floor(Math.random() * GetNumberOfAnimations() + 1);
					}
				}
				else
				{
					while(GetAnimationLockedStatus(randomAnimIndex))
					{
						randomAnimIndex = Math.floor(Math.random() * GetNumberOfAnimations() + 1);
					}
				}
				SetPlayAnimation(randomAnimIndex);
			}
		}
		
		/*public function RemoveClipsFromParent(backlightMC:MovieClip)
		{
			if(m_charAnimations != null && m_charAnimations.parent != null)
			{
				m_charAnimations.stop();
				(m_charAnimations.getChildAt(0) as MovieClip).stop();
				m_charAnimations.parent.removeChild(m_charAnimations);
			}
			
			if(m_OutDiamondMC != null && m_OutDiamondMC.parent != null)
			{
				m_OutDiamondMC.stop();
				m_OutDiamondMC.parent.removeChild(m_OutDiamondMC);
			}
			
			if(backlightMC != null && backlightMC.parent != null)
			{
				backlightMC.stop();
				backlightMC.parent.removeChild(backlightMC);
			}
			
			//For the split diamond (transition) graphic
			if(m_TransitionDiamondMC != null && m_TransitionDiamondMC.parent != null)
			{
				m_TransitionDiamondMC.stop();
				m_TransitionDiamondMC.parent.removeChild(m_TransitionDiamondMC);
			}
			
			//For inner diamonds
			if(m_InDiamondMC != null && m_InDiamondMC.parent != null)
			{
				m_InDiamondMC.stop();
				m_InDiamondMC.parent.removeChild(m_InDiamondMC);
			}
		}*/
		//Used when there is no character or related movie clips on the stage. To be used when switching to a different character
		/*public function AddCharacterClipsToAnotherMovieClip(parentMC:MovieClip, backlightMC:MovieClip)
		{
			var clipFrameNum:int = ((parentMC.currentFrame - 7) % 120) + 1;
			//Add the inner diamonds pattern first
			if(m_InDiamondMC)
			{
				if(m_defInDiaMC)
				{
					m_InDiamondMC.transform.colorTransform = m_ColorTransform;
				}
				parentMC.addChild(m_InDiamondMC);
				m_InDiamondMC.gotoAndPlay(clipFrameNum);
			}
			//Then add transitional diamond pattern
			if(m_TransitionDiamondMC)
			{
				if(m_defTransDiaMC)
				{
					m_TransitionDiamondMC.transform.colorTransform = m_ColorTransform;
				}
				parentMC.addChild(m_TransitionDiamondMC);
				m_TransitionDiamondMC.gotoAndPlay(clipFrameNum);
			}
			//Add the backlight
			if(backlightMC && m_useBacklight)
			{
				parentMC.addChild(backlightMC);
				backlightMC.gotoAndPlay(clipFrameNum);
				backlightMC.transform.colorTransform = m_BacklightColorTransform;
			}
			//Add the outer diamond pattern
			if(m_OutDiamondMC)
			{
				if(m_defOutDiaMC)
				{
					m_OutDiamondMC.transform.colorTransform = m_ColorTransform;
				}
				parentMC.addChild(m_OutDiamondMC);
				m_OutDiamondMC.gotoAndPlay(clipFrameNum);
			}
			
			//Finally add the character
			if(m_charAnimations == null)
			{
				throw new Error("Error: Character Movie clip was found to be null.");
			}
			parentMC.addChild(m_charAnimations);
			RandomizePlayAnim();
			PlayingLockedAnimCheck();
			PlayAnimation();
		}*/
		public function PlayAnimation(animationFrame:int):void
		{
			//select the animation to play
			m_charAnimations.gotoAndStop(m_playAnimationFrame);
			//and set this animation's frame number to reflect where it would be if animations weren't changed on a whim
			var animationMC:MovieClip = m_charAnimations.getChildAt(0) as MovieClip;
			//var parentMC:MovieClip = m_charAnimations.parent as MovieClip;
			if(animationMC)
			{
				animationMC.gotoAndPlay(animationFrame);
			}
		}
		
		public function SetPlayAnimation(animNumber:int):void
		{
			if(animNumber < 1)
			{
				animNumber = 1;
			}
			else if(animNumber > GetNumberOfAnimations())
			{
				animNumber = GetNumberOfAnimations();
			}
			m_playAnimationFrame = animNumber + 1;
		}
		
		public function SetRandomizeAnimation(randomStatus:Boolean):void
		{
			m_randomizePlayAnim = randomStatus;
		}
		public function GetRandomAnimStatus() : Boolean
		{
			return m_randomizePlayAnim;
		}
		public function ToggleRandomizeAnimation():void
		{
			m_randomizePlayAnim = !m_randomizePlayAnim;
		}
		public function GetAnimationLockedStatus(animIndex:int):Boolean
		{
			//have to convert animindex(starts from 1) into an array index (starts at 0)
			return m_lockedAnimation[int(animIndex-1)];
		}
		public function SetAnimationLockedStatus(animIndex:int, lockStatus:Boolean):void
		{
			if(animIndex < 1 || animIndex > GetNumberOfAnimations())
			{
				return;
			}
			m_lockedAnimation[int(animIndex-1)] = lockStatus;
		}
		public function GetNumberOfAnimations():int
		{
			return m_charAnimations.totalFrames - 1;
		}
		/*public function GetAnimationCurrentFrame():int
		{
			return (m_CharMC.getChildAt(0) as MovieClip).currentFrame;
		}*/
		public function GetNumberOfLockedAnimations():int
		{
			var lockedAnimNum:int = 0;
			for(var i:int = 0, l:int = m_lockedAnimation.length; i < l; ++i)
			{
				if(m_lockedAnimation[i])
				{
					++lockedAnimNum;
				}
			}
			return lockedAnimNum;
		}
		public function PlayingLockedAnimCheck():void
		{
			//Only 1 animation is available, so search for it and use it.
			if(GetAnimationLockedStatus(m_playAnimationFrame-1) && (GetNumberOfAnimations() - GetNumberOfLockedAnimations() == 1))
			{
				var unlockedAnimNum:int = 1;
				for each(var locked:Boolean in m_lockedAnimation)
				{
					if(!locked)
					{
						break;
					}
					++unlockedAnimNum;
				}
				SetPlayAnimation(unlockedAnimNum);
			}
		}
		
		protected function CreateColorTransformFromHex(colorValue:uint, alpha:uint = 255):ColorTransform
		{
			
			var ct:ColorTransform = new ColorTransform();
			ct.color = colorValue;
			if (alpha != 255)
			{
				if (alpha > 255) { alpha = 255; }
				ct.alphaMultiplier = 0;
				ct.alphaOffset = alpha;
			}
			return ct;
		}
		
		public function StopAnimation():void
		{
			if (m_charAnimations)
			{
				if (m_charAnimations.isPlaying)
				{
					m_charAnimations.stop();
				}
				(m_charAnimations.getChildAt(0) as MovieClip).stop();
			}
		}
		
		public function CheckAndSetupLinkedTransition():Boolean
		{
			var linkedAnimationNumber:int = -1;
			var currLabel:String = m_charAnimations.currentFrameLabel;
			if (currLabel == null || currLabel.indexOf("Into_") == -1) 
			{ 
				return false;
			}
			
			var labelSearchingFor:String = currLabel.replace("Into_", "");
			var labelsArray:Array = m_charAnimations.currentLabels;
			for (var x:int = 0, y:int = labelsArray.length; x < y; ++x )
			{
				var label:FrameLabel = labelsArray[x] as FrameLabel;
				if (label.name == labelSearchingFor)
				{
					linkedAnimationNumber = label.frame;
					break;
				}
			}
			if (linkedAnimationNumber == -1) { return false; }
		
			//Now to check the linked animation to do things
			var currentAnimation:MovieClip = (m_charAnimations.getChildAt(0) as MovieClip);
			var frameLabels:Array = currentAnimation.currentLabels;
			var startFrame:int = -1, endFrame:int = -1;
			for (var i:int = 0, l:int = frameLabels.length; i < l; ++i )
			{
				var animationLabel:FrameLabel = frameLabels[i] as FrameLabel;
				if (animationLabel.name == "ActivateStart")
				{
					startFrame = animationLabel.frame;
				}
				else if (animationLabel.name == "ActivateEnd")
				{
					endFrame = animationLabel.frame;
				}
			}
			if (endFrame > -1)
			{
				if (startFrame > -1)
				{
					if (currentAnimation.currentFrame >= startFrame && currentAnimation.currentFrame <= endFrame)
					{
						frameToTransitionToLinkedAnimation = endFrame;
						queuedLinkedAnimationNumber = linkedAnimationNumber;
						currentAnimation.addEventListener(Event.ENTER_FRAME, TryChangingToQueuedAnimation);
						return true;
					}
				}
				else
				{
					if (currentAnimation.currentFrame <= endFrame)
					{
						frameToTransitionToLinkedAnimation = endFrame;
						queuedLinkedAnimationNumber = linkedAnimationNumber;
						currentAnimation.addEventListener(Event.ENTER_FRAME, TryChangingToQueuedAnimation);
						return true;
					}
				}
			}
			return false;
		}
		
		private function TryChangingToQueuedAnimation(e:Event):void
		{
			if (e.target.currentFrame == this.frameToTransitionToLinkedAnimation)
			{
				this.SetPlayAnimation(queuedLinkedAnimationNumber);
				this.PlayAnimation(1);
				frameToTransitionToLinkedAnimation = -1;
				queuedLinkedAnimationNumber = -1;
				e.target.removeEventListener(Event.ENTER_FRAME, TryChangingToQueuedAnimation);
			}
			//Makes sure that if somehow it misses the transition to abort and remove the event listener.
			if (e.target.currentFrame == e.target.totalFrames)
			{
				frameToTransitionToLinkedAnimation = -1;
				queuedLinkedAnimationNumber = -1;
				e.target.removeEventListener(Event.ENTER_FRAME, TryChangingToQueuedAnimation);
			}
		}
		/*public function GetParentMovieClip():MovieClip
		{
			var parentMC:MovieClip = m_CharMC.parent as MovieClip;
			return parentMC;
		}*/
	}
}
