class BamFuzzyMembershipFunction extends Object
	editinlinenew
	abstract
	hidecategories(Object);

/** Name of the function type for easy idetification in editor */
var(BamFuzzyMembershipFunction) editoronly editconst string FunctionType;

/** 
 * Returns level of membership of given value to this function
 * @param value - value that membership level will be returned 
 */
function float GetMembershipLevel(int value)
{
	return 0;
}

DefaultProperties
{
	FunctionType="err"
}