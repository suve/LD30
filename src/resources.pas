unit resources;

interface
   uses Globals, Enums;

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

implementation

end.
