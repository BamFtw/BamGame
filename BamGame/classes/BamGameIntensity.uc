class BamGameIntensity extends Object;

struct BamGIParamValue
{
	var() class<BamGIParam> Param;
	var() float Value;
};

/** List that stores values of the parameters */
var() array<BamGIParamValue> Params;

/** List of Pawns currently firing at player, if its length reaches MaxEnemiesFiringAtPlayer
 *	param value no more pawns should be able to fire at player */
var array<Pawn> PawnsFiringAtPlayer;

var int TempBlockedFiringSlots;

var array<float> BlockedFiringSlots;

function Tick(float DeltaTime)
{
	local int q;
	
	for(q = 0; q < BlockedFiringSlots.Length; ++q)
	{
		BlockedFiringSlots[q] -= DeltaTime;
		if( BlockedFiringSlots[q] <= 0 )
		{
			BlockedFiringSlots.Remove(q, 1);
		}
	}

	// remove invalid Pawns from PawnsFiringAtPlayer list
	for(q = 0; q < PawnsFiringAtPlayer.Length; ++q)
	{
		if( PawnsFiringAtPlayer[q] == none || !PawnsFiringAtPlayer[q].IsAliveAndWell() )
		{
			PawnsFiringAtPlayer.Remove(q--, 1);
		}
	}
}

function TempBlockFiringSlot()
{
	++TempBlockedFiringSlots;
}

function TempUnblockFiringSlot()
{
	--TempBlockedFiringSlots;
}

function BlockFiringSlot(float duration)
{
	if( duration > 0 )
	{
		BlockedFiringSlots.AddItem(duration);
	}
}

/** Returns whether it is possible to shoot at player at this time */
function bool CanFireAtPlayer()
{
	return (PawnsFiringAtPlayer.Length + TempBlockedFiringSlots + BlockedFiringSlots.Length < GetParamValue(class'BamGIParam_MaxEnemiesFiringAtPlayer'));
}

/** Adds Pawn given as parameter to PawnsFiringAtPlayer list */
function StartedFiringAtPlayer(Pawn pwn)
{
	if( pwn == none || PawnsFiringAtPlayer.Find(pwn) != INDEX_NONE )
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
function SetParam(class<BamGIParam> param, float value)
{
	local int idx;

	if( param == none )
	{
		`trace("Wrong param", `red);
		return;
	}

	idx = GetParamIndex(param);

	if( idx == INDEX_NONE )
	{
		Params.AddItem(CreateParamValue(param, value));
	}
	else
	{
		Params[idx].Value = value;
	}
}


/** 
 * Returns value of param given as parameter
 * @param param - parameter which value should be returned
 * @return value of parameter or 0 if param is invalid
 */
function float GetParamValue(class<BamGIParam> param)
{
	local int idx;

	idx = GetParamIndex(param);

	if( param == none || idx == INDEX_NONE )
	{
		`trace("Wrong param", `red);
		return 0;
	}

	return Params[idx].Value;
}

/**
 * Returns index in the Params list of the param given as parameter
 * @param param - 
 * @return index of the param in the Params list, INDEX_NONE if not found
 */
function int GetParamIndex(class<BamGIParam> param)
{
	local int q;

	if( param != none && Params.Length > 0 )
	{
		for(q = 0; q < Params.Length; ++q)
		{
			if( Params[q].Param == param )
			{
				return q;
			}
		}
	}

	return INDEX_NONE;
}

/**
 * Creates and returns struct with specified values
 * @param param -
 * @param value - 
 * @return struct filled with given data
 */
function BamGIParamValue CreateParamValue(class<BamGIParam> param, float value)
{
	local BamGIParamValue val;

	val.Param = param;
	val.Value = value;

	return val;
}

DefaultProperties
{
	Params.Add((Param=class'BamGIParam_DamageTakenMultiplier_Player',Value=1.0))
	Params.Add((Param=class'BamGIParam_DamageTakenMultiplier_Friendly',Value=1.0))
	Params.Add((Param=class'BamGIParam_DamageTakenMultiplier_Neutral',Value=1.0))
	Params.Add((Param=class'BamGIParam_DamageTakenMultiplier_Hostile',Value=1.0))
	Params.Add((Param=class'BamGIParam_MaxEnemiesFiringAtPlayer',Value=2.0))
	Params.Add((Param=class'BamGIParam_AllowFriendlyFire',Value=0.0))
}