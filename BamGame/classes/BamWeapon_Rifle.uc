class BamWeapon_Rifle extends BamWeapon;


DefaultProperties
{
	Begin Object Name=FPMesh
		SkeletalMesh=SkeletalMesh'bam_wp_rifle.SkeletalMeshes.rifle'
	End Object

	Begin Object Name=TPMesh
		SkeletalMesh=SkeletalMesh'bam_wp_rifle.SkeletalMeshes.rifle'
		bOwnerNoSee=false
	End Object

	Begin Object name=FPMuzzleFlash
		Template=ParticleSystem'bam_p_wp_muzzleFlash_rifle.ps.RifleMuzzleFlash'
	End Object

	Begin Object name=TPMuzzleFlash
		Template=ParticleSystem'bam_p_wp_muzzleFlash_rifle.ps.RifleMuzzleFlash'
	End Object

	FireSound=SoundCue'bam_snd_wp_rifle.Cue.rifleFireSound'

	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'BamProjectile'
	FireInterval(0)=0.13
	Spread(0)=0.05
	InstantHitDamage(0)=0
	InstantHitMomentum(0)=0
	InstantHitDamageTypes(0)=class'DamageType'
}