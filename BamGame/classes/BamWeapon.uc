class BamWeapon extends UDKWeapon
	dependson(BamPawn);

/** Skeletal mesh component that should be attached to first person arms */
var UDKSkeletalMeshComponent FirstPersonMesh;
/** Skeletal mesh component that should be attached to third person character mesh */
var UDKSkeletalMeshComponent ThirdPersonMesh;

/** Name of the socket that is used as projectile start location, and effects spawn point */
var name MuzzleFlashSocket;

/** First person muzzle particle effect */
var ParticleSystemComponent FPMuzzleFlashPS;
/** Third person muzzle particle effect */
var ParticleSystemComponent TPMuzzleFlashPS;

/** Sound played on FireAmmunition */
var SoundCue FireSound;


/** Attaches particle systems to correct sockets */
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	FirstPersonMesh.AttachComponentToSocket(FPMuzzleFlashPS, MuzzleFlashSocket);
	ThirdPersonMesh.AttachComponentToSocket(TPMuzzleFlashPS, MuzzleFlashSocket);
}

/** Activates Muzzle particles and plays fire sound */
function ActivateMuzzleFlashEffects()
{
	if( FPMuzzleFlashPS != none )
	{
		FPMuzzleFlashPS.ActivateSystem(true);
	}

	if( TPMuzzleFlashPS != none )
	{
		TPMuzzleFlashPS.ActivateSystem(true);
	}

	if( Owner != none && FireSound != none )
	{
		Owner.PlaySound(FireSound);
	}
}

/** Returns location of the third person meshes MuzzleFlashSocket */
simulated event vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	local int q;
	local Vector Loc, HitNormal, HitLocation, adjustedLoc;
	local Rotator Rot;

	if( BamAIPawn(Owner) != none )
	{
		ThirdPersonMesh.GetSocketWorldLocationAndRotation(MuzzleFlashSocket, Loc, Rot);

		// test if location is not too close to world geometry if so try increasing height of start location
		for(q = 0; q < 5; ++q)
		{
			adjustedLoc = Loc + vect(0, 0, 5.0) * q;

			if( Trace(HitLocation, HitNormal, adjustedLoc + Vector(Rot) * 20.0, adjustedLoc, true, , , TRACEFLAG_Bullet) == none )
			{
				return adjustedLoc;
			}
			else
			{
				DrawDebugLine(adjustedLoc, adjustedLoc + Vector(Rot) * 20.0,  0, 255, 255, true);
			}
		}

		return Loc;
	}

	return super.GetPhysicalFireStartLoc(AimDir);
}

/** Fires weapon and activates muzzle effects */
simulated function FireAmmunition()
{
	super.FireAmmunition();
	ActivateMuzzleFlashEffects();
}

/** Attaches weapon meshes to Owners first and third person meshes */
function AttachToOwner()
{
	local BamPawn BOwner;
	BOwner = BamPawn(Owner);

	if( BOwner == none )
		return;

	// third person
	if( BOwner.CharacterMesh != none )
	{
		BOwner.CharacterMesh.AttachComponentToSocket(ThirdPersonMesh, BOwner.TPWeaponSocketName);
		ThirdPersonMesh.SetShadowParent(BOwner.CharacterMesh);
		ThirdPersonMesh.SetLightEnvironment(BOwner.CharacterMesh.LightEnvironment);
	}

	// first person
	if( BOwner.ArmsMesh != none )
	{
		BOwner.ArmsMesh.AttachComponentToSocket(FirstPersonMesh, BOwner.FPWeaponSocketName);
		FirstPersonMesh.SetFOV(BOwner.ArmsMesh.FOV);
	}
}

/** Detaches weapon meshes from owners meshes */
simulated function DetachWeapon()
{
	local BamPawn BOwner;
	BOwner = BamPawn(Owner);

	if( BOwner == none )
	{
		return;
	}

	// third person
	if( BOwner.CharacterMesh != none )
	{
		BOwner.CharacterMesh.DetachComponent(ThirdPersonMesh);
	}

	// first person
	if( BOwner.ArmsMesh != none )
	{
		BOwner.ArmsMesh.DetachComponent(FirstPersonMesh);
	}
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

/** Modifies parameters of the melee attack */
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
	simulated event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		DetachWeapon();
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
		SkeletalMesh=none
	End Object
	Components.Add(TPMesh);
	ThirdPersonMesh=TPMesh

	Begin Object class=ParticleSystemComponent name=FPMuzzleFlash
		Template=none
		bAutoActivate=false
		bIsActive=false
		bOwnerNoSee=false
		bOnlyOwnerSee=true
	End Object
	Components.Add(FPMuzzleFlash)
	FPMuzzleFlashPS=FPMuzzleFlash

	Begin Object class=ParticleSystemComponent name=TPMuzzleFlash
		Template=none
		bAutoActivate=false
		bIsActive=false
		bOwnerNoSee=true
		bOnlyOwnerSee=false
	End Object
	Components.Add(TPMuzzleFlash)
	TPMuzzleFlashPS=TPMuzzleFlash

	MuzzleFlashSocket=MuzzleFlashSocket

	FireSound=none

	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'BamProjectile'
	FireInterval(0)=0.15
	Spread(0)=0.04
	InstantHitDamage(0)=0
	InstantHitMomentum(0)=0
	InstantHitDamageTypes(0)=class'DamageType'
}