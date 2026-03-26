package body Twins.Configs is
   function Parse (Arguments : CL_Arguments.Argument_List.Vector) return Config is
      Arguments_Count : constant Natural := Natural (Arguments.Length);
   begin
      if Arguments_Count < 10 then
         raise Config_Error with "too few arguments";
      end if;

      return (Hostname => String_Holders.To_Holder ("foo"),
              Port => 1024,
              Content_Root => String_Holders.To_Holder ("bar"),
              Cert_File => String_Holders.To_Holder ("baz"),
              Key_File => String_Holders.To_Holder ("qux"));
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
