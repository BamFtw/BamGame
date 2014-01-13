class BamPawn extends GamePawn
	placeable
	abstract;


struct BamMeleeAttackProperties
{
	/** Damage dealt by this attack */
	var int Damage;
	/** Range of the attack */
	var float Range;
	/** Minimum dot product between Pawns direction and Vector between Pawn and target for target to be valid */
	var float MinDot;
	/** How many enemies can be hit with this attack */
	var int MaxNumOfHits;
	/** Whether damage can be dealt to friendly pawns */
	var bool bAllowFriendlyFire;
};

struct BamFootstepSoundsContainer
{
	/** Name of the physical material under the Pawn */
	var() Name PhysicalMaterialName;
	/** SoundCues that can be played on this material */
	var() array<SoundCue> SoundCues;
};

/** Minimum time between two footsteps */
var(Footsteps) float FoostepInterval;
/** Time of the last footstep sound played */
var float LastFootstepSoundPlayTime;
/** If right physical material name is not found in FootstepSounds this sound will be played */
var(Footsteps) SoundCue DefaultFootstepSound;
/** List of the footstep sound and materials they should be played on */
var(Footsteps) array<BamFootstepSoundsContainer> FootstepSounds;

/** Reference to GameInfo object */
var BamGameInfo Game;

/** AnimNode used for adjusting animation depending on direction the pawn is looking at */
var AnimNodeAimOffset CharacterAimOffset;

/** AnimNode used for playing custom animations on character mesh*/
var AnimNodeSlot CharacterFullBodySlot;
/** AnimNode used for playing custom animations on the top half of character mesh*/
var AnimNodeSlot CharacterTopBodySlot;
/** AnimNode used for playing custom animations on the bottom half of character mesh*/
var AnimNodeSlot CharacterBottomBodySlot;

/** AnimNode used for playing custom animations on arms mesh */
var AnimNodeSlot ArmsFullBodySlot;

/** AnimNode responsible for setting right cover animations */
var BamAnimNode_Covering CharacterCoverState;



/** Mesh component of the character viewed from the third person perspective */
var() UDKSkeletalMeshComponent CharacterMesh;
/** Mesh of the first person arms */
var() UDKSkeletalMeshComponent ArmsMesh;


/** Pitch of the aim offset that should be set in AimOffset node */
var Repnotify float CharacterAimOffsetPitch;
/** Arms will be offset forward by this value so they would not disappear at certain camera angles */
var() float ArmsForwardOffset;


/** Time this pawn was seen by the enemies is multiplied by this value which might lead to slower or faster detection */
var() float Detectability;


/** Name of the socket on arms mesh where the weapon should be attached */
var name FPWeaponSocketName;

/** Name of the socket on character mesh where the weapon should be attached */
var name TPWeaponSocketName;

/** Names of the bones that count as head */
var array<string> HeadBoneNames;


var float HeadshotDamageMultiplier;


/** Amount of spread that will be added to weapon */
var(Stats) float WeaponSpread;
/** Affects reaction time, peripheral vision and such */
var(Stats) float Awareness;
/** Multiplier of damage taken by pawn */
var(Stats) float DamageTakenMultiplier;

/** Actor responsible for informing controller about projectiles passing by */
var BamActor_ProjectileCatcher ProjectileCatcher;

/** Whether DesiredLocation is currently in use */
var bool bUseDesiredLocation;
/** Location to which pawn should be moved to with its GroundSpeed without using Velocity */
var Vector DesiredLocation;

/** 
 * Properties of pawns melee attack that can be adjusted or overriden
 * by its weapon when dealing damage via DealMeleeDamage function 
 */
var() BamMeleeAttackProperties MeleeProperties;

/** List of Inventory clases that should be added to pawns inventory after its spawned */
var() array<class<Inventory> > DefaultInventory;




/** Caches reference to BamGameInfo object */
simulated event PreBeginPlay()
{
	super.PreBeginPlay();

	Game = BamGameInfo(class'WorldInfo'.static.GetWorldInfo().Game);
}

/** Initialization */
event PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnDefaultInventory();
	SpawnProjectileCatcher();
}

function SpawnProjectileCatcher()
{
	ProjectileCatcher = Spawn(class'BamActor_ProjectileCatcher', self, , Location, Rotation, , true);
	
	if( ProjectileCatcher != none )
	{
		Attach(ProjectileCatcher);
	}
}



/** Spawns default inventory from DefaultInventory list */
function SpawnDefaultInventory()
{
	local int q;
	local Inventory inv;

	for(q = 0; q < DefaultInventory.Length; ++q)
	{
		inv = Spawn(DefaultInventory[q]);
		if( inv != none )
		{
			InvManager.AddInventory(inv, false);
		}
	}
}

