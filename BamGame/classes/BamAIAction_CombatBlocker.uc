class BamAIAction_CombatBlocker extends BamAIAction
	hidecategories(BamAIAction)
	editinlinenew;

static function BamAIAction_CombatBlocker Create()
{
	local BamAIAction_CombatBlocker action;
	action = new default.class;
	return action;
}

DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=true

	Duration=0
}