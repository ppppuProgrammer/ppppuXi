package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ToadetteMod extends AnimatedCharacterMod
    {
        public function ToadetteMod()
        {
            
            initialAnimationContainer = new ToadetteAnimations;
			m_menuIcon = new ToadetteIcon;
			
			m_characterName = "Toadette";
        }
    }
}