class BamActor_ProjectileCatcher extends BamActor;


struct CaughtProjectileData
{
	/** Time projectile was caught */
	var float CatchTime;
	/** Caught proejctile */
	var Projectile Projectile;
};

/** List of projectiles that are already caught */
var array<CaughtProjectileData> CaughtProjectiles;

/** Reference to Owner */
var BamAIPawn BPawn;

/** Sets collision type, initializes CaughtProjectiles list cleanup timer and reference to Owner */
event PostBeginPlay()
{
	super.PostBeginPlay();

	SetCollisionType(COLLIDE_TouchWeapons);
	SetTimer(1.0, true, nameof(CaughtProjectilesCleanup));

	BPawn = BamAIPawn(Owner);
}

/** Removes old projectiles from CaughtProjectiles list */
function CaughtProjectilesCleanup()
{
	local int q;

	for(q = 0; q < CaughtProjectiles.Length; ++q)
	{
		if( `TimeSince(CaughtProjectiles[q].CatchTime) >= 2.0 )
		{
			CaughtProjectiles.Remove(q--, 1);
		}
	}
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local Projectile pj;
	local BamPawn PjOwner;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	pj = Projectile(Other);

	// make sure touched actor is projectile and Pawn is not in combat
	if( pj == none || BPawn == none || BPawn.BController == none || BPawn.BController.IsInCombat() )
	{
		return;
	}

	PjOwner = BamPawn(FindPawnOwner(pj));

	// make sure owner of projectile is hostile and projectile wasn't already caught
	if( BPawn.BController.IsPawnHostile(PjOwner) && !IsProjectileCaught(Projectile(Other)) )
	{
		ProjectileCaught(pj, PjOwner);
	}
}

/** Returns whether projectile is in the  */
function bool IsProjectileCaught(Projectile pj)
{
	local int q;

	for(q = 0; q < CaughtProjectiles.Length; ++q)
	{
		if( CaughtProjectiles[q].Projectile == pj )
		{
			return true;
		}
	}

	return false;
}

/** Returns Pawn owner of the projectile */
function Pawn FindPawnOwner(Projectile pj)
{
	local array<Actor> PrevActors;
	local Actor currentActor;
	local int q;

	currentActor = pj;

	while( true )
	{
		if( ++q > 20 || currentActor.Owner == none || PrevActors.Find(currentActor.Owner) != INDEX_NONE )
		{
			`trace("failed to get owner pawn", `red);
			return none;
		}

		if( Pawn(currentActor.Owner) != none )
		{
			return Pawn(currentActor.Owner);
		}
		
		PrevActors.AddItem(currentActor);
		currentActor = currentActor.Owner;
	}
}

/** Called when this actor touches new projectile */
function ProjectileCaught(Projectile pj, BamPawn PjOnwer)
{
	local CaughtProjectileData data;

	if( BPawn == none || BPawn.BController == none || pj == none )
	{
		return;
	}

	data.CatchTime = WorldInfo.TimeSeconds;
	data.Projectile = pj;

	CaughtProjectiles.AddItem(data);

	BPawn.BController.ProjectileCaught(pj, PjOnwer);
}




DefaultProperties
{
	Begin Object class=StaticMeshComponent name=BulletCatcherCollider
		StaticMesh=StaticMesh'bam_ch_bullet_catcher.bullet_catcher'
		bOwnerNoSee=true
		bOnlyOwnerSee=true
		CollideActors=true
		BlockActors=false
		BlockZeroExtent=true
		BlockNonZeroExtent=false
		AlwaysCheckCollision=true
	End Object
	Components.Add(BulletCatcherCollider)
	CollisionComponent=BulletCatcherCollider

	CollisionType=COLLIDE_TouchWeapons
}