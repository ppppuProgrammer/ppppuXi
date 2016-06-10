package 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author 
	 */
	public class Shygirls extends AnimatedCharacter  
	{
		
		public function Shygirls()
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0x58DBFB);
			m_centerDiamondColor = CreateColorTransformFromHex(0x3C64CF);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x142B85);
			m_backgroundColor = CreateColorTransformFromHex(0xFFFFFF);
			m_backlightColor = new ColorTransform(.99, .99, .99);
			
			m_charAnimations = new ShygirlsAnimations();
			m_charAnimations.x = -54.05;
			m_charAnimations.y = 93;
			m_menuButton = new ShygirlsButton();
			m_menuButton.SetHitArea(new SquareBtnHitArea(110, 70));
			m_name = "Shygirls";
			m_musicClassName = "WiiFitBGM";
			m_musicTitle = "Training Menu - Wii Fit";
			m_musicStartPoint = ConvertSamplesToMilliseconds(576);
			m_musicLoopStartPoint = ConvertSamplesToMilliseconds(1415850) + m_musicStartPoint;
			m_musicLoopEndPoint = (ConvertSamplesToMilliseconds(3527735) + m_musicStartPoint);
		}
	}

}