package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ScootalooMod extends AnimatedCharacterMod
    {
        public function ScootalooMod()
        {
            this.characterPayload = new Scootaloo();
			initialAnimationContainer = new ScootalooAnimations();
			initialAnimationContainer.x = -54.05;
			initialAnimationContainer.y = 93;
        }
    }
}