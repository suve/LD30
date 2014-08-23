unit buildings;

{$INCLUDE defines.inc}

interface
   uses Enums;

Type
   TProduction = record
      Active : Boolean;
      crType : TCreatureType;
      
      Speed : Double;
      Progress : Double;
   end;
   
   PBuilding = ^TBuilding;
   TBuilding = object
      C, H : Double;
      
      Finished : Double;
      HP, MaxHP : Double;
      
      Production : TProduction;
      Team : uInt;
      
      Procedure Calculate();
      
      Constructor Create();
      Destructor Destroy();
   end;

Var
   Building : Array of PBuilding;
   BuildingNum, BuildingLen : uInt;



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

end.
