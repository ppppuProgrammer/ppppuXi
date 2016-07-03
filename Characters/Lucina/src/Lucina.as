package
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Lucina extends AnimatedCharacter 
	{
		
		public function Lucina()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xC4CCE1);
			m_centerDiamondColor = CreateColorTransformFromHex(0xA3B1D1);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x869AC4);
			m_outerDiamondColor = CreateColorTransformFromHex(0x496298);
			m_backlightColor = new ColorTransform(0, 0, 1);
			
			m_menuIcon = new LucinaIcon();
			
			m_name = "Lucina";
			m_defaultMusicName = " FE Spa";
		}
		
	}

}