/** Caches anim nodes */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);

	if( SkelComp == ArmsMesh )
	{
		ArmsFullBodySlot = AnimNodeSlot(SkelComp.FindAnimNode('FullBodySlot'));
	}
	else if( SkelComp == CharacterMesh )
	{
		CharacterFullBodySlot = AnimNodeSlot(SkelComp.FindAnimNode('FullBodySlot'));
		CharacterTopBodySlot = AnimNodeSlot(SkelComp.FindAnimNode('TopBodySlot'));
		CharacterBottomBodySlot = AnimNodeSlot(SkelComp.FindAnimNode('BottomBodySlot'));
		CharacterAimOffset = AnimNodeAimOffset(SkelComp.FindAnimNode('AimOffset'));
		CharacterCoverState = BamAnimNode_Covering(SkelComp.FindAnimNode('CoverStance'));
	}
}

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	HandleDesiredLocation(DeltaTime);

	// update first person arms location and rotation
	if( ArmsMesh != none )
	{
		ArmsMesh.SetRotation(GetViewRotation());
		ArmsMesh.SetTranslation((GetPawnViewLocation() - Location) + Vector(GetViewRotation()) * ArmsForwardOffset);
	}

	AdjustPeripheralVision();
	
	AdjustAimOffset();
}

/** Sets PeripheralVision depending on Awareness */
function AdjustPeripheralVision()
{
	local float originalPeripheralVision;
	originalPeripheralVision = BamAIPawn(ObjectArchetype) == none ? default.PeripheralVision : BamAIPawn(ObjectArchetype).PeripheralVision;
	PeripheralVision = FClamp(1 - ((1 - originalPeripheralVision) * Awareness), 0, 1);	
}


function float GetViewPitch()
{
	if( Controller != none )
	{
		return Controller.Rotation.Pitch;
	}

	return Rotation.Pitch;
}

/** Updates aim offset of the character mesh */
function AdjustAimOffset()
{
	local float Pitch;

	if( CharacterAimOffset != none && Controller != none )
	{
		Pitch = GetViewPitch();
		
		if( Pitch > 16383.1 )
		{
			Pitch = -(65536.0 - Pitch);
		}

		CharacterAimOffsetPitch = FClamp(Pitch / 16383.0, -1.0, 1.0);

		CharacterAimOffset.Aim.Y = CharacterAimOffsetPitch;
	}
}

/**
 * Moves Pawn to specified location without using velocity
 * @param inLocation location to which Pawn should be moved
 */
function SetDesiredLocation(Vector inLocation)
{
	local float distance, duration;

	distance = VSize2D(Location - inLocation);

	if( distance == 0 )
		return;

	// failsafe duration
	duration = distance / GroundSpeed;

	SetTimer(duration * 1.1, false, NameOf(DesiredLocationFailsafe));

	bUseDesiredLocation = true;
	DesiredLocation = inLocation;
}

/** Cancels use of DesiredLocation */
function CancelDesiredLocation()
{
	DesiredLocationReached();
}

/**
 * Moves Pawn toward DesiredLocation with right speed without using velocity
 * @param DeltaTime 
 */
function HandleDesiredLocation(float DeltaTime)
{
	local float distance, stepSize;
	
	if( !bUseDesiredLocation )
	{
		return;
	}

	Velocity = vect(0, 0, 0);

	distance = VSize2D(Location - DesiredLocation);
	if( distance > 0 )
	{
		stepSize = FMin(distance, GroundSpeed * DeltaTime);
		Move(Normal(DesiredLocation - Location) * stepSize);
	}

	if( VSize2D(Location - DesiredLocation) < 0.1 )
	{
		DesiredLocationReached();
	}
}

/** Called by timer if Pawn gets stucked */
function DesiredLocationFailsafe()
{
	DesiredLocationReached();
}

/** Stops use of DesiredLocation */
function DesiredLocationReached()
{
	ClearTimer(NameOf(DesiredLocationFailsafe));
	bUseDesiredLocation = false;
	DesiredLocation = Location;
}

