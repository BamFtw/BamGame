class BamActor_POI extends BamActor
	placeable;

var() float MinWaitTime;

var() float MaxWaitTime;

DefaultProperties
{
	bStatic=true
	bNoDelete=true
	
	Begin Object Name=Sprite
		Sprite=Texture2D'bam_hud_icons.POI'
	End Object

	MinWaitTime=2.5
	MaxWaitTime=5.0
}