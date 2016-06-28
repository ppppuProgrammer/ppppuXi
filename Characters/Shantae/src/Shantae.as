package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Shantae extends AnimatedCharacter 
	{
		
		public function Shantae()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFE9707);
			m_centerDiamondColor = CreateColorTransformFromHex(0xF84704);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0xEE2703);
			m_backgroundColor = CreateColorTransformFromHex(0xF3B80B);
			m_charAnimations = new ShantaeAnimations();
			m_charAnimations.x = -54.55;
			m_charAnimations.y = 92.75;
			m_menuIcon = new ShantaeIcon();
			
			m_name = "Shantae";
			m_defaultMusicName = "Burning Town PC";
		}
		
	}

}