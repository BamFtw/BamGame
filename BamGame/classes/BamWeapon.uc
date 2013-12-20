class BamWeapon extends UDKWeapon
	dependson(BamPawn);

/** Skeletal mesh component that should be attached to first person arms */
var UDKSkeletalMeshComponent FirstPersonMesh;
/** Skeletal mesh component that should be attached to third person character mesh */
var UDKSkeletalMeshComponent ThirdPersonMesh;

var name MuzzleFlashSocket;

var ParticleSystemComponent FPMuzzleFlashPS;
var ParticleSystemComponent TPMuzzleFlashPS;

var SoundCue FireSound;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	FirstPersonMesh.AttachComponentToSocket(FPMuzzleFlashPS, MuzzleFlashSocket);
	ThirdPersonMesh.AttachComponentToSocket(TPMuzzleFlashPS, MuzzleFlashSocket);
}

function ActivateMuzzleFlashEffects()
{
	FPMuzzleFlashPS.ActivateSystem(true);
	TPMuzzleFlashPS.ActivateSystem(true);

	if( Owner != none && FireSound != none )
		Owner.PlaySound(FireSound);
}

simulated event vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	local Vector Loc;
	local Rotator Rot;

	if( BamAIPawn(Owner) != none )
	{
		ThirdPersonMesh.GetSocketWorldLocationAndRotation(MuzzleFlashSocket, Loc, Rot);
		return Loc;
	}

	return super.GetPhysicalFireStartLoc(AimDir);
}

simulated function FireAmmunition()
{
	super.FireAmmunition();
	ActivateMuzzleFlashEffects();
}

/** Attaches weapon meshes to Owner meshes */
function AttachToOwner()
{
	local BamPawn BOwner;
	BOwner = BamPawn(Owner);

	if( BOwner == none )
		return;

	BOwner.CharacterMesh.AttachComponentToSocket(ThirdPersonMesh, BOwner.TPWeaponSocketName);
	ThirdPersonMesh.SetShadowParent(BOwner.CharacterMesh);
	ThirdPersonMesh.SetLightEnvironment(BOwner.CharacterMesh.LightEnvironment);

	BOwner.ArmsMesh.AttachComponentToSocket(FirstPersonMesh, BOwner.FPWeaponSocketName);
	FirstPersonMesh.SetFOV(BOwner.ArmsMesh.FOV);


}

/** Detaches weapon meshes from owners meshes */
simulated function DetachWeapon()
{
	local BamPawn BOwner;
	BOwner = BamPawn(Owner);

	if( BOwner == none )
		return;

	BOwner.CharacterMesh.DetachComponent(ThirdPersonMesh);
	BOwner.ArmsMesh.DetachComponent(FirstPersonMesh);
}


function ModifyMeleeParameters(out BamMeleeAttackProperties properities);


simulated state WeaponEquipping
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		AttachToOwner();
	}
}

simulated state WeaponPuttingDown
{
}

/**
 * Adds any fire spread offset to the passed in rotator
 * @param Aim the base aim direction
 * @return the adjusted aim direction
 */
simulated function rotator AddSpread(rotator BaseAim)
{
	local vector X, Y, Z;
	local float CurrentSpread, RandY, RandZ;

	CurrentSpread = Spread[CurrentFireMode];

	// add pawns spread
	if( BamAIPawn(Owner) != none )
	{
		CurrentSpread = FMax(0, CurrentSpread + BamAIPawn(Owner).WeaponSpread);
	}

	if (CurrentSpread == 0)
	{
		return BaseAim;
	}
	else
	{
		// Add in any spread.
		GetAxes(BaseAim, X, Y, Z);
		RandY = FRand() - 0.5;
		RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
		return rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
	}
}

DefaultProperties
{
	Begin Object Class=UDKSkeletalMeshComponent Name=FPMesh
		DepthPriorityGroup=SDPG_Foreground
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
	End Object
	Components.Add(FPMesh);
	FirstPersonMesh=FPMesh

	Begin Object Class=UDKSkeletalMeshComponent Name=TPMesh
		bOnlyOwnerSee=false
		bOwnerNoSee=true
		SkeletalMesh=SkeletalMesh'bam_wp_rifle.SkeletalMeshes.rifle'
	End Object
	Components.Add(TPMesh);
	ThirdPersonMesh=TPMesh

	Begin Object class=ParticleSystemComponent name=FPMuzzleFlash
		Template=ParticleSystem'bam_p_wp_muzzleFlash_rifle.ps.RifleMuzzleFlash'
		bAutoActivate=false
		bIsActive=false
		bOwnerNoSee=false
		bOnlyOwnerSee=true
	End Object
	Components.Add(FPMuzzleFlash)
	FPMuzzleFlashPS=FPMuzzleFlash

	Begin Object class=ParticleSystemComponent name=TPMuzzleFlash
		Template=ParticleSystem'bam_p_wp_muzzleFlash_rifle.ps.RifleMuzzleFlash'
		bAutoActivate=false
		bIsActive=false
		bOwnerNoSee=true
		bOnlyOwnerSee=false
	End Object
	Components.Add(TPMuzzleFlash)
	TPMuzzleFlashPS=TPMuzzleFlash

	MuzzleFlashSocket=MuzzleFlashSocket

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