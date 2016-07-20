package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class FioraMod extends AnimatedCharacterMod
    {
        public function FioraMod()
        {
            
			initialAnimationContainer = new FioraAnimations;
			initialAnimationContainer.x = -226.8;
			initialAnimationContainer.y = 213.6;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xBDCEEC);
			m_centerDiamondColor = CreateColorTransformFromHex(0x98B4DC);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x7C99C3);
			m_outerDiamondColor = CreateColorTransformFromHex(0x494E62);
			m_backlightColor = CreateColorTransformFromHex(0x0, 0);
			
			m_menuIcon = new XenoIcon;
			
			m_characterName = "Fiora";
			m_preferredMusicName = "Gaur Plain";
        }
    }
}