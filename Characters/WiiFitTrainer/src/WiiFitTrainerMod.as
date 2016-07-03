package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class WiiFitTrainerMod extends AnimatedCharacterMod
    {
        public function WiiFitTrainerMod()
        {
            this.characterPayload = new WiiFitTrainer();
			initialAnimationContainer = new WFTAnimations();
			initialAnimationContainer.x = -54.75;
			initialAnimationContainer.y = 92;
        }
    }
}