package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ShygirlsMod extends AnimatedCharacterMod
    {
        public function ShygirlsMod()
        {
            this.characterPayload = new Shygirls();
			initialAnimationContainer = new ShygirlsAnimations();
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
        }
    }
}