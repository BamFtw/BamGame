class BamAIController_Defender extends BamAIController;

defaultproperties
{
	NeedManagerClass=class'BamNeedManager_Example'

	DefaultAction=(class=class'BamAIAction_Idle',Archetype=none)
	CombatAction=(class=class'BamAIAction_Combat',Archetype=none)
}