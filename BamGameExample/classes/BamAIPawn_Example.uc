class BamAIPawn_Example extends BamAIPawn;

/** Mesh component of the hat this pawn is wearing */
var() UDKSkeletalMeshComponent HatMesh;
/** SkeletalMesh that will be asigned to SkeletalMesh of HatMesh component */
// var() SkeletalMesh HatSkelMesh;

event PostBeginPlay()
{
	super.PostBeginPlay();
	AttachHat();
}

/** Sets correct mesh for hts Mesh comp and attaches it to character mesh */
function AttachHat()
{
	// HatMesh.SetSkeletalMesh(HatSkelMesh);
	CharacterMesh.AttachComponentToSocket(HatMesh, 'HatSocket');
}

DefaultProperties
{
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
}