package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class WiiFitTrainerMod extends AnimatedCharacterMod
    {
        public function WiiFitTrainerMod()
        {
            
			initialAnimationContainer = new WFTAnimations;
			initialAnimationContainer.x = -54.75;
			initialAnimationContainer.y = 92;
			m_topLeftDiamondColor = CreateColorTransformFromHex(0xA0D551);
			m_centerDiamondColor = CreateColorTransformFromHex(0x6FBD1C);
			m_bottomRightDiamondColor = CreateColorTransformFromHex(0x30B001);
			m_outerDiamondColor = CreateColorTransformFromHex(0xD1EF8B);
			
			m_menuIcon = new WFTIcon;
			
			m_characterName = "WiiFitTrainer";
			m_preferredMusicName = "WF Training Menu";
        }
    }
}