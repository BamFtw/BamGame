class BamPlayerPawn_Example extends BamAIPawn_Example;

DefaultProperties
{
	Begin Object name=CharMesh
		Materials[0]=MaterialInstanceConstant'bam_ch_default.Materials.character_casual2_Mat_INST'
	End Object

	begin object name=Hat
		SkeletalMesh=SkeletalMesh'bam_ch_hats.SkeletalMeshes.Hat'
	End Object

	DefaultInventory[0]=class'BamWeapon_Rifle'

	Health=10000
	HealthMax=10000
	Detectability=0.75
}