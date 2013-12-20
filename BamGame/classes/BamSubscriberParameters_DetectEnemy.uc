class BamSubscriberParameters_DetectEnemy extends BamSubscriberParameters;

var Pawn Seen;

static function BamSubscriberParameters_DetectEnemy Create(BamAIController ctrl, BamAIPawn pwn, Pawn seenPwn)
{
	local BamSubscriberParameters_DetectEnemy instance;

	instance = new default.class;

	instance.Controller = ctrl;
	instance.Pawn = pwn;
	
	instance.Seen = seenPwn;

	return instance;
}