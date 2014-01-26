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
	
	Begin Object class=BamFuzzyMembershipFunction_Trapezoidal name=MyMemFunc_Low
		A=10
		B=40
		C=50
		D=60
	End Object

	Begin Object class=BamFuzzyMembershipFunction_Trapezoidal name=MyMemFunc_Medium
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

	MembershipFunctions[BFL_VeryLow]=(Level=BFL_VeryLow,Function=MemFunc_VeryLow)
	MembershipFunctions[BFL_Low]=(Level=BFL_Low,Function=MyMemFunc_Low)
	MembershipFunctions[BFL_Medium]=(Level=BFL_Medium,Function=MyMemFunc_Medium)
	MembershipFunctions[BFL_High]=(Level=BFL_High,Function=MemFunc_High)
	MembershipFunctions[BFL_VeryHigh]=(Level=BFL_VeryHigh,Function=MemFunc_VeryHigh)
}