/** Checks for haedshot */
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int actualDamage;
	local PlayerController PC;
	local Controller Killer;

	// modify damage by this pawns DamageTakenMultiplier
	Damage *= DamageTakenMultiplier;

	if( Game.GameIntensity.GetParamValue(class'BamGIParam_AllowFriendlyFire') == 0 && IsPawnFriendly(InstigatedBy.Pawn) )
	{
		`trace("Friendly fire ignored", `cyan);
		return;
	}

	// adjust damage for GI
	if( GetALocalPlayerController().Pawn == self )
	{
		Damage *= Game.GameIntensity.GetParamValue(class'BamGIParam_DamageTakenMultiplier_Player');
	}

	// check for headshot bones and adjust damage
	if( HeadBoneNames.Find(string(HitInfo.BoneName)) != INDEX_NONE )
	{
		Damage *= HeadshotDamageMultiplier;
	}

	// below copy of super(Pawn).TakeDamage with exclusion of MakeNoise
	if ( (Role < ROLE_Authority) || (Health <= 0) )
	{
		return;
	}

	if ( damagetype == None )
	{
		if ( InstigatedBy == None )
			`warn("No damagetype for damage with no instigator");
		else
			`warn("No damagetype for damage by "$instigatedby.pawn$" with weapon "$InstigatedBy.Pawn.Weapon);
		//scripttrace();
		DamageType = class'DamageType';
	}
	Damage = Max(Damage, 0);

	if (Physics == PHYS_None && DrivenVehicle == None)
	{
		SetMovementPhysics();
	}
	if (Physics == PHYS_Walking && damageType.default.bExtraMomentumZ)
	{
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	}
	momentum = momentum/Mass;

	if ( DrivenVehicle != None )
	{
		DrivenVehicle.AdjustDriverDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	}

	ActualDamage = Damage;
	WorldInfo.Game.ReduceDamage(ActualDamage, self, instigatedBy, HitLocation, Momentum, DamageType, DamageCauser);
	AdjustDamage(ActualDamage, Momentum, instigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);

	// call Actor's version to handle any SeqEvent_TakeDamage for scripting
	Super.TakeDamage(ActualDamage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	Health -= actualDamage;
	if (HitLocation == vect(0,0,0))
	{
		HitLocation = Location;
	}

	if ( Health <= 0 )
	{
		PC = PlayerController(Controller);
		// play force feedback for death
		if (PC != None)
		{
			PC.ClientPlayForceFeedbackWaveform(damageType.default.KilledFFWaveform);
		}
		// pawn died
		Killer = SetKillInstigator(InstigatedBy, DamageType);
		TearOffMomentum = momentum;
		Died(Killer, damageType, HitLocation);
	}
	else
	{
		HandleMomentum( momentum, HitLocation, DamageType, HitInfo );
		NotifyTakeHit(InstigatedBy, HitLocation, ActualDamage, DamageType, Momentum, DamageCauser);
		if (DrivenVehicle != None)
		{
			DrivenVehicle.NotifyDriverTakeHit(InstigatedBy, HitLocation, actualDamage, DamageType, Momentum);
		}
		if ( instigatedBy != None && instigatedBy != controller )
		{
			LastHitBy = instigatedBy;
		}
	}
	PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum, HitInfo);
}


/** Kills pawn */
simulated event TornOff()
{
	super.TornOff();
	Died(none, class'DamageType', vect(0,0,0));
}

simulated event bool Died(Controller Killer,  class<DamageType> DamageType,  vector HitLocation)
{
	PlayDying(DamageType, HitLocation);
	return super.Died(Killer, DamageType, HitLocation);
}

/**
 * Called by BamAnimNotify_MeleeAttack when the damage should be dealt
 * Finds pawns in melee range that are within melee cone of this pawn
 */
simulated function DealMeleeDamage()
{
	local int q, w, hitCount;
	local BamMeleeAttackProperties properties;
	local Vector Dir;
	local float RangeSq, DistanceSq;
	local array<Pawn> PotentialTargets;
	local array<float> Distances;
	local Pawn pwn;

	properties = MeleeProperties;

	// add weapon modifiers
	if( BamWeapon(Weapon) != none )
	{
		BamWeapon(Weapon).ModifyMeleeParameters(properties);
	}


	Dir = Vector(Rotation);
	RangeSq = properties.Range * properties.Range;

	foreach WorldInfo.AllPawns(class'Pawn', pwn)
	{
		// skip if Pawn is friendly and friendly fire is off
		if( !properties.bAllowFriendlyFire && !IsPawnHostile(pwn) )
		{
			continue;
		}

		DistanceSq = VSizeSq(pwn.Location - Location);
		// check if pawn is within range and in front of the pawn
		if( pwn != self && (DistanceSq <= RangeSq) && (Dir dot (pwn.Location - Location) >= properties.MinDot) )
		{
			// if array is empty or distance is greater than the greatest in the arry push back
			if( Distances.Length == 0 || DistanceSq > Distances[Distances.Length - 1]  )
			{
				PotentialTargets.AddItem(pwn);
				Distances.AddItem(DistanceSq);
			}
			// if distance is less than the smallest push front
			else if( DistanceSq < Distances[0] )
			{
				PotentialTargets.InsertItem(0, pwn);
				Distances.InsertItem(0, DistanceSq);
			}
			// else insert in appropriate position
			else
			{
				for(w = 1; w < Distances.Length; ++w)
				{
					if( DistanceSq > Distances[w - 1] && DistanceSq < Distances[w] )
					{
						PotentialTargets.InsertItem(w, pwn);
						Distances.InsertItem(w, DistanceSq);
						break;
					}
				}
			}
		}
	}

	if( PotentialTargets.Length == 0 )
	{
		return;
	}

	// choose number of units hit
	hitCount = properties.MaxNumOfHits <= 0 ? PotentialTargets.Length : properties.MaxNumOfHits;

	// deal damage
	for(q = 0; q < hitCount; ++q)
	{
		PotentialTargets[q].TakeDamage(properties.Damage, Controller, PotentialTargets[q].Location, vect(0,0,0), class'damageType');
	}

}

