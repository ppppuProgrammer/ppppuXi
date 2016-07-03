package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class KoopagirlsMod extends AnimatedCharacterMod
    {
        public function KoopagirlsMod()
        {
            this.characterPayload = new Koopagirls();
			initialAnimationContainer = new KoopagirlsAnimations();
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
        }
    }
}