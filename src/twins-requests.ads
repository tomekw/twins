package Twins.Requests is
   Parse_Error : exception;
   Scheme_Error : exception;

   type Request is private;

   function Parse (Request_Line : String) return Request;

   function Host (Self : Request) return String;

   function Path (Self : Request) return String;

   function Params (Self : Request) return String;

   function Content_Path (Self : Request) return String;

private

   type Request is record
      Host : String_Holders.Holder;
      Path : String_Holders.Holder;
      Params : String_Holders.Holder;
   end record;
end Twins.Requests;
