unit resources;

interface
   uses Globals;

Type
   TResourceType = (RSRC_CRYSTAL, RSRC_METAL, RSRC_WOOD);
   
   PResource = ^TResource;
   TResource = record
      C : Double;
      
      Typ : TResourceType;
      Amount : Double;
   end;

Var
   Resource : Array of PResource;
   ResourceNum : uInt;

implementation

end.
