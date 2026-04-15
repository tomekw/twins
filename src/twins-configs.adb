with Ada.Directories;

package body Twins.Configs is
   function Parse (Result : Opts.Result) return Config is
      use String_Holders;

      Cfg : Config;
   begin
      Cfg.Hostname := To_Holder (Result.Arg ("hostname", "localhost"));

      declare
         Port : constant String := Result.Arg ("port", "1965");
      begin
         Cfg.Port := Sockets.Port_Type'Value (Port);
      exception
         when Constraint_Error =>
            raise Config_Error with "invalid port: " & Port;
      end;

      declare
         Root : constant String := Result.Arg ("root", "content");
      begin
         if not Directories.Exists (Root) then
            raise Config_Error with "invalid root: " & Root;
         end if;

         Cfg.Content_Root := To_Holder (Root);
      end;

      declare
         Cert_File : constant String := Result.Arg ("cert", "cert.pem");
      begin
         if not Directories.Exists (Cert_File) then
            raise Config_Error with "invalid cert file: " & Cert_File;
         end if;

         Cfg.Cert_File := To_Holder (Cert_File);
      end;

      declare
         Key_File : constant String := Result.Arg ("key", "key.pem");
      begin
         if not Directories.Exists (Key_File) then
            raise Config_Error with "invalid key file: " & Key_File;
         end if;

         Cfg.Key_File := To_Holder (Key_File);
      end;

      return Cfg;
   end Parse;

   function Hostname (Self : Config) return String is
   begin
      return Self.Hostname.Element;
   end Hostname;

   function Port (Self : Config) return Sockets.Port_Type is
   begin
      return Self.Port;
   end Port;

   function Content_Root (Self : Config) return String is
   begin
      return Self.Content_Root.Element;
   end Content_Root;

   function Cert_File (Self : Config) return String is
   begin
      return Self.Cert_File.Element;
   end Cert_File;

   function Key_File (Self : Config) return String is
   begin
      return Self.Key_File.Element;
   end Key_File;
end Twins.Configs;
