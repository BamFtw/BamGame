class BamAIPawn_Attacker extends BamAIPawn_Example;

DefaultProperties
{
	ControllerClass=class'BamAIController_Attacker'

	Begin Object name=CharMesh
		Materials[0]=MaterialInstanceConstant'bam_ch_default.Materials.character_ninja_Mat_INST'
	End Object

	DefaultInventory[0]=class'BamWeapon_Rifle'
}