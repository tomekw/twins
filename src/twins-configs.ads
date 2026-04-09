with GNAT.Sockets;

with Twins.Opts;

package Twins.Configs is
   Config_Error : exception;

   type Config is private;

   function Hostname (Self : Config) return String;
   function Port (Self : Config) return Sockets.Port_Type;
   function Content_Root (Self : Config) return String;
   function Cert_File (Self : Config) return String;
   function Key_File (Self : Config) return String;

   function Parse (Cmd : Opts.Command) return Config;

private

   type Config is record
      Hostname : String_Holders.Holder;
      Port : Sockets.Port_Type;
      Content_Root : String_Holders.Holder;
      Cert_File : String_Holders.Holder;
      Key_File : String_Holders.Holder;
   end record;
end Twins.Configs;
