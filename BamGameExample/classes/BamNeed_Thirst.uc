class BamNeed_Thirst extends BamNeed;

DefaultProperties
{
	NeedName="Thirst"

	DecayRate=1.5

	Begin Object name=MemFunc_VeryLow
		A=-100
		B=-100
		C=10
		D=30
	End Object
	
	Begin Object class=BamFuzzyMembershipFunction_Trapezoidal name=MemFunc_Low
		A=10
		B=40
		C=50
		D=60
	End Object

	Begin Object class=BamFuzzyMembershipFunction_Trapezoidal name=MemFunc_Medium
		A=50
		B=70
		C=80
		D=90
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