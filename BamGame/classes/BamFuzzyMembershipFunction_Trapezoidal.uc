class BamFuzzyMembershipFunction_Trapezoidal extends BamFuzzyMembershipFunction;

var(BamFuzzyMembershipFunction) float A;
var(BamFuzzyMembershipFunction) float B;
var(BamFuzzyMembershipFunction) float C;
var(BamFuzzyMembershipFunction) float D;

function float GetMembershipLevel(int value)
{
	if( !(A <= B && B <= C && C <= D) )
	{
		`trace("Wrong parameters for trapezoidal function (A=" $ A $ ", B=" $ B $ ", C=" $ C $ ", D=" $ D $ ")", `red);
	}

	if( value <= A || value >= D )
	{
		return 0;
	}

	if( value >= B && value <= C )
	{
		return 1;
	}

	if( value <= B )
	{
		return (value - A) / (B - A);
	}
	else
	{
		return (D - value) / (D - C);
	}
}

DefaultProperties
{
	FunctionType="Trapezoidal"
}