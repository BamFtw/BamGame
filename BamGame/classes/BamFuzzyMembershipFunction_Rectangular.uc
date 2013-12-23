class BamFuzzyMembershipFunction_Rectangular extends BamFuzzyMembershipFunction;

var(BamFuzzyMembershipFunction) float A;
var(BamFuzzyMembershipFunction) float B;

function float GetMembershipLevel(int value)
{
	if( !(A <= B) )
	{
		`trace("Wrong parameters for rectangular function (A=" $ A $ ", B=" $ B  $ ")", `red);
	}

	if( value >= A && value <= B )
	{
		return 1;
	}

	return 0;
}

DefaultProperties
{
	FunctionType="Rectangular"
}