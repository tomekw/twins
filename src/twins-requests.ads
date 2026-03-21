package Twins.Requests is
   Parse_Error : exception;

   type Request is private;

   function Parse (Request_Line : String) return Request;

   function Line (Self : Request) return String;

private

   type Request is record
      Line : String_Holders.Holder;
   end record;
end Twins.Requests;
