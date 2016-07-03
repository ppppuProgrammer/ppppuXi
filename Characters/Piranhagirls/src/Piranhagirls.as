package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author 
	 */
	public class Piranhagirls extends AnimatedCharacter 
	{
		
		public function Piranhagirls() 
		{
			m_topLeftDiamondColor = CreateColorTransformFromHex(0x58DBFB);
			m_centerDiamondColor = CreateColorTransformFromHex(0x3C64CF);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x142B85);
			m_outerDiamondColor = CreateColorTransformFromHex(0xFFFFFF);
			m_backlightColor = new ColorTransform(.99, .99, .99);
			
			
			m_menuIcon = new PGIcon();
			
			m_name = "Piranhagirls";
			//m_defaultMusicName = "";
		}
		
	}
	
}