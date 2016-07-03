package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class FioraMod extends AnimatedCharacterMod
    {
        public function FioraMod()
        {
            this.characterPayload = new Fiora();
			initialAnimationContainer = new FioraAnimations();
			initialAnimationContainer.x = -226.8;
			initialAnimationContainer.y = 213.6;
        }
    }
}