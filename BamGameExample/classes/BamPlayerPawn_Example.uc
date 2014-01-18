class BamPlayerPawn_Example extends BamAIPawn_Example;

simulated event GetActorEyesViewPoint(out vector out_Location, out Rotator out_Rotation)
{
	local Rotator rot;
	local Vector loc;

	CharacterMesh.GetSocketWorldLocationAndRotation('EyesSocket', out_Location, rot);
	super.GetActorEyesViewPoint(loc, out_Rotation);
}

DefaultProperties
{
	Begin Object name=CharMesh
		Materials[0]=MaterialInstanceConstant'bam_ch_default.Materials.character_casual2_Mat_INST'
		bOwnerNoSee=false
	End Object

	Begin Object name=FirstPersonArms
		bOwnerNoSee=true
	End Object

	begin object name=Hat
		SkeletalMesh=SkeletalMesh'bam_ch_hats.SkeletalMeshes.Hat'
	End Object

	DefaultInventory[0]=class'BamWeapon_Rifle'

	Health=10000
	HealthMax=10000
	Detectability=0.75
}