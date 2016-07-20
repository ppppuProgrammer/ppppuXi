package
{
	import flash.geom.ColorTransform;
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class RosalinaMod extends AnimatedCharacterMod
    {
        public function RosalinaMod()
        {
            
			initialAnimationContainer = new RosalinaAnimations;
			initialAnimationContainer.x = -223.8;
			initialAnimationContainer.y = 216.35;
			m_backlightColor = m_outerDiamondColor = m_bottomRightDiamondColor = m_centerDiamondColor = m_topLeftDiamondColor = 
				new ColorTransform(0.62, 1.0, 1.0, 1.0, -59, 22, 102);
			/*m_centerDiamondColor = CreateColorTransformFromHex(0x0);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x0);
			m_outerDiamondColor = CreateColorTransformFromHex(0x618EE9);*/
			
			m_menuIcon = new RosaIcon;
			
			m_characterName = "Rosalina";
        }
    }
}