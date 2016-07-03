package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class PiranhagirlsMod extends AnimatedCharacterMod
    {
        public function PiranhagirlsMod()
        {
            this.characterPayload = new Piranhagirls();
			initialAnimationContainer = new PiranhagirlsAnimations();
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
        }
    }
}