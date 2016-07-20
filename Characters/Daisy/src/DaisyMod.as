package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class DaisyMod extends AnimatedCharacterMod
    {
        public function DaisyMod()
        {
            
			initialAnimationContainer = new DaisyAnimations;
			initialAnimationContainer.x = -99.4;
			initialAnimationContainer.y = 173.8;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFFF2CA);
			m_centerDiamondColor = CreateColorTransformFromHex(0xFFE89F);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0xFFD75E);
			m_outerDiamondColor = CreateColorTransformFromHex(0xFFCC33);
			m_backlightColor = CreateColorTransformFromHex(0xFFCC00);
			
			m_menuIcon = new DaisyIcon;
			
			m_characterName = "Daisy"; 
			m_preferredMusicName = "SML1_1";
        }
    }
}