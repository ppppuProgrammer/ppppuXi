package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class IrisMod extends AnimatedCharacterMod
    {
        public function IrisMod()
        {
            
			initialAnimationContainer = new IrisAnimations;
			initialAnimationContainer.x = -226.8;
			initialAnimationContainer.y = 213.6;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xBC508D);
			m_centerDiamondColor = CreateColorTransformFromHex(0xB43C76);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0xA03167);
			m_outerDiamondColor = CreateColorTransformFromHex(0x8F2C5B);
			m_backlightColor = CreateColorTransformFromHex(0x0, 0);
			
			m_menuIcon = new AAIcon;
			
			m_characterName = "Iris"; 
			m_preferredMusicName = "Turnabout Sisters";
        }
    }
}