package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class LucinaMod extends AnimatedCharacterMod
    {
        public function LucinaMod()
        {
            this.characterPayload = new Lucina();
			initialAnimationContainer = new LucinaAnimations();
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
        }
    }
}