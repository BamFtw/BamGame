class BamAIController_Zombie extends BamAIController;

defaultproperties
{
	NeedManagerClass=class'BamNeedManager'

	DefaultAction=(class=class'BamAIAction_ZombieWander',Archetype=none)
	CombatAction=(class=class'BamAIAction_ZombieChase',Archetype=none)
}