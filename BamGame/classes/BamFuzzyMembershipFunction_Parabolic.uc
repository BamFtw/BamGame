class BamFuzzyMembershipFunction_Parabolic extends BamFuzzyMembershipFunction;

var(BamFuzzyMembershipFunction) float A;
var(BamFuzzyMembershipFunction) float B;

function float GetMembershipLevel(int value)
{
	local float x;

	if( !(A <= B) )
	{
		`trace("Wrong parameters for rectangular function (A=" $ A $ ", B=" $ B  $ ")", `red);
	}

	if( value <= A || value >= B )
	{
		return 0;
	}

	x = value / (B - A);

	return (x - 1) * -4 * x;
}

DefaultProperties
{
	FunctionType="Parabolic"
}