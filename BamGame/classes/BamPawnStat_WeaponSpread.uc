class BamPawnStat_WeaponSpread extends BamPawnStat;

/** 
 * Returns default value of Pawns stat
 * @param pwn - deault value of this Pawns stat will be returned
 * @return default value of stat 
 */
static function float GetDefaultValue(BamPawn pwn)
{
	return pwn.ObjectArchetype == none ? pwn.default.WeaponSpread : BamPawn(pwn.ObjectArchetype).WeaponSpread;
}

/**
 * Sets Pawns stat to default value + value given as param
 * @param pwn - pawn that should have its stats set
 * @param value - value of stat that should be added to its default value
 */
static function SetStat(BamPawn pwn, float value)
{
	pwn.WeaponSpread = GetDefaultValue(pwn) + value;
}