class BamNeed_Thirst extends BamNeed;


function float MF_VeryLow(float val)
{
	if( val <= 10.0 )
		return 1;

	return TriangleFunction(val, 10, 10, 30);
}

function float MF_Low(float val)
{
	return TrapezoidalFunction(val, 20, 30, 50, 60);
}

function float MF_Medium(float val)
{
	return TriangleFunction(val, 50, 60, 80);
}

function float MF_High(float val)
{
	return TrapezoidalFunction(val, 70, 80, 90, 100);
}

function float MF_VeryHigh(float val)
{
	if( val >= 100.0 )
		return 1;

	return TriangleFunction(val, 90, 100, 100);
}

DefaultProperties
{
	NeedName="Thirst"

	DecayRate=1.5
}