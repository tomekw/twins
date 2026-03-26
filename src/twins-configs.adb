package body Twins.Configs is
   function Parse (Arguments : CL_Arguments.Argument_List.Vector) return Config is
      Cfg : Config;
      Unused_Arguments_Count : constant Natural := Natural (Arguments.Length);
   begin
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
