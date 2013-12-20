class BamActor_Cover_Crouching extends BamActor_Cover;



defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'bam_hud_icons.Cover.CoverIcon_crouching'
	End Object

	Begin Object name=MyCylinderComponent
		CollisionHeight=20.0
	End Object

	

	bLeanUp=true
	DesirabilityModifier=0.8
}