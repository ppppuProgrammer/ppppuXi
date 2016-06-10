package
{
    import modifications.AnimatedCharacterMod;
    import flash.display.Sprite;
    import flash.events.Event;

    public class DaisyMod extends AnimatedCharacterMod
    {
        public function DaisyMod()
        {
            this.characterPayload = new Daisy();
        }
    }
}