class BamPawn extends GamePawn
	placeable
	abstract;

/** Reference to GameInfo object */
var BamGameInfo Game;

/** AnimNode used for adjusting animation depending on direction the pawn is looking at */
var AnimNodeAimOffset CharacterAimOffset;
/** AnimNode used for playing custom animations on character mesh*/
var AnimNodeSlot CharacterFullBodySlot;
var AnimNodeSlot CharacterTopBodySlot;
var AnimNodeSlot CharacterBottomBodySlot;
/** AnimNode used for playing custom animations on arms mesh */
var AnimNodeSlot ArmsFullBodySlot;
/** AnimNode responsible for setting right cover animations */
var BamAnimNode_Covering CharacterCoverState;



/** Mesh component of the character viewed from the third person perspective */
var() UDKSkeletalMeshComponent CharacterMesh;
/** Mesh of the first person arms */
var() UDKSkeletalMeshComponent ArmsMesh;
/** Mesh component of the hat this pawn is wearing */
var() UDKSkeletalMeshComponent HatMesh;
/** SkeletalMesh that will be asigned to SkeletalMesh of HatMesh component */
var() SkeletalMesh HatSkelMesh;

/** Pitch of the aim offset that should be set in AimOffset node */
var Repnotify float CharacterAimOffsetPitch;
/** Arms will be offset forward by this value so they would not disappear at certain camera angles */
var() float ArmsForwardOffset;

/** Name of the socket on arms mesh where the weapon should be attached */
var name FPWeaponSocketName;
/** Name of the socket on character mesh where the weapon should be attached */
var name TPWeaponSocketName;


/** Whether DesiredLocation is currently in use */
var bool bUseDesiredLocation;
/** Location to which pawn should be moved to with its GroundSpeed without using Velocity */
var Vector DesiredLocation;

var array<class<Inventory> > DefaultInventory;




replication
{
	if( bNetDirty )
		CharacterAimOffsetPitch;
}

simulated event PreBeginPlay()
{
	super.PreBeginPlay();

	Game = BamGameInfo(class'WorldInfo'.static.GetWorldInfo().Game);
}

event PostBeginPlay()
{
	super.PostBeginPlay();

	HatMesh.SetSkeletalMesh(HatSkelMesh);
	CharacterMesh.AttachComponentToSocket(HatMesh, 'HatSocket');

	SpawnDefaultInventory();
	
}

function SpawnDefaultInventory()
{
	local int q;
	local Inventory inv;

	for(q = 0; q < DefaultInventory.Length; ++q)
	{
		inv = Spawn(class'BamWeapon_Rifle');
		if( inv != none )
			InvManager.AddInventory(inv, false);
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
	local float Pitch;

	super.Tick(DeltaTime);

	HandleDesiredLocation(DeltaTime);

	// update first person arms location and rotation
	if( ArmsMesh != none )
	{
		ArmsMesh.SetRotation(GetViewRotation());
		ArmsMesh.SetTranslation((GetPawnViewLocation() - Location) + Vector(GetViewRotation()) * ArmsForwardOffset);
	}

	// update aim offset of the character mesh
	if( CharacterAimOffset != none && Controller != none )
	{
		Pitch = GetViewRotation().Pitch;
		if( Pitch > 16383.1 )
			Pitch = -(65536.0 - Pitch);

		CharacterAimOffsetPitch = FClamp(Pitch / 16383.0, -1.0, 1.0);

		if( Role == ROLE_Authority)
		{
			if( CharacterAimOffset != none )
				CharacterAimOffset.Aim.Y = CharacterAimOffsetPitch;
		}
	}


}



function SetDesiredLocation(Vector inLocation)
{
	local float distance, duration;

	distance = VSize2D(Location - inLocation);

	if( distance == 0 )
		return;

	duration = distance / GroundSpeed;

	SetTimer(duration * 1.1, false, NameOf(DesiredLocationFailsafe));

	bUseDesiredLocation = true;
	DesiredLocation = inLocation;
}

function CancelDesiredLocation()
{
	DesiredLocationReached();
}

function HandleDesiredLocation(float DeltaTime)
{
	local float distance, stepSize;
	
	if( !bUseDesiredLocation )
	{
		return;
	}

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

function DesiredLocationFailsafe()
{
	DesiredLocationReached();
}

function DesiredLocationReached()
{
	ClearTimer(NameOf(DesiredLocationFailsafe));
	bUseDesiredLocation = false;
	DesiredLocation = Location;
}




simulated event ReplicatedEvent(name VarName)
{
	super.ReplicatedEvent(VarName);

	// update aim offset node
	if( VarName == NameOf(CharacterAimOffsetPitch) )
	{
		if( CharacterAimOffset != none )
			CharacterAimOffset.Aim.Y = CharacterAimOffsetPitch;
	}
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

simulated function DealMeleeDamage()
{
	`trace(self @ "Deal Damage ---------------------------------", `green);
}

/** */
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

simulated function SetPawnRBChannels(SkeletalMeshComponent meshComp, bool bRagdollMode)
{
	meshComp.SetRBChannel(bRagdollMode ? RBCC_Pawn : RBCC_Untitled3);
	meshComp.SetRBCollidesWithChannel(RBCC_Default, bRagdollMode);
	meshComp.SetRBCollidesWithChannel(RBCC_Pawn, bRagdollMode);
	meshComp.SetRBCollidesWithChannel(RBCC_Vehicle, bRagdollMode);
	meshComp.SetRBCollidesWithChannel(RBCC_Untitled3, !bRagdollMode);
	meshComp.SetRBCollidesWithChannel(RBCC_BlockingVolume, bRagdollMode);
}


State Dying
{
	ignores TakeDamage;
}


defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionRadius=20.0
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
		//TickGroup=TG_DuringASyncWork
		TickGroup=TG_PreAsyncWork
		LightEnvironment=MyLightEnvironment
		HiddenEditor=true
	end object
	Components.Add(FirstPersonArms);
	ArmsMesh=FirstPersonArms

	HatSkelMesh=none

	begin object class=UDKSkeletalMeshComponent name=Hat
		PhysicsAsset=PhysicsAsset'bam_ch_hats.Physics.tophat_Physics'
		SkeletalMesh=none
		bOwnerNoSee=true
		LightEnvironment=MyLightEnvironment
		ShadowParent=CharMesh
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
		bHasPhysicsAssetInstance=false
		TickGroup=TG_PreAsyncWork
		// MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		RBDominanceGroup=20
		bAllowAmbientOcclusion=false
		bUseOnePassLightingOnTranslucency=true
		bPerBoneMotionBlur=true
	end object
	Components.Add(Hat);
	HatMesh=Hat


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

	DefaultInventory.Add(class'BamWeapon_Rifle')

	bCanCrouch=true
	UncrouchTime=1.5
	CrouchHeight=20.0
	CrouchRadius=20.0

	bBlocksNavigation=true

	FPWeaponSocketName=WeaponPoint
	TPWeaponSocketName=WeaponPoint

	TickGroup=TG_PreAsyncWork
}