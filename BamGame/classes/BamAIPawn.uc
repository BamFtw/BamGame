class BamAIPawn extends BamPawn;

/** Stats that can be modified via UpdateStat and UpdateStats functions */
enum BamPawnStat
{
	BPS_GroundSpeed<DisplayName=Ground Speed>,
	BPS_WeaponSpread<DisplayName=Weapon Spread>,
	BPS_Awareness<DisplayName=Awareness>,
	BPS_DamageTakenMultiplier<DisplayName=Damage Taken Multiplier>,
	BPS_MAX
};

/** Reference to BamAIController */
var BamAIController BController;

/** Amount of spread that will be added to weapon */
var(Stats) float WeaponSpread;

/** Affects reaction time, peripheral vision and such */
var(Stats) float Awareness;

/** Multiplier of damage taken by pawn */
var(Stats) float DamageTakenMultiplier;

/** Actor responsible for informing controller about projectiles passing by */
var BamActor_ProjectileCatcher ProjectileCatcher;

/** Percent of default GroundSpeed that should be used */
var float GroundSpeedPct;

simulated function Rotator GetAdjustedAimFor(Weapon W, vector StartFireLoc)
{
	local Rotator rot;

	rot.Yaw = Rotation.Yaw;
	rot.Pitch = BController.ViewPitch;

	return rot;
}

function float GetViewPitch()
{
	return BController.ViewPitch;
}

/**  */
event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	AdjustPeripheralVision();

	// to prevent bouncing
	Velocity.Z = 0;

	if( BController != none && BController.Team != none )
	{
		DrawDebugCylinder(Location + vect(0, 0, 1) * GetCollisionHeight(), Location + vect(0, 0, 6) * GetCollisionHeight(), 10, 24, BController.Team.TeamColor.R, BController.Team.TeamColor.G, BController.Team.TeamColor.B, false);
	}
}

/** Sets PeripheralVision depending on Awareness */
function AdjustPeripheralVision()
{
	local float originalPeripheralVision;
	originalPeripheralVision = BamAIPawn(ObjectArchetype) == none ? default.PeripheralVision : BamAIPawn(ObjectArchetype).PeripheralVision;
	PeripheralVision = FClamp(1 - ((1 - originalPeripheralVision) * Awareness), 0, 1);	
}

/**
 * Returns default value of stat, 0 if index is incorrect
 * @param stat stat index (BamPawnStat enum)
 */
function float GetDefaultStatValue(BamPawnStat stat)
{
	local BamAIPawn arch;

	arch = BamAIPawn(ObjectArchetype);

	switch(stat)
	{
		case BPS_GroundSpeed:
			return (arch == none ? default.GroundSpeed : arch.GroundSpeed) * GroundSpeedPct;
			break;
		case BPS_WeaponSpread:
			return arch == none ? default.WeaponSpread : arch.WeaponSpread;
			break;
		case BPS_Awareness:
			return arch == none ? default.Awareness : arch.Awareness;
			break;
		case BPS_DamageTakenMultiplier:
			return arch == none ? default.DamageTakenMultiplier : arch.DamageTakenMultiplier;
			break;
		default:
			return 0;
	}
}

/**
 * Updates stat
 * @param stat stat index (BamPawnStat enum)
 * @param value value that will be added to default stat value
 */
function UpdateStat(BamPawnStat stat, float value)
{
	switch(stat)
	{
		case BPS_GroundSpeed:
			GroundSpeed = GetDefaultStatValue(stat) + value;
			break;
		case BPS_WeaponSpread:
			WeaponSpread = GetDefaultStatValue(stat) + value;
			break;
		case BPS_Awareness:
			Awareness = GetDefaultStatValue(stat) + value;;
			break;
		case BPS_DamageTakenMultiplier:
			DamageTakenMultiplier = GetDefaultStatValue(stat) + value;;
			break;
		default:
			return;
	}
}

/**
 * Updates stats of this pawn
 * @param values indexes of this array should corespond to BamPawnStat enum
 */
function UpdateStats(array<float> values)
{
	local int q;

	for(q = 0; q < values.Length; ++q)
	{
		UpdateStat(BamPAwnStat(q), values[q]);
	}
}

/** Sets ground speed multiplier */
function SetGroundSpeedPct(float pct)
{
	GroundSpeedPct = FMax(0, pct);
}




/** Sets reference to BamAIController */
function PossessedBy(Controller C, bool bVehicleTransition)
{
	super.PossessedBy(C, bVehicleTransition);
	BController = BamAIController(C);
}

/** Spawns default controller */
event PostBeginPlay()
{
	super.PostBeginPlay();

	if( Controller == none )
	{
		SpawnDefaultController();
	}

	ProjectileCatcher = Spawn(class'BamActor_ProjectileCatcher', self, , Location, Rotation, , true);
	
	if( ProjectileCatcher != none )
	{
		Attach(ProjectileCatcher);
	}
}

/** Changes taken damage depending on DamageTakenMultiplier, informs controller about taken damage */
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// modify damage by this pawns DamageTakenMultiplier
	Damage *= DamageTakenMultiplier;

	// modify damage value by GameIntensity
	if( GetALocalPlayerController().Pawn != self && BController != none )
	{
		// check if player team
		if( BController.Team == Game.PlayerTeam )
		{
			Damage *= Game.GameIntensity.GetParamValue(BGIP_DamageTakenMultiplier_Friendly);
		}
		// check if hostile team
		else if( Game.PlayerTeam.IsTeamHostile(BController.Team) )
		{
			Damage *= Game.GameIntensity.GetParamValue(BGIP_DamageTakenMultiplier_Hostile);
		}
		// not friendly nor friendly, must be neutral
		else
		{
			Damage *= Game.GameIntensity.GetParamValue(BGIP_DamageTakenMultiplier_Neutral);
		}
	}
	
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	
	if( IsAliveAndWell() && BController != none )
	{
		BController.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}
}


/** Returns whether pawn given as parameter is hostile */
function bool IsPawnHostile(Pawn pwn)
{
	return BController.IsPawnHostile(pwn);
}


State Dying
{
	ignores TakeDamage;

	event BeginState(Name PreviousStateName)
	{
		if( ProjectileCatcher != none )
		{
			ProjectileCatcher.Destroy();
		}

		if( Controller != none )
		{
			Controller.Destroy();
		}

		super.BeginState(PreviousStateName);
	}
}



defaultproperties
{
	ControllerClass=class'BamAIController'
	Physics=PHYS_Falling
	CollisionType=COLLIDE_BlockAllButWeapons

	WeaponSpread=0.0
	Awareness=1.0
	DamageTakenMultiplier=1.0

	GroundSpeedPct=1.0
}