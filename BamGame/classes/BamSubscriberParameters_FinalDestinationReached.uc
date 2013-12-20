class BamSubscriberParameters_FinalDestinationReached extends BamSubscriberParameters;

var Vector Location;

static function BamSubscriberParameters_FinalDestinationReached Create(BamAIController ctrl, BamAIPawn pwn, Vector loc)
{
	local BamSubscriberParameters_FinalDestinationReached instance;

	instance = new default.class;

	instance.Controller = ctrl;
	instance.Pawn = pwn;
	instance.Location = loc;

	return instance;
}