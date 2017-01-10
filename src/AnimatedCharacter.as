package 
{
	import events.AnimationTransitionEvent;
	import events.FadeToBlackTransitionEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import mx.logging.*;
	import flash.events.UncaughtErrorEvent;
	/**
	 * ...
	 * @author 
	 */
	public class AnimatedCharacter 
	{
		//The name of the character
		protected var m_name:String = null;
		
		/*The vector that contains all animation movieclips for the character. Also referred to as the animation collection*/
		protected var m_charAnimations:Vector.<MovieClip> = new Vector.<MovieClip>();
		//animation labels are used to tell which animations are linked.
		protected var m_animationLabel:Vector.<String> = new Vector.<String>();
		
		private var m_currentlyPlayingAnimation:MovieClip = null;
		/*The id of the characters animation collection that is slated to play or is playing currently. -1 indicates nothing is playing.
		 * Value corresponds to the index of the character animations vector*/
		private var m_currentAnimationIndex:int = -1;
		
		private var m_animationNames:Dictionary = new Dictionary();
		
		/*Background colors*/
		//The current colors of the background elements for the character
		protected var m_backgroundColors:Object;
		//The original colors set for the character
		protected var m_topLeftDiamondColor:ColorTransform = new ColorTransform();
		protected var m_centerDiamondColor:ColorTransform = new ColorTransform(); //For the top right and bottom left sections of the diamond
		protected var m_bottomRightDiamondColor:ColorTransform = new ColorTransform();
		protected var m_outerDiamondColor:ColorTransform = new ColorTransform();
		protected var m_backlightColor:ColorTransform = new ColorTransform();
		
		//The name of the music to play for the character.
		protected var m_preferredMusicName:String = "Beep Block Skyway";
		
		//private var m_playAnimationId:int = 0;
		//Indicates whether the animation to play is to be randomly chosen.
		private var m_randomizePlayAnim:Boolean = true;
		private var m_lockedAnimation:Vector.<Boolean> = new Vector.<Boolean>(); //Keeps track if an animation can be switched to.
		
		//Graphic used to represent the character on the menu
		protected var m_menuIcon:Sprite = null;
		
		/*Index targets is used to maintain a key-value pairing of the accessible animations id (starts from 0) to a specific index
		 * of charAnimations that contains an animation. This is done as certain animations may not be intended to be accessible 
		 * by normal means.*/
		private var m_idTargets:Vector.<int> = new Vector.<int>();
		
		private var m_transitionActivationPoints:Vector.<int> = new Vector.<int>(2);
		
		//The frame in the current animation to switch to the linked animation. 
		private var frameToTransitionToLinkedAnimation:int = -1;
		/*The index of the animation in the character animations vector that will be switched to when the current animation reaches
		* the frame denoted in the above variable (frameToTransitionToLinkedAnimation)*/
		private var queuedLinkedAnimationIndex:int = -1;
		/*Indicates if the character is still in their linked animation, which are able to be set to loop a section endlessly until the 
		 * character or animation is switched by the user.*/
		private var isInLinkedAnimation:Boolean = false;
		
		private var displayArea:Sprite = new Sprite();
		
		//The logging object for this class
		private var logger:ILogger;
		
		//The frame that the fade to black transition should be started on.
		protected var fadeToBlackFrame:int = -1;
		
		//Keeps track of all animations that were indicated to be a nested animation (an animation that contains multiple children movieclips, each of which are 120 frame animations)
		protected var nestedAnimationsIdList:Vector.<int> = new Vector.<int>();
		
		
		private static const animationAddFailedMessage:String = "Failed to add animations:";
		
		public function AnimatedCharacter(characterData:Object=null) 
		{
			if (characterData == null) { return; }

			m_topLeftDiamondColor = characterData.tlColor;
			m_centerDiamondColor = characterData.cenColor;
			m_bottomRightDiamondColor = characterData.brColor
			m_outerDiamondColor = characterData.outColor;
			m_backlightColor = characterData.lightColor;
			
			SetBackgroundColorsToDefault();
			m_menuIcon = characterData.icon;
			m_preferredMusicName = characterData.perferredMusic;
			m_name = characterData.name;
			
			//Create the logger object that's used by this class to output messages.
			//Need to remove all invalid characters from the name or the logger will throw an error
			var nameSanitizerForLogger:RegExp = /[\s\r\n\[\]~$^&\/(){}<>+=`!#%?,:;'"@]+/gim;
			logger = Log.getLogger("AnimatedCharacter_" + m_name.replace(nameSanitizerForLogger,''));
			
			var animation:MovieClip = characterData.animation;
			if (animation != null)
			{
				if ( animation.numChildren > 1)
				{
					AddAnimation(animation);
				}
				else if(animation.numChildren == 1)
				{
					AddAnimationsFromMovieClip(animation);
				}
				animation.stopAllMovieClips();
				animation = null;
			}

		}
		
		//Resets the background colors object to the default values set for the character.
		public function SetBackgroundColorsToDefault():void
		{
			m_backgroundColors = { inDiaTL:m_topLeftDiamondColor, inDiaCen:m_centerDiamondColor, inDiaBR:m_bottomRightDiamondColor, 
				outDia: m_outerDiamondColor,light:m_backlightColor };
		}
		
		//Returns an object containing the current colors to use for background elements.
		public function GetBackgroundColors():Object
		{
			return m_backgroundColors;
		}
		
		public function IsValidCharacter():Boolean	{return (m_name != null && m_menuIcon != null && m_charAnimations.length > 0);}
		
		public function GetName():String	{return m_name;}
		public function GetIcon():Sprite	{ return m_menuIcon; }
		
		public function GetPreferredMusicName():String	{return m_preferredMusicName;}
		
		public function UpdateBackgroundColors():void
		{
			
		}
		
		private function UpdateIdTargets():void
		{
			m_idTargets = new Vector.<int>();
			var inaccessibleIndices:Vector.<int> = new Vector.<int>();
			var label:String;
			for (var x:int = 0; x < m_animationLabel.length; ++x)
			{
				label = m_animationLabel[x] as String;
				//"Into_" must be found in the name at the first position of the string (0) for the labeled animation to be 
				//accessible via normal means.
				if (label != null && label.length > 0 && label.indexOf("Into_") != 0)
				{
					inaccessibleIndices[inaccessibleIndices.length] = x;
				}
			}
			for (var i:int = 0; i < m_charAnimations.length; ++i)
			{
				if (inaccessibleIndices.indexOf(i) == -1)
				{
					m_idTargets[m_idTargets.length] = i;
				}
			}
		}
		
		/*Adds multiple animations from a single multi framed movieclip, in which each of those frames containing an animation.
		Because of how "attached" movie clips are when exported from Flash CS, there needs to be some work done
		to get the animations seperated. Every animation in a frame of the animation Collection must have AS linkage.
		This is so we can get the constructor for the animation, create a new instance and save that into the animations vector.*/
		public function AddAnimationsFromMovieClip(animationCollection:MovieClip):void
		{
			var failMessage:String = animationAddFailedMessage;
			for (var i:int = 1; i <= animationCollection.totalFrames; ++i)
			{
				animationCollection.gotoAndStop(i);
				//Stop the movie clip in the collection from playing, which can cause sounds embed into them
				//to play for a few milliseconds during this.
				if (animationCollection.numChildren > 0 && animationCollection.getChildAt(0) as MovieClip != null)
				{
					(animationCollection.getChildAt(0) as MovieClip).stop();
					var animationIndex:int = m_charAnimations.length;
					
					var label:String = animationCollection.currentFrameLabel;
					var isLinkedEndAnimation:Boolean = false;
					if (label && label.indexOf("Into_") != 0)
					{
						isLinkedEndAnimation = true;
					}
					//Animation labels are not allowed to overwrite each other
					if (label && m_animationLabel.indexOf(label) != -1)
					{
						label = null;
					}
					var animationClass:Class = Object(animationCollection.getChildAt(0)).constructor;
					var animationName:String = getQualifiedClassName(animationClass);
					var animation:DisplayObject = new animationClass();
					if (animation && (animation as MovieClip).totalFrames > 1 && !(animationName in m_animationNames))
					{
						animation.name = animationCollection.getChildAt(0).name;
						//trace(animation.name);
						(animation as MovieClip).stop();
						if (isLinkedEndAnimation == false)
						{
							//add animation
							m_charAnimations[animationIndex] = animation/*animationCollection.getChildAt(0)*/ as MovieClip;
							m_animationLabel[animationIndex] = label; //add label
							m_lockedAnimation[m_lockedAnimation.length] = false;
							m_animationNames[animationName] = animationIndex;
						}
						else if (isLinkedEndAnimation == true && label != null)
						{
							m_charAnimations[animationIndex] = animation/*animationCollection.getChildAt(0)*/ as MovieClip;
							m_animationLabel[animationIndex] = label; //add label
							//No need to worry about the animation's lock since linked end animations are unaccessible by normal means anyway.
						}	
						else
						{
							failMessage += " " + animationName + "(endlink missing label)";
						}
						
						//If animation was added then do a check to see if it's intended to be a nested animation
						if (m_charAnimations.indexOf(animation) != -1 && animation.name.charAt(0) == "$")
						{
							try
							{
								//Try to stop all the children in the animation. If this fails, then the nested animation is either a regular animation or was not set up properly.
								for (var x:int = 0, y:int = (animation as MovieClip).numChildren; x < y; ++x)
								{
									((animation as MovieClip).getChildAt(x) as MovieClip).stop();
								}
								nestedAnimationsIdList[nestedAnimationsIdList.length] = animationIndex;
							}
							catch (e:Error)
							{
								//Catch the error and log it. Also the animation will now be considered a regular animation, not a nested one.
								logger.error("Error while trying to play animation {0}, which is not a proper nested animation. In your flash authoring program, either remove the \"$\" from  {0}'s name ({1}) within the animation container to indicate that it's a regular animation or correct the mistakes of the nested animation.\nError Information: " + "\n" + e.getStackTrace(), getQualifiedClassName(animation), animation.name);
							}
						}
						//m_charAnimations[animationIndex].stop();
					}
					else
					{
						failMessage += " " + animationName+"(Wasn't valid movieclip or animation with same name was already added)";
					}
					//animationCollection.removeChild(m_charAnimations[animationIndex]);
				}
			}
			if (failMessage != animationAddFailedMessage)
			{
				logger.warn(failMessage);
			}
			//Allow the movie clip to be garbage collected
			animationCollection.removeChildren();
			animationCollection = null;
			UpdateIdTargets();
		}
		
		//Adds a movieclip to the character's animation vector. An animation added this way can not be linked to another.
		public function AddAnimation(initialAnimation:MovieClip):void
		{
			initialAnimation.stop();
			var animationIndex:int = m_charAnimations.length;
			
			var animationClass:Class = Object(initialAnimation).constructor;
			var animationName:String = getQualifiedClassName(animationClass);
			var animation:MovieClip = new animationClass();
			if (animation && (animation as MovieClip).totalFrames > 1 && !(animationName in m_animationNames)) 
			{
				animation.name = initialAnimation.name;
				(animation as MovieClip).stop();
				//add animation
				m_charAnimations[animationIndex] = animation as MovieClip;
				m_animationLabel[animationIndex] = null; //add label
				m_lockedAnimation[m_lockedAnimation.length] = false;
				m_animationNames[animationName] = animationIndex;
				if (animation.name.charAt(0) == "$")
				{	
					try
					{
						//Try to stop all the children in the animation. If this fails, then the nested animation is either a regular animation or was not set up properly.
						for (var i:int = 0, l:int = animation.numChildren; i < l; ++i)
						{
							(animation.getChildAt(i) as MovieClip).stop();
						}
						nestedAnimationsIdList[nestedAnimationsIdList.length] = animationIndex;
					}
					catch (e:Error)
					{
						//Catch the error and log it. Also the animation will now be considered a regular animation, not a nested one.
						logger.error("Error while trying to play animation {0}, which is not a proper nested animation. In your flash authoring program, either remove the \"$\" from  {0}'s name ({1}) within the animation container to indicate that it's a regular animation or correct the mistakes of the nested animation.\nError Information: " + "\n" + e.getStackTrace(), getQualifiedClassName(animation), animation.name);
					}
				}
			}
			else
			{
				logger.warn("Couldn't add animation: " + animationName+"(Wasn't valid movieclip or animation with same name was already added");
			}
			//Allow the original movie clip to be garbage collected
			initialAnimation = null;
			UpdateIdTargets();
		}
		
		[inline]
		public function StopAnimation():void
		{
			if (m_currentlyPlayingAnimation)
			{
				if (m_currentlyPlayingAnimation.isPlaying)
				{
					m_currentlyPlayingAnimation.stop();
				}
			}
		}
		
		public function GetCurrentAnimationId():int
		{
			return m_currentAnimationIndex;
		}
		
		public function SetRandomizeAnimation(randomStatus:Boolean):void
		{
			m_randomizePlayAnim = randomStatus;
		}
		public function GetRandomAnimStatus() : Boolean
		{
			return m_randomizePlayAnim;
		}
		
		/*public function OnAccessibleAnimationCheck():void
		{
			//Check that animation index has an accessible animation id associated with it.
			if (GetIdTargetForIndex(m_currentAnimationIndex) == -1)
			{
				//Animation index didn't have an associated accessible id.
				m_currentAnimationIndex = -1;
			}
		}*/
		
		//Returns the animation id that was selected
		public function RandomizePlayAnim(forceRandomization:Boolean=false):void
		{
			if(m_randomizePlayAnim || forceRandomization == true)
			{
				//Randomly select a number out of the number of accessible animations
				var accessibleAnimationCount:int = GetNumberOfAccessibleAnimations();
				var randomAnimIndex:int = Math.floor(Math.random() * accessibleAnimationCount);
				
				if((accessibleAnimationCount - GetNumberOfLockedAnimations()) > 2)
				{
					while(randomAnimIndex == m_currentAnimationIndex || GetAnimationLockedStatus(randomAnimIndex))
					{
						randomAnimIndex = Math.floor(Math.random() * accessibleAnimationCount);
					}
				}
				else
				{
					while(GetAnimationLockedStatus(randomAnimIndex))
					{
						randomAnimIndex = Math.floor(Math.random() * accessibleAnimationCount);
					}
				}
				m_currentAnimationIndex = m_idTargets[randomAnimIndex];
				
				//ChangeAnimationIndexToPlay(randomAnimIndex);
			}
		}
		
		public function SetLockOnAnimation(animId:int, lockValue:Boolean):void
		{
			var indexForId:int = m_idTargets.indexOf(animId);
			logger.debug("Trying to set lock on animation {0} (id {1}) to {2}",GetNameOfAnimationById(animId),  animId, lockValue);
			/*Conditions that will not have a set locked:
			 * 1) index for id [id target] is -1 (animation id did not belong to an accessible animation). 
			 * 2) if lockValue is true: setting the lock on the given animation will lead to all animations being locked.*/
			if( indexForId == -1 || (lockValue == true && GetNumberOfLockedAnimations() + 1 >= GetNumberOfAccessibleAnimations()) )
			{
				logger.debug("Could not change lock on animation {0} (id {1})", GetNameOfAnimationById(animId),  animId);
				return;
			}
			m_lockedAnimation[indexForId] = lockValue;
		}
		
		public function GetTotalNumberOfAnimations():int
		{
			return m_charAnimations.length;
		}
		
		/*"accessible" animations are animations that are not end linked animations (meaning, they must be manually activated by the user
		 * with a special command)*/
		[inline]
		public function GetNumberOfAccessibleAnimations():int
		{
			return m_idTargets.length;
		}
		
		[inline]
		public function GetNumberOfLockedAnimations():int
		{
			var lockedAnimNum:int = 0;
			for(var i:int = 0, l:int = m_lockedAnimation.length; i < l; ++i)
			{
				if(m_lockedAnimation[i] == true)
				{
					++lockedAnimNum;
				}
			}
			return lockedAnimNum;
		}
		
		public function PlayingLockedAnimCheck():void
		{
			//Make sure the currently playing animation can be locked.
			//animation id are already the accessible animations.
			var accessibleId:int = GetIdTargetForIndex(m_currentAnimationIndex);
			//id returned was -1, meaning the animation at the index was not accessible.
			//if (accessibleId == -1) { return;}
			if(GetAnimationLockedStatus(accessibleId) && (GetNumberOfAccessibleAnimations() - GetNumberOfLockedAnimations() == 1))
			{
				var unlockedAnimNum:int = 0;
				for each(var locked:Boolean in m_lockedAnimation)
				{
					if(!locked)
					{
						break;
					}
					++unlockedAnimNum;
				}
				m_currentAnimationIndex = m_idTargets[unlockedAnimNum];
				//ChangeAnimationIndexToPlay(unlockedAnimNum);
			}
		}
		
		//Checks if there are any transition points for the current animation and sets the transition points vector which is used to let any classes that need that information.
		public function CheckCurrentAnimationForTransitionLinks():void
		{
			
		
			//Now to check the linked animation to do things
			var currentAnimation:MovieClip = m_currentlyPlayingAnimation;
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
			if (startFrame == -1 && endFrame > 0)
			{
				startFrame = 1;
			}
			if (endFrame > currentAnimation.totalFrames)
			{
				endFrame = currentAnimation.totalFrames;
			}
			m_transitionActivationPoints[1] = endFrame;
			m_transitionActivationPoints[0] = startFrame;
		}
		public function GetTransitionActivationPoints():Vector.<int>
		{
			return m_transitionActivationPoints;
		}
		public function SetupLinkedTransition():Boolean
		{
			var linkedAnimationIndex:int = -1;
			var currLabel:String = m_animationLabel[m_currentAnimationIndex];// m_charAnimations.currentFrameLabel;
			if (currLabel == null || currLabel.indexOf("Into_") == -1) 
			{ 
				return false;
			}
			
			var labelSearchingFor:String = currLabel.replace("Into_", "");
			var labels:Vector.<String> = m_animationLabel;
			for (var x:int = 0, y:int = labels.length; x < y; ++x )
			{
				var label:String = labels[x] as String;
				if (label != null && label == labelSearchingFor)
				{
					linkedAnimationIndex = x;
					break;
				}
			}
			if (linkedAnimationIndex == -1) { return false; }
			
			var currentAnimationFrame:int = m_currentlyPlayingAnimation.currentFrame;
			if(m_transitionActivationPoints[1] > 0)
			{
				if (m_transitionActivationPoints[0] > 0)
				{
					if (currentAnimationFrame >= m_transitionActivationPoints[0] && currentAnimationFrame <= m_transitionActivationPoints[1])
					{
						frameToTransitionToLinkedAnimation = m_transitionActivationPoints[1];
						queuedLinkedAnimationIndex = linkedAnimationIndex;
						m_currentlyPlayingAnimation.addEventListener(Event.ENTER_FRAME, TryChangingToQueuedAnimation);
						return true;
					}
				}
				else
				{
					if (currentAnimationFrame <= m_transitionActivationPoints[1])
					{
						frameToTransitionToLinkedAnimation = m_transitionActivationPoints[1];
						queuedLinkedAnimationIndex = linkedAnimationIndex;
						m_currentlyPlayingAnimation.addEventListener(Event.ENTER_FRAME, TryChangingToQueuedAnimation);
						return true;
					}
				}
			}
			return false;
		}
		
		public function RemoveFromDisplay():void
		{
			displayArea.removeChildren();
			if (displayArea.parent != null)	{displayArea.parent.removeChild(displayArea);}
		}
		
		private function TryChangingToQueuedAnimation(e:Event):void
		{
			if (e.target.currentFrame == this.frameToTransitionToLinkedAnimation)
			{
				this.ChangeAnimationIndexToPlay(queuedLinkedAnimationIndex);
				this.GotoFrameAndPlayForCurrentAnimation(1);
				//animation has changed, so now to attach a frame script to it to activate the fade to black transition.
				//First check if the animation has a "FadeToBlack" label. End link animations can use this to specify a frame to start the fade to black transition
				if (this.m_currentlyPlayingAnimation.currentLabels.length > 0)
				{
					fadeToBlackFrame = this.m_currentlyPlayingAnimation.currentLabels.indexOf("FadeToBlack");
				}
				//if the label wasn't found then the amount of frames that the transition lasts is subtracted from the total frame count of the animation. The result of that subtraction is the fadeToBlackFrame.
				if (fadeToBlackFrame == -1)
				{
					fadeToBlackFrame = this.m_currentlyPlayingAnimation.totalFrames - AppCore.GetFadeToBlackTransitionDuration();
				}
				//Last check, make sure that fadeToBlackFrame is not less than 1, which could happen if an animation duration is shorter than the transition.
				if (fadeToBlackFrame < 1)
				{
					fadeToBlackFrame = 1;
				}
				
				//With the FtBFrame found, attach the frame script
				this.m_currentlyPlayingAnimation.addFrameScript(fadeToBlackFrame-1, RequestFadeToBlackTransition);
				
				frameToTransitionToLinkedAnimation = -1;
				queuedLinkedAnimationIndex = -1;
				e.target.removeEventListener(Event.ENTER_FRAME, TryChangingToQueuedAnimation);
				isInLinkedAnimation = true;
				displayArea.dispatchEvent(new Event(AnimationTransitionEvent.ANIMATION_TRANSITIONED));
			}
			//Makes sure that if somehow it misses the transition to abort and remove the event listener.
			if (e.target.currentFrame == e.target.totalFrames)
			{
				frameToTransitionToLinkedAnimation = -1;
				queuedLinkedAnimationIndex = -1;
				e.target.removeEventListener(Event.ENTER_FRAME, TryChangingToQueuedAnimation);
				//Even though the transition is unable to activate, this event needs to be dispatched so any listeners can remove any sort 
				//of locks put in place for animation transitions.
				displayArea.dispatchEvent(new Event(AnimationTransitionEvent.ANIMATION_TRANSITIONED));
				isInLinkedAnimation = false;
			}
		}
		
		public function GotoFrameAndPlayForCurrentAnimation(animationFrame:int):void
		{
			if (m_currentAnimationIndex < 0 || m_charAnimations.length == 0)	{ return; }
			
			//and set this animation's frame number to reflect where it would be if animations weren't changed on a whim
			var animation:MovieClip = m_charAnimations[m_currentAnimationIndex];
			if(animation)
			{
				//displayArea.addChild(animation);
				//animation.nextFrame();
				animation.gotoAndPlay(animationFrame);
				if (nestedAnimationsIdList.indexOf(m_currentAnimationIndex) != -1)
				{
					for (var i:int = 0, l:int = animation.numChildren; i < l; ++i)
					{
						(animation.getChildAt(i) as MovieClip).gotoAndPlay(animationFrame);
					}
				}
				//animation.play();
			}
			
			
		}
		
		public function AddToDisplay(parent:DisplayObjectContainer):void
		{
			parent.addChild(displayArea);
		}
		
		public function IsStillInLinkedAnimation():Boolean
		{
			return isInLinkedAnimation;
		}
		
		public function ChangeInLinkedAnimationStatus(value:Boolean):void
		{
			isInLinkedAnimation = value;
		}
		
		[inline]
		private function GetIdTargetForIndex(index:int):int
		{
			return m_idTargets.indexOf(index);
			
		}
		
		public function GetAnimationLockedStatus(animIndex:int):Boolean
		{
			var idTarget:int = GetIdTargetForIndex(animIndex);
			if (idTarget == -1) { return false; }
			else
				return m_lockedAnimation[idTarget];
		}
		
		public function GetAnimationLocks():Vector.<Boolean>
		{
			return m_lockedAnimation;
		}
		
		/* Chnages the id of the animation to play and adds the appropriate animation to the display area.
		* Parameter "animIndex" - the index of the character animations vector to pull the animation from and place on the display area.
		* Result: -1 doesn't change the current animation id. Values >= 0 get the animation from the animations vector.
		* */
		public function ChangeAnimationIndexToPlay(animIndex:int=-1):void
		{
			
			if (animIndex > -1)	{ m_currentAnimationIndex = animIndex /*+ 1*/; }
			
			/*If the animation index does not correspond to an actual animation, in a case such as 
			 * adding an extra animation for one playthrough then locking that extra animation then 
			 * removing it for the next playthrough, then it needs to be randomly selected*/
			if (m_currentAnimationIndex >= GetTotalNumberOfAnimations())
			{
				RandomizePlayAnim(true);
			}
			
			if (displayArea.numChildren == 1) 
			{ 
				var displayedAnimation:MovieClip = displayArea.getChildAt(0) as MovieClip;
				displayedAnimation.stop();
				displayArea.removeChildAt(0); 
				m_currentlyPlayingAnimation = null;
			}
			
			if (m_currentAnimationIndex > -1 && m_currentAnimationIndex < m_charAnimations.length && displayArea.numChildren == 0)
			{
				m_currentlyPlayingAnimation = m_charAnimations[m_currentAnimationIndex];
				displayArea.addChild(m_charAnimations[m_currentAnimationIndex]);
				CheckCurrentAnimationForTransitionLinks();
			}
		}
		
		public function GetAnimationIdTargets():Vector.<int>
		{
			return m_idTargets;
		}
		
		public function GetIdOfAnimationName(animationName:String):int
		{
			if (animationName in m_animationNames)
			{
				return m_animationNames[animationName];
			}
			else
			{
				//No id for found for the name
				return -1;
			}
		}
		
		public function GetNameOfAnimationById(animationId:int):String
		{
			for (var name:String in m_animationNames) 
			{
				if (m_animationNames[name] == animationId)
				{
					return name;
				}
			}
			return null;
		}
		
		private function RequestFadeToBlackTransition():void
		{
			displayArea.dispatchEvent(new Event(FadeToBlackTransitionEvent.FADETOBLACK_TRANSITION));
			//Remove the frame script that was responsible for having this function called.
			this.m_currentlyPlayingAnimation.addFrameScript(fadeToBlackFrame-1, null);
			//Reset the fade to black frame. 
			fadeToBlackFrame = -1;
		}
		
		/*protected function CreateColorTransformFromHex(colorValue:uint, alpha:uint = 255):ColorTransform
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
		}*/
		
		/*public function DEBUG_TraceCurrentFrame():void
		{
			trace("Character frame: " + m_currentlyPlayingAnimation.currentFrame);
		}*/
	}

}