/** Returns whether pawn given as parameter is friendly */
function bool IsPawnFriendly(Pawn pwn)
{
	return !IsPawnHostile(pwn);
}

/** Returns whether pawn given as parameter is hostile */
function bool IsPawnHostile(Pawn pwn)
{
	return true;
}

/** Turns ragdoll on */
simulated event PlayDying(class<DamageType> DamageType,  vector HitLoc)
{
	super.PlayDying(DamageType, HitLoc);

	Mesh = CharacterMesh;

	if( Mesh != none && Mesh.PhysicsAssetInstance != none )
	{
		Mesh.MinDistFactorForKinematicUpdate = 0.0;
		Mesh.ForceSkelUpdate();
		Mesh.SetTickGroup(TG_PostAsyncWork);
		CollisionComponent = Mesh;
		CylinderComponent.SetActorCollision(false, false);
		Mesh.SetActorCollision(true, false);
		Mesh.SetTraceBlocking(true, true);
		SetPawnRBChannels(Mesh, true);
		SetPhysics(PHYS_RigidBody);
		Mesh.PhysicsWeight = 1.0;

		if( Mesh.bNotUpdatingKinematicDueToDistance )
			Mesh.UpdateRBBonesFromSpaceBases(true, true);

		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
		Mesh.bUpdateKinematicBonesFromAnimation = false;
		Mesh.WakeRigidBody();

		Mesh.SetAnimTreeTemplate(none);
	}
}

function Vector GetCenterLocation()
{
	local vector loc;
	local rotator rot;

	CharacterMesh.GetSocketWorldLocationAndRotation('ChestSocket', loc, rot);

	return loc;
}

simulated function SetPawnRBChannels(SkeletalMeshComponent meshComp, bool bRagdollMode)
{
	meshComp.SetRBChannel(bRagdollMode ? RBCC_Pawn : RBCC_Untitled3);
	meshComp.SetRBCollidesWithChannel(RBCC_Default, bRagdollMode);
	meshComp.SetRBCollidesWithChannel(RBCC_Pawn, bRagdollMode);
	meshComp.SetRBCollidesWithChannel(RBCC_Vehicle, bRagdollMode);
	meshComp.SetRBCollidesWithChannel(RBCC_Untitled3, !bRagdollMode);
	meshComp.SetRBCollidesWithChannel(RBCC_BlockingVolume, bRagdollMode);
}

