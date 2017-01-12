package modifications 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.utils.getQualifiedClassName;
	/**
	 * Character mod intended for use in interactive versions of ppppu. A movie clip containing all the animations that will be shown
	 * is expected. In order to add more animations for the character, the flash document for the character must be modified.
	 * @author 
	 */
	public class AnimatedCharacterMod extends Mod implements IModdable
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
		//The name of the character added by the mod. There can't be multiple characters added with the same name. 
		protected var m_characterName:String;
		//The name of the group this mod is in. This is for animation mods that add animations for the same character, visual wise (example: Peach and PeachP (polished)), without the issues caused by character name collisions.
		protected var m_characterGroup:String;
		
		
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
			}
		}
		
		//Function that makes sure all the data of the mod is set up. Primarily used for backwards compatibility with older versions of the mod.
		public function ValidateData():void
		{
			if (m_menuIcon != null)
			{
				m_menuIcon.name = getQualifiedClassName(m_menuIcon);
			}
			if (m_characterGroup == null || m_characterGroup == "")
			{
				//For compatibility purposes with older mods, group name is set to the character name.
				m_characterGroup = m_characterName;
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
			group: m_characterGroup,
			animation: initialAnimationContainer };
			return data;
		}
		
		public function OutputModDetails():String
		{
			var output:String = "Character Name: " + m_characterName + ", Group Name: " + m_characterGroup + ", Preferred Music: " + m_preferredMusicName;
			return output;
		}
		
		public override function Dispose():void
		{
			super.Dispose();
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
			m_characterGroup = null;
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