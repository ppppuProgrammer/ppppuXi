package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Peach extends AnimatedCharacter 
	{
		
		public function Peach()
		{
			//m_topLeftDiamondColor = CreateColorTransformFromHex(0x0);
			//m_centerDiamondColor = CreateColorTransformFromHex(0x0);
			//m_bottomRightDiamondColor = CreateColorTransformFromHex(0x0);
			//m_backgroundColor = CreateColorTransformFromHex(0x0);
			m_charAnimations = new PeachAnimations();
			m_charAnimations.x = -226.8;
			m_charAnimations.y = 213.65;
			m_menuIcon = new PeachIcon();
			
			m_name = "Peach";
			
		}
		
	}

}