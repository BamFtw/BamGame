class BamSeqAction_SetGameIntensity extends BamSeqAction;

struct BamGIParamValuePair
{
	var() BamGameIntensityParam Parameter;
	var() float Value;
};

/** List of GI params that will be set when this SeqAction is activated */
var() array<BamGIParamValuePair> Params;

/** Sets GameIntensity parameters specified in Params list */
event Activated()
{
	local BamGameInfo bgi;
	local int q;

	bgi = BamGameInfo(class'WorldInfo'.static.GetWorldInfo().Game);

	if( bgi == none )
	{
		`trace("GameInfo object is not BamGameInfo", `red);
		return;
	}

	for(q = 0; q < Params.Length; ++q)
	{
		bgi.GameIntensity.SetParam(Params[q].Parameter, Params[q].Value);
	}
}

defaultproperties
{
	ObjCategory="Bam.Gameplay.GameIntensity"
	ObjName="Set GI"

	VariableLinks.Empty
}