package
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Isabelle extends AnimatedCharacter 
	{
		
		public function Isabelle()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFFEC9B);
			m_centerDiamondColor = CreateColorTransformFromHex(0xEAC033);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x55482A);
			m_backgroundColor = CreateColorTransformFromHex(0x956329);
			//m_backlightColor = new ColorTransform(1.0, 1.0, 1.0, 1.0, 156, -22, -103);
			m_charAnimations = new IsabelleAnimations();
			m_charAnimations.x = -54.75;
			m_charAnimations.y = 92;
			m_menuIcon = new IsabelleIcon();

			
			m_name = "Isabelle";
			m_defaultMusicName = "2 AM";
		}
		
	}

}