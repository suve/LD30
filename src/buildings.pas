unit buildings;

{$INCLUDE defines.inc}

interface
   uses Enums, Entities;

Type
   TBuildingStats = record
      MaxHP : Double;
      BuildTime : Double;
      Collect : Boolean;
      Produce : Boolean;
      Cost : Array[TResourceType] of Double
   end;

Const
   BuildingStats : Array[TBuildingType] of TBuildingStats = (
      (MaxHP: 500; BuildTime: 60; Collect:  True; Produce:  True; Cost: ( 400, 100, 250)),
      (MaxHP: 200; BuildTime: 45; Collect: False; Produce: False; Cost: ( 120,   0,  80)),
      (MaxHP: 400; BuildTime: 48; Collect:  True; Produce:  True; Cost: ( 400, 250,  30)),
      (MaxHP: 155; BuildTime: 36; Collect: False; Produce: False; Cost: (  80,  72,  10)),
      ()
   );

Type
   TProduction = record
      Active : Boolean;
      crType : TCreatureType;
      
      Speed : Double;
      Progress : Double;
   end;
   
   PBuilding = ^TBuilding;
   TBuilding = object(TEntity)
      
      Typ : TBuildingType;
      Finished : Double;
      Production : TProduction;
      
      Procedure Calculate(); Virtual;
      
      Constructor Create();
      Destructor Destroy(); Virtual;
   end;

Var
   Building : Array of PBuilding;
   BuildingNum, BuildingLen : sInt;


Function NearestCollector(Const ncC:Double;Const Team:sInt):sInt;
Procedure DamageBuilding(Const Idx:sInt;Const Dmg:Double);


implementation
   uses Globals;

Procedure TBuilding.Calculate();
   begin
      If (Production.Active) then begin
         Production.Progress += dT * Production.Speed;
         If (Production.Progress >= 100) then begin
            Globals.FinishProduction(@Self);
            Production.Active := False;
         end
      end;
   end;

Constructor TBuilding.Create();
   begin
      
   end;

Destructor TBuilding.Destroy();
   begin
      
   end;


Function NearestCollector(Const ncC:Double;Const Team:sInt):sInt;
   Var Idx, nID : sInt; Dist, nDst : Double;
   begin
      If (BuildingNum <= 0) then Exit(-1);
      
      nID := -1; nDst := 1000000;
      
      For Idx := 0 to (BuildingLen - 1) do
         If (Building[Idx] <> NIL) then
            If (Building[Idx]^.Team = Team) and (BuildingStats[Building[Idx]^.Typ].Collect) then begin
               Dist := CDist(nCC, Building[Idx]^.C);
               If (Dist < nDst) then begin
                  nID := Idx; nDst := Dist
               end
            end;
         
      Exit(nID)
   end;


Procedure DamageBuilding(Const Idx:sInt;Const Dmg:Double);
   begin
      If (Idx < 0) or (Idx >= BuildingLen) then Exit();
      If (Building[Idx] = NIL) then Exit();
      
      Building[Idx]^.HP -= Dmg;
      If (Building[Idx]^.HP <= 0) then begin
         Dispose(Building[Idx],Destroy());
         Building[Idx] := NIL;
         BuildingNum -= 1;
      end
   end;

end.