/** Plays footstep sound that depends on PhysicalMaterial Pawn is on */
event PlayFootStepSound(int FootDown)
{
	local Vector sndLocation, HitLocation, HitNormal;
	local SoundCue selectedSound;
	local TraceHitInfo HitInfo;
	local int q;

	// make sure its not too soon
	if( `TimeSince(LastFootstepSoundPlayTime) < FoostepInterval )
	{
		return;
	}

	LastFootstepSoundPlayTime = WorldInfo.TimeSeconds;

	// set sound location at pawns feet
	sndLocation = Location;
	sndLocation.Z -= GetCollisionHeight() * 0.5;

	// trace to get PhysicalMaterial from HitInfo
	Trace(HitLocation, HitNormal, Location - vect(0, 0, 1) * GetCollisionHeight(), Location, , , HitInfo);

	// look for right SoundCue
	if( HitInfo.PhysMaterial != none && FootstepSounds.Length > 0 )
	{
		for(q = 0; q < FootstepSounds.Length; ++q)
		{
			if( FootstepSounds[q].PhysicalMaterialName == HitInfo.PhysMaterial.Name )
			{
				if( FootstepSounds[q].SoundCues.Length > 0 )
				{
					selectedSound = FootstepSounds[q].SoundCues[FootstepSounds[q].SoundCues.Length];
				}
				break;
			}
		}
	}

	// play found SoundCue or default one
	if( selectedSound != none || DefaultFootstepSound != none )
	{
		PlaySound(selectedSound == none ? DefaultFootstepSound : selectedSound, , , , sndLocation);
	}
}

State Dying
{
	ignores TakeDamage;
}


defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		// CollisionRadius=20.0
		CollisionRadius=16.0
		CollisionHeight=45.0
		bAlwaysRenderIfSelected=true
		BlockNonZeroExtent=true
		BlockZeroExtent=false
		BlockActors=true
		CollideActors=true
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=0.2
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object class=UDKSkeletalMeshComponent name=CharMesh
		SkeletalMesh=SkeletalMesh'bam_ch_default.SkeletalMeshes.Default'
		AnimTreeTemplate=AnimTree'bam_ch_default.AnimTrees.DefaultAnimTree'
		AnimSets[0]=AnimSet'bam_ch_default.AnimSets.DefaultAnims'
		AnimSets[1]=AnimSet'bam_ch_default.AnimSets.AimOffsets_Long'
		PhysicsAsset=PhysicsAsset'bam_ch_default.PhysicsAssets.Default_Physics'
		Materials[0]=MaterialInstanceConstant'bam_ch_default.Materials.character_gentleman_Mat_INST'
		bOwnerNoSee=true
		LightEnvironment=MyLightEnvironment
		Scale=2.0
		RBChannel=RBCC_Untitled3
		ScriptRigidBodyCollisionThreshold=1.0
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=true
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true

		CollideActors=true
		BlockZeroExtent=true
		AlwaysCheckCollision=true

		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		RBDominanceGroup=20
		bAllowAmbientOcclusion=false
		bUseOnePassLightingOnTranslucency=true
		bPerBoneMotionBlur=true
	End Object
	Components.Add(CharMesh)
	CharacterMesh=CharMesh

	begin object class=UDKSkeletalMeshComponent name=FirstPersonArms
		FOV=68.0
		SkeletalMesh=SkeletalMesh'bam_ch_player.Meshes.arms_base'
		AnimTreeTemplate=AnimTree'bam_ch_player.AnimTrees.arms_AnimTree'
		AnimSets[0]=AnimSet'bam_ch_player.AnimSets.arms_animSet'
		PhysicsAsset=None
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=true
		bIgnoreControllersWhenNotRendered=false
		bOnlyOwnerSee=true
		bOwnerNoSee=false
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=false
		AbsoluteTranslation=false
		AbsoluteRotation=true
		AbsoluteScale=true
		bSyncActorLocationToRootRigidBody=false
		CastShadow=false
		TickGroup=TG_PreAsyncWork
		LightEnvironment=MyLightEnvironment
		HiddenEditor=true
	end object
	Components.Add(FirstPersonArms);
	ArmsMesh=FirstPersonArms

	ArmsForwardOffset=5.0

	InventoryManagerClass=class'BamInventoryManager'

	RotationRate=(Yaw=32000)

	BaseEyeHeight=33.0
	EyeHeight=33.0


	GroundSpeed=110.0
	WalkingPct=3.0
	CrouchedPct=0.7

	MaxStepHeight=5.0

	JumpZ=400
	AccelRate=512.0

	PeripheralVision=0.17 // ~80
	//PeripheralVision=0.7071 // ~45 deg
	//PeripheralVision=0.866 // ~30 deg

	bCanCrouch=true
	UncrouchTime=1.5
	CrouchHeight=20.0
	CrouchRadius=20.0

	bBlocksNavigation=true

	FPWeaponSocketName=WeaponPoint
	TPWeaponSocketName=WeaponPoint

	TickGroup=TG_PreAsyncWork

	Detectability=1.0

	MeleeProperties=(Damage=30,Range=100,bAllowFriendlyFire=false,MinDot=0.5,MaxNumOfHits=1)

	HeadBoneNames=("Bip001-Head")
	HeadshotDamageMultiplier=2.0

	WeaponSpread=0.0
	Awareness=1.0
	DamageTakenMultiplier=1.0


	FoostepInterval=0.2
	LastFootstepSoundPlayTime=-9999
	DefaultFootstepSound=SoundCue'bam_snd_footsteps_wood.footsteps_wood'
}