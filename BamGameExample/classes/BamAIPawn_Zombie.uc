class BamAIPawn_Zombie extends BamAIPawn_Example;

DefaultProperties
{
	ControllerClass=class'BamAIController_Zombie'

	Begin Object name=CharMesh
		AnimTreeTemplate=AnimTree'bam_ch_zombie.AnimTrees.ZombieAnimTree'
		AnimSets[0]=AnimSet'bam_ch_default.AnimSets.DefaultAnims'
		AnimSets[1]=AnimSet'bam_ch_zombie.AnimSets.ZombieAnims'
		Materials[0]=MaterialInstanceConstant'bam_ch_default.Materials.character_zombie_Mat_INST'
	End Object

	DefaultInventory.Empty

	GroundSpeed=110.0
	WalkingPct=1.0
	AccelRate=512.0
	PeripheralVision=0.7071

	Health=500.0
	HealthMax=500.0
}