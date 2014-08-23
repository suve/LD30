program ld30;

{$INCLUDE defines.inc}

uses
   SysUtils, SDL, SDL_Image, SDL_Mixer, Sour, GL,
   Globals;

Var
   Traveller : Double;

Procedure AdvanceTime();
   begin
      Time := SDL_GetTicks() - Ticks;
      If (Time = 0) then begin
         SDL_Delay(1);
         Time := SDL_GetTicks() - Ticks
      end;
      
      Ticks := Ticks + Time;
      dT := Time / SDL_TICKS_PER_SECOND
   end;

Const
   ZOOM_KEYBOARD = FALSE; ZOOM_MOUSE = TRUE;

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

Procedure ProcessEvents();
   begin
      While (SDL_PollEvent(@Ev) > 0) do
         Case (Ev.Type_) of
         
            SDL_QuitEv: Terminate := True;
            
            SDL_KeyDown:
               Case (Ev.Key.Keysym.Sym) of
                  SDLK_ESCAPE: Terminate := True;
                  SDLK_MINUS: CameraZoom(-1, ZOOM_KEYBOARD);
                  SDLK_EQUALS: CameraZoom(+1, ZOOM_KEYBOARD);
                  
                  SDLK_UP: CamMove[DIR_UP] := True;
                  SDLK_RI: CamMove[DIR_RI] := True;
                  SDLK_DO: CamMove[DIR_DO] := True;
                  SDLK_LE: CamMove[DIR_LE] := True;
               end;
            
            SDL_KeyUp:
               Case (Ev.Key.Keysym.Sym) of
                  SDLK_UP: CamMove[DIR_UP] := False;
                  SDLK_RI: CamMove[DIR_RI] := False;
                  SDLK_DO: CamMove[DIR_DO] := False;
                  SDLK_LE: CamMove[DIR_LE] := False;
               end;
            
            SDL_MouseMotion: begin
               mX := Ev.Motion.X;
               mY := Ev.Motion.Y;
            end;
            
            SDL_MouseButtonDown: begin
               mX := Ev.Button.X;
               mY := Ev.Button.Y;
               
               Case (Ev.Button.Button) of
                  SDL_BUTTON_WHEELDOWN: CameraZoom(-1, ZOOM_MOUSE);
                  SDL_BUTTON_WHEELUP: CameraZoom(+1, ZOOM_MOUSE);
               end;
            end;
            
         end;
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
      
      Sour.SetVisibleArea(
         Trunc(Camera.X), Trunc(Camera.Y),
         Trunc(800 * CamScaleFactor), Trunc(600 * CamScaleFactor)
      )
   end;

Procedure DrawFrame();
   Var Pl, Points, Pt : sInt;
       Angle, Circumference : Double;
       Trav : TPoint;
   begin
   Sour.BeginFrame();
      
      Sour.TexDisable();
      For Pl := 0 to 1 do begin
         Circumference := Planet[Pl].R * 2 * Pi;
         Points := Trunc(Circumference / PLANET_GRANULARITY);
         
         glBegin(GL_LINE_LOOP);
            glColor4ub(255,255,255,255);
            For Pt := 0 to (Points-1) do begin
               Angle := 2 * Pi * Pt / Points;
               glVertex2f(
                  Planet[Pl].X + Cos(Angle)*Planet[Pl].R,
                  Planet[Pl].Y + Sin(Angle)*Planet[Pl].R
               );
            end;
         glEnd();
      end;
      
      glBegin(GL_LINES);
         glColor4ub(255,0,0,255);
         
         glVertex2f(Planet[0].X,Planet[0].Y);
         glVertex2f(ptA.X,ptA.Y);
         
         glVertex2f(Planet[1].X,Planet[1].Y);
         glVertex2f(ptA.X,ptA.Y);
         
         glColor4ub(255,255,0,255);
         glVertex2f(Planet[0].X,Planet[0].Y);
         glVertex2f(ptB.X,ptB.Y);
         
         glVertex2f(Planet[1].X,Planet[1].Y);
         glVertex2f(ptB.X,ptB.Y);
         
         glColor4ub(0,128,255,255);
         glVertex2f(Planet[0].X,Planet[0].Y);
         glVertex2f(ptC.X,ptC.Y);
         
         glColor4ub(0,255,255,255);
         glVertex2f(Planet[1].X,Planet[1].Y);
         glVertex2f(ptC.X,ptC.Y);
         
         glColor4ub(0,0,255,255);
         glVertex2f(ptC.X + Cos(ptCAngle + Pi/2) * 5000, ptC.Y + Sin(ptCAngle + Pi/2) * 5000);
         glVertex2f(ptC.X - Cos(ptCAngle + Pi/2) * 5000, ptC.Y - Sin(ptCAngle + Pi/2) * 5000);
         
      glEnd();
      
      CH_to_XY(Traveller,0,@Trav);
      glBegin(GL_QUADS);
         
         glColor4ub(255,0,0,255);
         
         glVertex2f(Trav.X - (10 * CamScaleFactor), Trav.Y - (10 * CamScaleFactor));
         glVertex2f(Trav.X - (10 * CamScaleFactor), Trav.Y + (10 * CamScaleFactor));
         glVertex2f(Trav.X + (10 * CamScaleFactor), Trav.Y + (10 * CamScaleFactor));
         glVertex2f(Trav.X + (10 * CamScaleFactor), Trav.Y - (10 * CamScaleFactor));
         
      glEnd();
      
   Sour.FinishFrame();
   end;

Procedure CountFrames();
   Var WindowName : AnsiString;
   begin
      Frames += 1;
      
      FrameTime += Time;
      If (FrameTime < 1000) then Exit;
      
      WriteStr(WindowName, GAME_NAME, ' v.', GAME_VERSION, ' (', Frames, ' FPS)');
      SDL_WM_SetCaption(PChar(WindowName), PChar(WindowName));
      
      FrameTime -= 1000;
      Frames := 0
   end;

begin // MAIN
   Randomize();
   
   SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO or SDL_INIT_TIMER);
   
   Sour.SetGLAttributes(8,8,8,1);
   Screen := Sour.OpenWindow(800,600);
   
   SDL_WM_SetCaption(PChar(GAME_NAME),PChar(GAME_NAME));
   Sour.SetClearColour(Sour.MakeColour(0,0,0));
   
   With Planet[0] do begin
      X := 2000; Y := 2000; R := 2000
   end;
   
   With Planet[1] do begin
      X := 3500; Y := 3500; R := 1500
   end;
   
   CalcPlanetZones();
   Traveller := 0;
   
   Repeat
      
      AdvanceTime();
      
      Traveller += dT * 3690;
      If (Traveller > Planet[1].Cmax)
         then Traveller -= Planet[1].Cmax;
      
      ProcessEvents();
      MoveCamera();
      
      DrawFrame();
      CountFrames()
      
   Until Terminate;
   
   SDL_Quit()
end.
