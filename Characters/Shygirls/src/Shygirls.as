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
			m_outerDiamondColor = CreateColorTransformFromHex(0xFFFFFF);
			m_backlightColor = new ColorTransform(.99, .99, .99);
			
			
			m_menuIcon = new SGIcon();
			
			m_name = "Shygirls";
			//m_defaultMusicName = "";
		}
	}

}