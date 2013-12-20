class BamPlayerPawn extends BamPawn;

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	Controller.PlaySound(SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_EnergyCue');
}

defaultproperties
{
	Begin Object name=CharMesh
		Materials[0]=MaterialInstanceConstant'bam_ch_default.Materials.character_casual2_Mat_INST'
	End Object

	Health=10000
	HealthMax=10000

	HatSkelMesh=SkeletalMesh'bam_ch_hats.SkeletalMeshes.Hat'
}