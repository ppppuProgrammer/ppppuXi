package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class IsabelleMod extends AnimatedCharacterMod
    {
        public function IsabelleMod()
        {
            
			initialAnimationContainer = new IsabelleAnimations;
			initialAnimationContainer.x = -54.75;
			initialAnimationContainer.y = 92;
			
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xFFEC9B);
			m_centerDiamondColor = CreateColorTransformFromHex(0xEAC033);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x55482A);
			m_outerDiamondColor = CreateColorTransformFromHex(0x956329);
			//m_backlightColor = 1.0, 1.0, 1.0, 1.0, 156, -22, -103;
			
			m_menuIcon = new IsabelleIcon;

			
			m_characterName = "Isabelle";
			m_preferredMusicName = "2 AM";
        }
    }
}