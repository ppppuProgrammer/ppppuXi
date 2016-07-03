package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class GardevoirMod extends AnimatedCharacterMod
    {
        public function GardevoirMod()
        {
            this.characterPayload = new Gardevoir();
			initialAnimationContainer = new GardevoirAnimations();
			initialAnimationContainer.x = -98.75;
			initialAnimationContainer.y = 174;
        }
    }
}