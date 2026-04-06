with GNAT.Sockets;

with Twins.CL_Arguments;

package Twins.Configs is
   Config_Error : exception;

   type Config is private;

   function Hostname (Self : Config) return String;

   function Port (Self : Config) return Sockets.Port_Type;

   function Content_Root (Self : Config) return String;

   function Cert_File (Self : Config) return String;

   function Key_File (Self : Config) return String;

   function Parse (Arguments : CL_Arguments.Argument_List.Vector) return Config;

private

   type Config is record
      Hostname : String_Holders.Holder := String_Holders.To_Holder ("localhost");
      Port : Sockets.Port_Type := 1965;
      Content_Root : String_Holders.Holder := String_Holders.To_Holder ("content");
      Cert_File : String_Holders.Holder := String_Holders.To_Holder ("cert.pem");
      Key_File : String_Holders.Holder := String_Holders.To_Holder ("key.pem");
   end record;
end Twins.Configs;
