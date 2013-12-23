class BamFuzzyMembershipFunction_Triangular extends BamFuzzyMembershipFunction;

var(BamFuzzyMembershipFunction) float A;
var(BamFuzzyMembershipFunction) float B;
var(BamFuzzyMembershipFunction) float C;

function float GetMembershipLevel(int value)
{
	if( !(A <= B && B <= C) )
	{
		`trace("Wrong parameters for triangular function (A=" $ A $ ", B=" $ B $ ", C=" $ C $ ")", `red);
	}

	if( value <= A || value >= C )
	{
		return 0;
	}

	if( value < B )
	{
		return (value - A) / (B - A);
	}

	if( value > B )
	{
		return (C - value) / (C - B);
	}
}

DefaultProperties
{
	FunctionType="Triangular"
}