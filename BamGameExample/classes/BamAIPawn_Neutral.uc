class BamAIPawn_Neutral extends BamAIPawn;

DefaultProperties
{
	ControllerClass=class'BamAIController_Neutral'

	Begin Object name=CharMesh
		AnimTreeTemplate=AnimTree'bam_ch_default.AnimTrees.NeutralAnimTree'
		Materials[0]=MaterialInstanceConstant'bam_ch_default.Materials.character_casual1_Mat_INST'
	End Object

	DefaultInventory.Empty

	HatSkelMesh=SkeletalMesh'bam_ch_hats.SkeletalMeshes.Cap'
}