unit bullets;

{$INCLUDE defines.inc}

interface
   uses Enums, Entities;

Type
   PBullet = ^TBullet;
   TBullet = record
      X, Y, xVel, yVel : Double;
      
      Pow : Double;
      Team : sInt
   end;

Var
   Bullet : Array of PBullet;
   BulletNum, BulletLen : sInt;


Procedure FireBullet(Const enFr, enTo:PEntity;Const Pow,Spd:Double);


implementation
   uses Globals;


Procedure FireBullet(Const enFr, enTo:PEntity;Const Pow,Spd:Double);
   Var
      B:PBullet; enFrPt,enToPt : TPoint; enFrAn, enToAn, dist : Double;
      Idx : uInt;
   begin
      New(B);
      
      CH_to_XYA(enFr^.C, 0, @enFrPt, @enFrAn);
      CH_to_XYA(enTo^.C, 0, @enToPt, @enToAn);
      
      enFrPt.X += Cos(enFrAn) * 21; enFrPt.Y += Cos(enFrAn) * 21;
      enToPt.X += Cos(enToAn) * 21; enToPt.Y += Cos(enToAn) * 21;
      
      B^.XVel := enToPt.X - enFrPt.X;
      B^.YVel := enToPt.Y - enFrPt.Y;
      dist := Sqrt(Sqr(B^.XVel) + Sqr(B^.YVel));
      
      B^.XVel := B^.XVel / dist * Spd; 
      B^.YVel := B^.YVel / dist * Spd;
      
      B^.X := enFrPt.X; B^.Y := enFrPt.Y;
      B^.Team := enFr^.Team;
      B^.Pow := Pow;
      
      If (BulletNum = BulletLen) then begin
         BulletLen += ARRAY_RESIZE_STEP;
         SetLength(Bullet, BulletLen);
         Idx := BulletNum
      end else
         For Idx := 0 to (BulletLen - 1) do
            If (Bullet[Idx] = NIL) then Break;
         
      Bullet[Idx] := B;
      BulletNum += 1
   end;


end.
