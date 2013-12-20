class BamNavMeshObstacle extends NavMeshObstacle;



/**
 * script accessible function that builds the bounding shape for the navmesh obstacle
 * Note: needs to return a CW wound convex shape!
 * @param shape - array of verts for cutting shape
 * @return TRUE if the shape creation was a success
 */
event bool GetObstacleBoudingShape(out array<vector> Shape)
{
	local float Scale;
	local vector Offset;
	Scale = DrawScale;


	// Clockwise!
	// top right corner
	Offset.X = Scale * DrawScale3D.X;
	Offset.Y = Scale * DrawScale3D.Y;
	Shape.AddItem(Location + (Offset >> Rotation));
	// bottom right corner
	Offset.X = -Scale * DrawScale3D.X;
	Offset.Y = Scale * DrawScale3D.Y;
	Shape.AddItem(Location + (Offset >> Rotation) );
	// bottom left corner
	Offset.X = -Scale * DrawScale3D.X;
	Offset.Y = -Scale * DrawScale3D.Y;
	Shape.AddItem(Location + (Offset >> Rotation) );
	// top left corner
	Offset.X = Scale * DrawScale3D.X;
	Offset.Y = -Scale * DrawScale3D.Y;
	Shape.AddItem(Location + (Offset >> Rotation) );

	`log("shape :" @ Shape[0] @ Shape[1] @ Shape[2] @ Shape[3]);

	return TRUE;
}

DefaultProperties
{
	DrawScale=1.0
}