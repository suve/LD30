program ld30;

{$MODE OBJFPC} {$COPERATORS ON}

uses SysUtils, SDL, SDL_Image, SDL_Mixer, Sour, GL;

Const
   GAME_NAME = 'LD30';
   GAME_VMAJOR = 0;
   GAME_VMINOR = 1;
   GAME_VBUGFX = 0;
   GAME_VERSION = Chr(GAME_VMAJOR) + '.' + Chr(GAME_VMINOR) + '.' + Chr(GAME_VBUGFX);

   SDL_TICKS_PER_SECOND = 1000;
   PLANET_GRANULARITY = 10;
   CAMERA_SPEED = 500;

Type
   sInt = System.NativeInt;
   uInt = System.NativeUInt;

Type
   PDir = ^TDir;
   TDir = (DIR_UP, DIR_RIGHT, DIR_DOWN, DIR_LEFT);

Const
   DIR_RI = DIR_RIGHT;
   DIR_DO = DIR_DOWN;
   DIR_LE = DIR_LEFT;
   
   SDLK_RI = SDLK_RIGHT;
   SDLK_DO = SDLK_DOWN;
   SDLK_LE = SDLK_LEFT;

Type
   PPoint = ^TPoint;
   TPoint = record
      X, Y : Double
   end;
   
   PPlanet = ^TPlanet;
   TPlanet = record
      X, Y, R : Double
   end;

Var
   Screen : PSDL_Surface = NIL;
   Terminate : Boolean = FALSE;
   Ev : TSDL_Event;
   
   Ticks, Time : uInt;
   dT : Double;
   
   Frames : uInt = 0;
   FrameTime : uInt = 0;
   
   Planet : Array[0..1] of TPlanet;
   
   Camera : TPoint = (X:0.0; Y:0.0);
   CamMove : Array[TDir] of Boolean = (False,False,False,False);

   CamScale : sInt = 10;
   CamScaleFactor : Double = 1;

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

Procedure CameraZoom(Const Change:sInt);
   Var CtrX, CtrY, NewScaleFactor : Double;
   begin
      CamScale += Change;
      If (CamScale <  1) then CamScale :=  1 else
      If (CamScale > 10) then CamScale := 10;
      
      NewScaleFactor := (11 - CamScale);
      
      CtrX := Camera.X + (Screen^.W / 2) * CamScaleFactor;
      CtrY := Camera.Y + (Screen^.H / 2) * CamScaleFactor;
      
      Camera.X := CtrX - (Screen^.W / 2) * NewScaleFactor;
      Camera.Y := CtrY - (Screen^.H / 2) * NewScaleFactor;
      
      CamScaleFactor := NewScaleFactor
   end;

Procedure ProcessEvents();
   begin
      While (SDL_PollEvent(@Ev) > 0) do
         Case (Ev.Type_) of
         
            SDL_QuitEv: Terminate := True;
            
            SDL_KeyDown:
               Case (Ev.Key.Keysym.Sym) of
                  SDLK_ESCAPE: Terminate := True;
                  SDLK_MINUS: CameraZoom(-1);
                  SDLK_EQUALS: CameraZoom(+1);
                  
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
            
         end;
   end;

Procedure MoveCamera();
   Var XMove, YMove : sInt; Scale : Double;
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
      X := 3000; Y := 3000; R := 1500
   end;
   
   Repeat
      
      AdvanceTime();
      
      ProcessEvents();
      MoveCamera();
      
      DrawFrame();
      CountFrames()
      
   Until Terminate;
   
   SDL_Quit()
end.
