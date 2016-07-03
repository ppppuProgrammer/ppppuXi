package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	////import ppppu.Character;
	
	/**
	 * ...
	 * @author 
	 */
	public class Daisy extends AnimatedCharacter 
	{
		
		public function Daisy()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFFF2CA);
			m_centerDiamondColor = CreateColorTransformFromHex(0xFFE89F);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0xFFD75E);
			m_outerDiamondColor = CreateColorTransformFromHex(0xFFCC33);
			m_backlightColor = CreateColorTransformFromHex(0xFFCC00);
			
			m_menuIcon = new DaisyIcon();
			
			m_name = "Daisy"; 
			m_defaultMusicName = "SML1_1";
		}
		
	}

}