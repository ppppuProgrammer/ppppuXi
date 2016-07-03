package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class RosalinaMod extends AnimatedCharacterMod
    {
        public function RosalinaMod()
        {
            this.characterPayload = new Rosalina();
			initialAnimationContainer = new RosalinaAnimations();
			initialAnimationContainer.x = -223.8;
			initialAnimationContainer.y = 216.35;
        }
    }
}