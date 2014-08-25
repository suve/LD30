unit cameraunit;

{$INCLUDE defines.inc}

interface
   uses enums;

Var
   Camera : TPoint = (X:0.0; Y:0.0);
   CamMove : Array[TDir] of Boolean = (False,False,False,False);

Const
   ZOOM_KEYBOARD = FALSE; ZOOM_MOUSE = TRUE;

Procedure CameraZoom(Const Change:sInt;Const Mouse:Boolean);
Procedure MoveCamera();


implementation
   uses Globals;

Procedure CameraZoom(Const Change:sInt;Const Mouse:Boolean);
   Var CtrX, CtrY, NewScaleFactor : Double;
       NewScale : sInt;
   begin
      NewScale := CamScale + Change;
      If (NewScale <  1) then NewScale :=  1 else
      If (NewScale > 10) then NewScale := 10;
      
      If (NewScale = CamScale) then Exit();
      
      NewScaleFactor := (11 - NewScale);
      
      If (Not Mouse) then begin
         CtrX := Camera.X + (Screen^.W / 2) * CamScaleFactor;
         CtrY := Camera.Y + (Screen^.H / 2) * CamScaleFactor;
         
         Camera.X := CtrX - (Screen^.W / 2) * NewScaleFactor;
         Camera.Y := CtrY - (Screen^.H / 2) * NewScaleFactor
      end else begin
         CtrX := Camera.X + mX * CamScaleFactor;
         CtrY := Camera.Y + mY * CamScaleFactor;
         
         Camera.X := CtrX - mX * NewScaleFactor;
         Camera.Y := CtrY - mY * NewScaleFactor
      end;
      
      CamScaleFactor := NewScaleFactor;
      CamScale := NewScale
   end;

Procedure MoveCamera();
   Var XMove, YMove : sInt;
   begin
      XMove := 0; YMove := 0;
      
      If (CamMove[DIR_UP]) then YMove -= 1;
      If (CamMove[DIR_RI]) then XMove += 1;
      If (CamMove[DIR_DO]) then YMove += 1;
      If (CamMove[DIR_LE]) then XMove -= 1;
      
      Camera.X += XMove * CamScaleFactor * CAMERA_SPEED * dT;
      Camera.Y += YMove * CamScaleFactor * CAMERA_SPEED * dT;
   end;


end.
