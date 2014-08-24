unit resources;

{$INCLUDE defines.inc}

interface
   uses Globals, Enums, Entities;

Type
   PResource = ^TResource;
   TResource = record
      C : Double;
      
      Typ : TResourceType;
      Amount : Double;
   end;

Var
   Resource : Array of PResource;
   ResourceNum, ResourceLen : uInt;


Function NearestResource(Const nrC:Double;Const RT:TResourceType):sInt;
Function ResourceAvailable(Const nrC:Double;Const RT:TResourceType;Const Range : Double = 5):sInt;

Function ResourceAvailable(Const nrC:Double;Const Range : Double = 5):sInt;

Procedure MineResource(Const Idx:sInt;Const HowMuch:Double);


implementation



Function NearestResource(Const nrC:Double;Const RT:TResourceType):sInt;
   Var Idx, nID : sInt; nD, Dist : Double;
   begin
      If (ResourceNum = 0) then Exit(-1);
      
      nID := -1; nD := 1000000;
      
      For Idx := 0 to (ResourceLen - 1) do
         If (Resource[Idx] <> NIL) then
            If (Resource[Idx]^.Typ = RT) then begin
               Dist := nrC - Resource[Idx]^.C;
               If (Dist < 0) then Dist += Planet[1].Cmax;
               If (Dist < nD) then begin
                  nID := Idx; nD := Dist;
               end
            end;
      Exit(nID)
   end;


Function ResourceAvailable(Const nrC:Double;Const RT:TResourceType;Const Range : Double = 5):sInt;
   Var Idx : sInt; Dist : Double;
   begin
      If (ResourceNum = 0) then Exit(-1);
      For Idx := 0 to (ResourceLen - 1) do
         If (Resource[Idx] <> NIL) then
            If (Resource[Idx]^.Typ = RT) then begin
               Dist := nrC - Resource[Idx]^.C;
               If (Dist < 0) then Dist += Planet[1].Cmax;
               If (Dist < Range) then Exit(Idx)
            end;
      Exit(-1)
   end;


Function ResourceAvailable(Const nrC:Double;Const Range : Double = 5):sInt;
   Var Idx : sInt; Dist : Double;
   begin
      If (ResourceNum = 0) then Exit(-1);
      For Idx := 0 to (ResourceLen - 1) do
         If (Resource[Idx] <> NIL) then begin
            Dist := nrC - Resource[Idx]^.C;
            If (Dist < 0) then Dist += Planet[1].Cmax;
            If (Dist < Range) then Exit(Idx)
         end;
      Exit(-1)
   end;


Procedure MineResource(Const Idx:sInt;Const HowMuch:Double);
   begin
      If (Idx < 0) or (Idx >= ResourceLen) then Exit();
      If (Resource[Idx] = NIL) then Exit();
      
      Resource[Idx]^.Amount -= HowMuch;
      If (Resource[Idx]^.Amount <= 0) then begin
         Dispose(Resource[Idx]);
         Resource[Idx] := NIL;
         ResourceNum -= 1
      end
   end;


end.
