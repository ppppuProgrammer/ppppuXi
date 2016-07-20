package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;
	import flash.geom.ColorTransform;

    public class ShygirlsMod extends AnimatedCharacterMod
    {
        public function ShygirlsMod()
        {
            
			initialAnimationContainer = new ShygirlsAnimations;
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0x58DBFB);
			m_centerDiamondColor = CreateColorTransformFromHex(0x3C64CF);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x142B85);
			m_outerDiamondColor = CreateColorTransformFromHex(0xFFFFFF);
			m_backlightColor = new ColorTransform(.99, .99, .99);
			
			
			m_menuIcon = new SGIcon;
			
			m_characterName = "Shygirls";
        }
    }
}