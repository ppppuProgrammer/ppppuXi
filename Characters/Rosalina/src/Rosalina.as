package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Rosalina extends AnimatedCharacter 
	{
		
		public function Rosalina()
		{
			m_outerDiamondColor = m_bottomRightDiamondColor = m_centerDiamondColor = m_topLeftDiamondColor = 
				new ColorTransform(0.62, 1.0, 1.0, 1.0, -59, 22, 102, 0);
			m_backlightColor = new ColorTransform(.62, 1, 1, 1, -59, 22, 102);
			/*m_centerDiamondColor = CreateColorTransformFromHex(0x0);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x0);
			m_outerDiamondColor = CreateColorTransformFromHex(0x618EE9);*/
			
			m_menuIcon = new RosaIcon();
			
			m_name = "Rosalina";
			
		}
		
	}

}