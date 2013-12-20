class BamCamera extends Camera;

function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local vector		Loc, Pos, HitLocation, HitNormal;
	local rotator		Rot;
	local Actor			HitActor;
	local CameraActor	CamActor;
	local bool			bDoNotApplyModifiers;
	local TPOV			OrigPOV;
	local Pawn          TPawn;

	// Don't update outgoing viewtarget during an interpolation 
	if( PendingViewTarget.Target != None && OutVT == ViewTarget && BlendParams.bLockOutgoing )
	{
		return;
	}

	// store previous POV, in case we need it later
	OrigPOV = OutVT.POV;

	// Default FOV on viewtarget
	OutVT.POV.FOV = DefaultFOV;

	// Viewing through a camera actor.
	CamActor = CameraActor(OutVT.Target);
	if( CamActor != None )
	{
		CamActor.GetCameraView(DeltaTime, OutVT.POV);

		// Grab aspect ratio from the CameraActor.
		bConstrainAspectRatio	= bConstrainAspectRatio || CamActor.bConstrainAspectRatio;
		OutVT.AspectRatio		= CamActor.AspectRatio;

		// See if the CameraActor wants to override the PostProcess settings used.
		CamOverridePostProcessAlpha = CamActor.CamOverridePostProcessAlpha;
		CamPostProcessSettings = CamActor.CamOverridePostProcess;
	}
	else
	{
		TPawn = Pawn(OutVT.Target);
		// Give Pawn Viewtarget a chance to dictate the camera position.
		// If Pawn doesn't override the camera view, then we proceed with our own defaults
		if( TPawn == None || !TPawn.CalcCamera(DeltaTime, OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV) )
		{
			// don't apply modifiers when using these debug camera modes.
			bDoNotApplyModifiers = TRUE;

			switch( CameraStyle )
			{
				case 'Fixed'		:	// do not update, keep previous camera position by restoring
										// saved POV, in case CalcCamera changes it but still returns false
										OutVT.POV = OrigPOV;
										break;

				case 'ThirdPerson'	: // Simple third person view implementation
				case 'FreeCam'		:
				case 'FreeCam_Default':
										Loc = OutVT.Target.Location;
										Rot = OutVT.Target.Rotation;

										// Take into account Mesh Translation so it takes into account the PostProcessing we do there.
										if ((TPawn != None) && (TPawn.Mesh != None))
										{
											Loc += (TPawn.Mesh.Translation - TPawn.default.Mesh.Translation) >> OutVT.Target.Rotation;
										}

										//OutVT.Target.GetActorEyesViewPoint(Loc, Rot);
										if( CameraStyle == 'FreeCam' || CameraStyle == 'FreeCam_Default' )
										{
											Rot = PCOwner.Rotation;
										}
										Loc += FreeCamOffset >> Rot;

										Pos = Loc - Vector(Rot) * FreeCamDistance;
										// @fixme, respect BlockingVolume.bBlockCamera=false
										HitActor = Trace(HitLocation, HitNormal, Pos, Loc, FALSE, vect(12,12,12));
										OutVT.POV.Location = (HitActor == None) ? Pos : HitLocation;
										OutVT.POV.Rotation = Rot;
										break;

				case 'FirstPerson'	: // Simple first person, view through viewtarget's 'eyes'
				default				:	OutVT.Target.GetActorEyesViewPoint(OutVT.POV.Location, OutVT.POV.Rotation);
										// Take into account Mesh Translation so it takes into account the PostProcessing we do there.
										if ((TPawn != None) && (TPawn.Mesh != None))
										{
											OutVT.POV.Location += (TPawn.Mesh.Translation - TPawn.default.Mesh.Translation) >> OutVT.Target.Rotation;
										}
										break;

			}
		}
	}

	if( !bDoNotApplyModifiers )
	{
		// Apply camera modifiers at the end (view shakes for example)
		ApplyCameraModifiers(DeltaTime, OutVT.POV);
	}
}