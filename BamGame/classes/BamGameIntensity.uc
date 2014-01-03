class BamGameIntensity extends Object;

enum BamGameIntensityParam
{
	BGIP_InvalidParam,
	BGIP_DamageTakenMultiplier_Player,
	BGIP_DamageTakenMultiplier_Friendly,
	BGIP_DamageTakenMultiplier_Neutral,
	BGIP_DamageTakenMultiplier_Hostile,
	BGIP_MaxEnemiesFiringAtPlayer,
	BGIP_AllowFriendlyFire,
	BGIP_MAX
};

/** List that stores values of the parameters from BamGameIntensityParam enum */
var() array<float> Params;

/** List of Pawns currently firing at player, if its length reaches 
 *	BGIP_MaxEnemiesFiringAtPlayer param value no more pawns should be able to fire at player */
var array<Pawn> PawnsFiringAtPlayer;

function Tick(float DeltaTime)
{
	local int q;
	
	// remove invalid Pawns from PawnsFiringAtPlayer list
	for(q = 0; q < PawnsFiringAtPlayer.Length; ++q)
	{
		if( PawnsFiringAtPlayer[q] == none || !PawnsFiringAtPlayer[q].IsAliveAndWell() )
		{
			PawnsFiringAtPlayer.Remove(q--, 1);
		}
	}
}

/** Returns whether it is possible to shoot at player at this time */
function bool CanFireAtPlayer()
{
	return (PawnsFiringAtPlayer.Length < GetParamValue(BGIP_MaxEnemiesFiringAtPlayer));
}

/** Adds Pawn given as parameter to PawnsFiringAtPlayer list */
function StartedFiringAtPlayer(Pawn pwn)
{
	if( pwn == none )
	{
		return;
	}

	PawnsFiringAtPlayer.AddItem(pwn);
}

/** Removes Pawn given as paramter from PawnsFiringAtPlayer list */
function StoppedFiringAtPlayer(Pawn pwn)
{
	PawnsFiringAtPlayer.RemoveItem(pwn);
}



/** Resets all parameters to their default values */
function Reset()
{
	if( ObjectArchetype != none )
	{
		Params = BamGameIntensity(ObjectArchetype).Params;
		return;
	}

	Params = default.Params;
}

/** 
 * Sets value of param
 * @param param - parameter to set
 * @param value - value to assign to given param
 */
function SetParam(BamGameIntensityParam param, float value)
{
	if( param <= BGIP_InvalidParam || param >= Params.Length )
	{
		`trace("param out of bounds :" @ int(param), `red);
		return;
	}

	Params[param] = value;
}

/** 
 * Returns value of param given as parameter
 * @param param - parameter which value should be returned
 * @return value of parameter or 0 if param is invalid
 */
function float GetParamValue(BamGameIntensityParam param)
{
	if( param <= BGIP_InvalidParam || param >= Params.Length )
	{
		`trace("param out of bounds :" @ int(param), `red);
		return 0;
	}

	return Params[param];
}

DefaultProperties
{
	Params[BGIP_DamageTakenMultiplier_Player]=0.5
	Params[BGIP_DamageTakenMultiplier_Friendly]=0.75
	Params[BGIP_DamageTakenMultiplier_Neutral]=1.0
	Params[BGIP_DamageTakenMultiplier_Hostile]=1.0
	Params[BGIP_MaxEnemiesFiringAtPlayer]=2
	Params[BGIP_AllowFriendlyFire]=0
}