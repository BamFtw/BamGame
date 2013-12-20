class BamActor_SpawnLocation extends BamActor
	placeable;

DefaultProperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'bam_hud_icons.SpawnLocation'
	End Object

	Begin Object Name=MyCylinderComponent
		CollisionRadius=20.0
		CollisionHeight=45.0
		bAlwaysRenderIfSelected=true
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		CollideActors=false
	End Object
	Components.Add(MyCylinderComponent)
	CollisionComponent=MyCylinderComponent
}