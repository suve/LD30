program ld30;

{$INCLUDE defines.inc}
{$IFDEF WINDOWS} {$APPTYPE GUI} {$ENDIF}

uses
   SysUtils,
   SDL, SDL_Image, SDL_Mixer,
   Sour, GL,
   Globals, Enums,
   Resources,
   Buildings, Creatures,
   Renderer;

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

Procedure MakeSelection();
   Var 
      Idx : sInt;
      aX, aY, bX, bY, T : Double;
   begin
      aX := mSelX;
      aY := mSelY;
      
      bX := Camera.X + mX * CamScaleFactor;
      bY := Camera.Y + mY * CamScaleFactor;
      
      If (bX < aX) then begin T := aX; aX := bX; bX := T end;
      If (bY < aY) then begin T := aY; aY := bY; bY := T end;
      
      SelLen := 0;
      If (CreatureNum > 0) then begin
         For Idx := 0 to (CreatureLen - 1) do
            If (Creature[Idx] <> NIL) then
               If (EntityInBox(Creature[Idx],15,21,aX,aY,bX,bY)) then begin
                  SelID[selLen] := Idx;
                  selLen += 1;
                  If (selLen = SEL_MAX) then Break;
               end;
         If (selLen > 0) then begin
            SelType := SEL_CREAT;
            Exit()
         end;
      end;
      If (BuildingNum > 0) then begin
         For Idx := 0 to (BuildingLen - 1) do
            If (Building[Idx] <> NIL) then
               If (EntityInBox(Building[Idx],30,42,aX,aY,bX,bY)) then begin
                  SelID[selLen] := Idx;
                  selLen += 1;
                  If (selLen = SEL_MAX) then Break;
               end;
         If (selLen > 0) then begin
            SelType := SEL_BUILD;
            Exit()
         end;
      end;
      SelType := SEL_NONE
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
                  SDL_BUTTON_LEFT: begin
                     SelType := SEL_MAKING;
                     mSelX := Trunc(Camera.X + mX * CamScaleFactor);
                     mSelY := Trunc(Camera.Y + mY * CamScaleFactor);
                  end;
                  
                  SDL_BUTTON_WHEELDOWN: CameraZoom(-1, ZOOM_MOUSE);
                  SDL_BUTTON_WHEELUP: CameraZoom(+1, ZOOM_MOUSE);
               end;
            end;
            
            SDL_MouseButtonUp: begin
               mX := Ev.Button.X;
               mY := Ev.Button.Y;
               
               Case (Ev.Button.Button) of
                  SDL_BUTTON_LEFT: MakeSelection();
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


Procedure CalculateBuildings();
   Var C:uInt;
   begin
      If (BuildingNum = 0) then Exit();
      For C:=0 to (BuildingLen - 1) do begin
         If (Building[C] = NIL) then Continue;
         
         Building[C]^.Calculate()
      end;
   end;


Procedure CalculateCreatures();
   Var C:uInt;
   begin
      If (CreatureNum = 0) then Exit();
      For C:=0 to (CreatureLen - 1) do begin
         If (Creature[C] = NIL) then Continue;
         
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

Procedure LoadGfx();
   Var CrTy : TCreatureType; BuTy : TBuildingType;
       FilePath : AnsiString;
   begin
      FontA := Sour.LoadFont('gfx/font.png',$000000,7,9,#32);
      Sour.SetFontSpacing(FontA,1,1);
      
      UIGfx[UI_TECHNO][UIS_CRYSTALS] := Sour.LoadImage('gfx/techno-crystal.png',$000000);
      UIGfx[UI_TECHNO][UIS_TIMBER  ] := Sour.LoadImage('gfx/techno-timber.png',$000000);
      UIGfx[UI_TECHNO][UIS_METAL   ] := Sour.LoadImage('gfx/techno-metal.png',$000000);
      
      UIGfx[UI_TECHNO][UIS_SEL_L] := Sour.LoadImage('gfx/techno-sel-l.png',$000000);
      UIGfx[UI_TECHNO][UIS_SEL_M] := Sour.LoadImage('gfx/techno-sel-m.png',$000000);
      UIGfx[UI_TECHNO][UIS_SEL_R] := Sour.LoadImage('gfx/techno-sel-r.png',$000000);
      
      UIGfx[UI_TRIBAL][UIS_CRYSTALS] := Sour.LoadImage('gfx/tribal-crystal.png',$000000);
      UIGfx[UI_TRIBAL][UIS_TIMBER  ] := Sour.LoadImage('gfx/tribal-timber.png',$000000);
      UIGfx[UI_TRIBAL][UIS_METAL   ] := Sour.LoadImage('gfx/tribal-metal.png',$000000);
      
      UIGfx[UI_TRIBAL][UIS_SEL_L] := Sour.LoadImage('gfx/tribal-sel-l.png',$000000);
      UIGfx[UI_TRIBAL][UIS_SEL_M] := Sour.LoadImage('gfx/tribal-sel-m.png',$000000);
      UIGfx[UI_TRIBAL][UIS_SEL_R] := Sour.LoadImage('gfx/tribal-sel-r.png',$000000);
      
      ResourceGfx := Sour.LoadImage('gfx/resources.png',$000000);
      CreatureGfx := Sour.LoadImage('gfx/creatures.png',$000000);
      BuildingGfx := Sour.LoadImage('gfx/buildings.png',$000000);
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
   
   LoadGfx();
   
   With Planet[0] do begin
      X := 2000; Y := 2000; R := 2000
   end;
   
   With Planet[1] do begin
      X := 3500; Y := 3500; R := 1500
   end;
   
   CalcPlanetZones();
   
   ResourceLen := 20;
   SetLength(Resource, ResourceLen);
   For ResourceNum := 0 to (ResourceLen-1) do begin
      New(Resource[ResourceNum]);
      
      Resource[ResourceNum]^.Typ := TResourceType(Random(3));
      Resource[ResourceNum]^.Amount := 40+Random(81);
      
      Resource[ResourceNum]^.C := Random() * Planet[1].Cmax
   end;
   ResourceNum := ResourceLen;
   
   CreatureLen := 5;
   SetLength(Creature, CreatureLen);
   For CreatureNum := 0 to (CreatureLen-1) do begin
      New(Creature[CreatureNum],Create());
      
      Creature[CreatureNum]^.C := Random() * Planet[1].Cmax;
      Creature[CreatureNum]^.Speed := 150 + Random() * 300;
      
      Creature[CreatureNum]^.Order := CROR_WALK;
      Creature[CreatureNum]^.OrderTarget := Trunc(Random() * Planet[1].Cmax);
      
      Creature[CreatureNum]^.Typ := CRTRIB_WORK;
   end;
   CreatureNum := CreatureLen;
   
   BuildingLen := 0;
   BuildingNum := 0;
   SelType := SEL_NONE;
   
   Repeat
      
      AdvanceTime();
      
      ProcessEvents();
      MoveCamera();
      
      CalculateBuildings();
      CalculateCreatures();
      
      DrawFrame();
      CountFrames()
      
   Until Terminate;
   
   SDL_Quit()
end.
