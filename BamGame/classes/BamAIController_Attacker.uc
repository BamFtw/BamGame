class BamAIController_Attacker extends BamAIController;

defaultproperties
{
	NeedManagerClass=class'BamNeedManager'

	DefaultAction=(class=class'BamAIAction_Idle',Archetype=none)
	CombatAction=(class=class'BamAIAction_Combat',Archetype=none)
}