class BamNeed_Tiredness extends BamNeed;

DefaultProperties
{
	NeedName="Tiredness"
	DecayRate=0.5

	Begin Object name=MemFunc_VeryLow
		A=-100
		B=-100
		C=20
		D=30
	End Object
	
	Begin Object class=BamFuzzyMembershipFunction_Trapezoidal name=MemFunc_Low
		A=10
		B=40
		C=50
		D=60
	End Object

	Begin Object name=MemFunc_Medium
		A=50
		B=60
		C=80
	End Object

	Begin Object name=MemFunc_High
		A=70
		B=80
		C=90
	End Object

	Begin Object class=BamFuzzyMembershipFunction_Trapezoidal name=MemFunc_VeryHigh
		A=80
		B=100
		C=1000
		D=1000
	End Object
}