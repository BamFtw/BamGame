class BamProjectile extends UDKProjectile;

/** Rate at which Z axis of velocity will be adjusted */
var() float BulletDropRate;

/** Sound played when projectile hits world geometry */
var SoundCue GroundImpactSound;

/** Sound played when projectile hits Pawn */
var SoundCue CharacterImpactSound;

/**  */
event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if( BulletDropRate != 0 )
	{
		Velocity.Z -= DeltaTime * BulletDropRate;
	}
}

function Init(Vector Direction)
{
	super.Init(Direction);
	SetRotation(Rotator(Direction));
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local TraceHitInfo HitInfo;
	local Vector traceHitLocation, traceHitNormal;

	// if( Pawn(Other) != none )
	// {
	// 	DrawDebugBox(HitLocation, vect(2,2,2), 255, 0, 0, true);
	// }
	// else
	// {
	// 	DrawDebugBox(HitLocation, vect(2,2,2), 0, 255, 0, true);
	// }
	
	if (Other != Instigator)
	{
		if (!Other.bStatic && DamageRadius == 0.0)
		{
			SpawnHitEffect(HitNormal);

			if( Pawn(Other) != none )
			{
				// get hit info
				Trace(traceHitLocation, traceHitNormal, Location + Vector(Rotation) * 20.0, Location - Vector(Rotation) * 20.0, true, , HitInfo, TRACEFLAG_Bullet);
				DrawDebugLine(Location - Vector(Rotation) * 20.0,  Location + Vector(Rotation) * 20.0, 255, 255, 255, true);

				if( CharacterImpactSound != none )
				{
					PlaySound(CharacterImpactSound, , , , HitLocation);
				}
			}
			else
			{
				if( GroundImpactSound != none )
				{
					PlaySound(GroundImpactSound, , , , HitLocation);
				}
			}

			Other.TakeDamage(Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType, HitInfo, self);
		}
		Explode(HitLocation, HitNormal);
	}
}

simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	super.HitWall(HitNormal, Wall, WallComp);
	SpawnHitEffect(HitNormal);

	// DrawDebugBox(Location, vect(2,2,2), 0, 0, 255, true);

	if( GroundImpactSound != none )
	{
		PlaySound(GroundImpactSound);
	}
}

/** Spawns sound and particle effect at hit location */
function SpawnHitEffect(Vector Normal)
{
	local Vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local Actor HitActor;
	local ParticleSystem PS;

	HitActor = Trace(HitLocation, HitNormal, Location + (Normal * -4.0), Location + (Normal * 4.0), , , HitInfo, TRACEFLAG_Bullet);

	if( HitLocation != vect(0, 0, 0) )
	{
		PS = (Pawn(HitActor) != none ? ParticleSystem'bam_p_hitImpact_blood.PS.Blood' : ParticleSystem'bam_p_hitImpact_dirt.PS.Dirt');
		
		if( PS != none )
		{
			Class'WorldInfo'.static.GetWorldInfo().MyEmitterPool.SpawnEmitter(PS, HitLocation, Rotator(HitNormal));
		}
	}
}



DefaultProperties
{
	Begin Object class=StaticMeshComponent name=ProjectileMeshComp
		StaticMesh=StaticMesh'bam_wp_projectile_rifle.Mesh.RifleProjectile'
		Scale=1.9
	End Object
	Components.Add(ProjectileMeshComp)

	Begin Object class=ParticleSystemComponent name=TrailComp
		Template=ParticleSystem'VH_Manta.Effects.PS_Manta_Projectile'
		Scale3D=(X=0.35,Y=0.35,Z=0.35)
	End Object
	Components.Add(TrailComp)

	DamageRadius=0.0
	Damage=10
	Speed=6000.0
	MaxSpeed=6000.0

	BulletDropRate=24.0

	GroundImpactSound=SoundCue'bam_snd_HitImpacts.Cue.HitImpact_Ground'
	CharacterImpactSound=SoundCue'bam_snd_HitImpacts.Cue.HitImpact_Character'
}