package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class AppleBloomMod extends AnimatedCharacterMod
    {
        public function AppleBloomMod()
        {
            this.characterPayload = new AppleBloom();
        }
    }
}