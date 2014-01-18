class BamAIAction_CombatBlocker extends BamAIAction
	hidecategories(BamAIAction)
	noteditinlinenew;

static function BamAIAction_CombatBlocker Create_CombatBlocker()
{
	local BamAIAction_CombatBlocker action;
	action = new class'BamAIAction_CombatBlocker';
	return action;
}

DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=true

	Duration=0
}