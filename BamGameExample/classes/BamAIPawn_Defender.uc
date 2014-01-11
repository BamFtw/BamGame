class BamAIPawn_Defender extends BamAIPawn_Example;

DefaultProperties
{
	ControllerClass=class'BamAIController_Defender'

	Begin Object name=CharMesh
		Materials[0]=MaterialInstanceConstant'bam_ch_default.Materials.character_gentleman_Mat_INST'
	End Object

	begin object name=Hat
		SkeletalMesh=SkeletalMesh'bam_ch_hats.SkeletalMeshes.tophat'
	End Object

	DefaultInventory[0]=class'BamWeapon_Rifle'
}