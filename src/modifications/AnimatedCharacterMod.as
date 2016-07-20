package modifications 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	/**
	 * Character mod intended for use in interactive versions of ppppu. A movie clip containing all the animations that will be shown
	 * is expected. In order to add more animations for the character, the flash document for the character must be modified.
	 * @author 
	 */
	public class AnimatedCharacterMod extends Mod
	{
		//The character instance that will be extracted from the mod and added into the character manager.
		//protected var characterPayload:AnimatedCharacter;
		//A movie clip containing 1 or more frames, each frame being a movie clip that holds an animation sequence.
		protected var initialAnimationContainer:MovieClip = null;
		
		protected var m_topLeftDiamondColor:ColorTransform = CreateColorTransformFromHex(0xFFE1E3);
		protected var m_centerDiamondColor:ColorTransform = CreateColorTransformFromHex(0xFEC2C7); //For the top right and bottom left sections of the diamond
		protected var m_bottomRightDiamondColor:ColorTransform = CreateColorTransformFromHex(0xFD9FA7);
		protected var m_outerDiamondColor:ColorTransform = CreateColorTransformFromHex(0xFC7883);
		protected var m_backlightColor:ColorTransform = CreateColorTransformFromHex(0xFFD200);
		
		protected var m_menuIcon:Sprite;
		protected var m_preferredMusicName:String = "Beep Block Skyway";
		protected var m_characterName:String;
		
		
		
		public function AnimatedCharacterMod() 
		{
			modType = Mod.MOD_ANIMATEDCHARACTER;
		}
		override protected function FirstFrame(e:Event):void
		{
			super.FirstFrame(e);
			if (initialAnimationContainer != null)
			{
				initialAnimationContainer.stop();
				//A movie clip containing 1 children is one that typically has movie clips contained in each frame and that initialAnimationContainer is not an animation itself.
				//If there are more children then it's likely that the initialAnimationContainer itself is  an animation and is the only one.
				//if (initialAnimationContainer.numChildren == 1)	{ characterPayload.AddAnimationsFromMovieClip(initialAnimationContainer); }
				//else { characterPayload.AddAnimation(initialAnimationContainer);}
				//characterPayload.SetBackgroundColorsToDefault();
				//characterPayload.InitializeAfterLoad();
			}
		}
		
		public function GetCharacterData():Object
		{
			var data:Object = {
			tlColor: m_topLeftDiamondColor,
			cenColor: m_centerDiamondColor,
			brColor: m_bottomRightDiamondColor,
			outColor: m_outerDiamondColor,
			lightColor: m_backlightColor,
			icon: m_menuIcon,
			perferredMusic: m_preferredMusicName,
			name: m_characterName,
			animation: initialAnimationContainer};
			return data;
		}
		
		public override function Dispose():void
		{
			if (initialAnimationContainer != null)
			{
				initialAnimationContainer.stopAllMovieClips();
				initialAnimationContainer.removeChildren();
				if (initialAnimationContainer.parent != null)
				{
					initialAnimationContainer.parent.removeChild(initialAnimationContainer);
				}
				initialAnimationContainer = null;
			}
			
			
			m_topLeftDiamondColor = null;
			m_centerDiamondColor = null;
			m_bottomRightDiamondColor = null;
			m_outerDiamondColor = null;
			m_backlightColor = null;
			
			m_menuIcon = null;
			m_preferredMusicName = null;
			m_characterName = null;
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
	}

}