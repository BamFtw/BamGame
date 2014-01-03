class BamSeqAction_ResetGameIntensity extends BamSeqAction;

/** Resets GameIntensity paremeters to their default values */
event Activated()
{
	local BamGameInfo bgi;

	bgi = BamGameInfo(class'WorldInfo'.static.GetWorldInfo().Game);

	if( bgi == none )
	{
		`trace("GameInfo object is not BamGameInfo", `red);
		return;
	}

	bgi.GameIntensity.Reset();
}

defaultproperties
{
	ObjCategory="Bam.Gameplay.GameIntensity"
	ObjName="Reset GI"

	VariableLinks.Empty
}