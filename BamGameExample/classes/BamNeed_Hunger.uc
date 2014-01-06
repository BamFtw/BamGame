class BamNeed_Hunger extends BamNeed;

DefaultProperties
{
	NeedName="Hunger"
	DecayRate=1.0

	Begin Object name=MemFunc_VeryLow
		A=-100
		B=-100
		C=0
		D=20
	End Object
	
	Begin Object name=MemFunc_Low
		A=10
		B=30
		C=40
	End Object

	Begin Object class=BamFuzzyMembershipFunction_Trapezoidal name=MemFunc_Medium
		A=30
		B=50
		C=60
		D=80
	End Object

	Begin Object name=MemFunc_High
		A=60
		B=80
		C=90
	End Object

	Begin Object name=MemFunc_VeryHigh
		A=80
		B=100
		C=1000
		D=1000
	End Object
}