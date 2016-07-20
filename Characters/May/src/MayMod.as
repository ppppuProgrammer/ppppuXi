package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class MayMod extends AnimatedCharacterMod
    {
        public function MayMod()
        {
            
			initialAnimationContainer = new MayAnimations;
			initialAnimationContainer.x = -99.15;
			initialAnimationContainer.y = 173.8;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFFFFFF);
			m_centerDiamondColor = CreateColorTransformFromHex(0xCCCCCC);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x999999);
			m_outerDiamondColor = CreateColorTransformFromHex(0xFF0000);
			m_backlightColor = CreateColorTransformFromHex(0x999999);
			
			m_menuIcon = new MayIcon;
			
			m_characterName = "May";
			m_preferredMusicName = "Miror B. Battle - Pokemon MayD";
        }
    }
}