with GNAT.Sockets;

with Tackle.Opts;

package Twins.Configs is
   use Tackle;
   use Tackle.Opts;

   Options : constant Option_List := [Arg  ("hostname", 'H', "Server hostname (default: localhost)"),
                                      Arg  ("port",     'p', "Server port (default: 1965)"),
                                      Arg  ("root",     'r', "Content root (default: ""content"" in the current directory)"),
                                      Arg  ("cert",     'c', "TLS certificate path (default: ""cert.pem"" in the current directory)"),
                                      Arg  ("key",      'k', "TLS key path (default: ""key.pem"" in the current directory)"),
                                      Arg  ("workers",  'w', "Workers count (default: 8)"),
                                      Flag ("help",     'h', "Print this message")];

   Config_Error : exception;

   type Config is private;

   function Hostname (Self : Config) return String;
   function Port (Self : Config) return Sockets.Port_Type;
   function Content_Root (Self : Config) return String;
   function Cert_File (Self : Config) return String;
   function Key_File (Self : Config) return String;
   function Workers_Count (Self : Config) return Positive;

   function Parse (Result : Opts.Result) return Config;

private

   type Config is record
      Hostname : String_Holders.Holder;
      Port : Sockets.Port_Type;
      Content_Root : String_Holders.Holder;
      Cert_File : String_Holders.Holder;
      Key_File : String_Holders.Holder;
      Workers_Count : Positive;
   end record;
end Twins.Configs;
