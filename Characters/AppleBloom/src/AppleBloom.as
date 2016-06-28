package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class AppleBloom extends AnimatedCharacter 
	{
		
		public function AppleBloom()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xEF67A5);
			m_centerDiamondColor = CreateColorTransformFromHex(0xD7298F);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x99258E);
			m_backgroundColor = CreateColorTransformFromHex(0xF6B7D2);
			m_backlightColor = CreateColorTransformFromHex(0x49FBE1);
			m_charAnimations = new AppleBloomAnimations();
			m_charAnimations.x = -54.05;
			m_charAnimations.y = 93;
			m_menuIcon = new AppleBloomIcon();
			
			m_name = "Apple Bloom"; 
			m_defaultMusicName = "CMC GC";
		}
		
	}

}