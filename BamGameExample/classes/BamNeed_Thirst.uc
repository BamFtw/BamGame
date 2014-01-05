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
	
	Begin Object name=MemFunc_Low
		A=20
		B=40
		C=60
	End Object

	Begin Object name=MemFunc_Medium
		A=50
		B=60
		C=70
		D=80
	End Object

	Begin Object name=MemFunc_High
		A=70
		B=90
		C=100
	End Object

	Begin Object name=MemFunc_VeryHigh
		A=90
		B=100
		C=1000
		D=1000
	End Object

	MembershipFunctions[BFL_VeryLow]=(Level=BFL_VeryLow,Function=MemFunc_VeryLow)
	MembershipFunctions[BFL_Low]=(Level=BFL_Low,Function=MemFunc_Low)
	MembershipFunctions[BFL_Medium]=(Level=BFL_Medium,Function=MemFunc_Medium)
	MembershipFunctions[BFL_High]=(Level=BFL_High,Function=MemFunc_High)
	MembershipFunctions[BFL_VeryHigh]=(Level=BFL_VeryHigh,Function=MemFunc_VeryHigh)
}