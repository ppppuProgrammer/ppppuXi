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
        }
    }
}