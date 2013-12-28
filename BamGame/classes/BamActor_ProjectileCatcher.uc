class BamActor_ProjectileCatcher extends BamActor;


struct CaughtProjectileData
{
	var float CatchTime;
	var Projectile Projectile;
};


var array<CaughtProjectileData> DetectedProjectiles;

var BamAIPawn BPawn;

event PostBeginPlay()
{
	super.PostBeginPlay();
	SetCollisionType(COLLIDE_TouchWeapons);
	SetTimer(1.0, true, nameof(DetectedProjectilesCleanup));

	BPawn = BamAIPawn(Owner);
}

function DetectedProjectilesCleanup()
{
	local int q;

	for(q = 0; q < DetectedProjectiles.Length; ++q)
	{
		if( `TimeSince(DetectedProjectiles[q].CatchTime) >= 2.0 )
		{
			DetectedProjectiles.Remove(q--, 1);
		}
	}
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local Projectile pj;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	if( !BPawn.BController.IsInCombat() )
	{
		return;
	}
	
	pj = Projectile(Other);

	if( pj != none && BPawn.BController.IsPawnHostile(FindPawnOwner(pj)) && !IsProjectileCought(Projectile(Other)) )
	{
		ProjectileCought(Projectile(Other));
	}
}

function bool IsProjectileCought(Projectile pj)
{
	local int q;

	for(q = 0; q < DetectedProjectiles.Length; ++q)
	{
		if( DetectedProjectiles[q].Projectile == pj )
		{
			return true;
		}
	}

	return false;
}

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

function ProjectileCought(Projectile pj)
{
	local CaughtProjectileData data;

	if( pj == none )
	{
		return;
	}

	data.CatchTime = WorldInfo.TimeSeconds;
	data.Projectile = pj;

	DetectedProjectiles.AddItem(data);


	BPawn.BController.ProjectileCaught(pj);
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