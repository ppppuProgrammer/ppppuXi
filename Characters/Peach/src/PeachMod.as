package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class PeachMod extends AnimatedCharacterMod
    {
        public function PeachMod()
        {
            
			initialAnimationContainer = new PeachAnimations;
			initialAnimationContainer.x = -226.8;
			initialAnimationContainer.y = 213.65;
			
			m_menuIcon = new PeachIcon;
			
			m_characterName = "Peach";
        }
    }
}