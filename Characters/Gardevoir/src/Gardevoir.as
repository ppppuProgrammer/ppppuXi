package  
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Gardevoir extends AnimatedCharacter 
	{
		
		public function Gardevoir()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFFFFFF);
			m_centerDiamondColor = CreateColorTransformFromHex(0xCCCCCC);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x999999);
			m_backgroundColor = CreateColorTransformFromHex(0xFF0000);
			m_backlightColor = CreateColorTransformFromHex(0x999999);
			m_charAnimations = new GardevoirAnimations();
			m_charAnimations.x = -98.75;
			m_charAnimations.y = 174;
			m_menuButton = new GardevoirButton();
			m_menuButton.SetHitArea(new SquareBtnHitArea(75,75));
			m_name = "Gardevoir";
			m_musicClassName = m_name + "BGM";
			m_musicTitle = "Route 1 - Pokemon Anime";
			m_musicStartPoint = ConvertSamplesToMilliseconds(576);
			m_musicLoopStartPoint = ConvertSamplesToMilliseconds(1066558) + m_musicStartPoint;
			m_musicLoopEndPoint= (ConvertSamplesToMilliseconds(2123951) + m_musicStartPoint);
		}
		
	}

}