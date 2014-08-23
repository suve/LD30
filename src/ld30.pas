program ld30;

{$INCLUDE defines.inc}
{$IFDEF WINDOWS} {$APPTYPE GUI} {$ENDIF}

uses
   SysUtils, SDL, SDL_Image, SDL_Mixer, Sour, GL,
   Globals, Resources, Creatures, Renderer;

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
   end;


Procedure CalculateCreatures();
   Var C:uInt;
   begin
      If (CreatureNum = 0) then Exit();
      For C:=0 to (CreatureNum - 1) do begin
         If (Creature[C] = NIL) then Exit();
         
         Creature[C]^.Calculate()
      end;
   end;


Procedure CountFrames();
   Var WindowName : AnsiString;
   begin
      Frames += 1;
      
      FrameTime += Time;
      If (FrameTime < 1000) then Exit;
      
      WriteStr(FrameStr,'FPS: ',Frames);
      WriteStr(WindowName, GAME_NAME, ' v.', GAME_VERSION, ' (', Frames, ' FPS)');
      SDL_WM_SetCaption(PChar(WindowName), PChar(WindowName));
      
      FrameTime -= 1000;
      Frames := 0
   end;

begin // MAIN
   Randomize();
   
   SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO or SDL_INIT_TIMER);
   
   Icon := IMG_Load('gfx/iconA.png');
   SDL_WM_SetIcon(Icon, NIL);
   
   Sour.SetGLAttributes(8,8,8,1);
   Screen := Sour.OpenWindow(800,600);
   
   SDL_WM_SetCaption(PChar(GAME_NAME),PChar(GAME_NAME));
   Sour.SetClearColour(Sour.MakeColour(0,0,0));
   
   FontA := Sour.LoadFont('gfx/font.png',$000000,7,9,#32);
   Sour.SetFontSpacing(FontA,1,1);
   
   TechnoUI[UIS_CRYSTALS] := Sour.LoadImage('gfx/techno-crystal.png',$000000);
   TechnoUI[UIS_TIMBER  ] := Sour.LoadImage('gfx/techno-timber.png',$000000);
   TechnoUI[UIS_METAL   ] := Sour.LoadImage('gfx/techno-metal.png',$000000);
   
   TribalUI[UIS_CRYSTALS] := Sour.LoadImage('gfx/tribal-crystal.png',$000000);
   TribalUI[UIS_TIMBER  ] := Sour.LoadImage('gfx/tribal-timber.png',$000000);
   TribalUI[UIS_METAL   ] := Sour.LoadImage('gfx/tribal-metal.png',$000000);
   
   With Planet[0] do begin
      X := 2000; Y := 2000; R := 2000
   end;
   
   With Planet[1] do begin
      X := 3500; Y := 3500; R := 1500
   end;
   
   CalcPlanetZones();
   Traveller := 0;
   
   SetLength(Resource, 20);
   For ResourceNum := 0 to 19 do begin
      New(Resource[ResourceNum]);
      
      Resource[ResourceNum]^.Typ := TResourceType(Random(3));
      Resource[ResourceNum]^.Amount := 100+Random(51);
      
      Resource[ResourceNum]^.C := Random() * Planet[1].Cmax
   end;
   ResourceNum += 1;
   
   SetLength(Creature, 5);
   For CreatureNum := 0 to 4 do begin
      New(Creature[CreatureNum],Create());
      
      Creature[CreatureNum]^.C := Random() * Planet[1].Cmax;
      Creature[CreatureNum]^.Speed := 150 + Random() * 300;
      
      Creature[CreatureNum]^.Order := CROR_WALK;
      Creature[CreatureNum]^.OrderTarget := Trunc(Random() * Planet[1].Cmax);
   end;
   CreatureNum += 1;
   
   Repeat
      
      AdvanceTime();
      
      Traveller += dT * 3690;
      If (Traveller > Planet[1].Cmax)
         then Traveller -= Planet[1].Cmax;
      
      ProcessEvents();
      MoveCamera();
      
      CalculateCreatures();
      
      DrawFrame();
      CountFrames()
      
   Until Terminate;
   
   SDL_Quit()
end.
