package body Twins.Configs is
   function Parse (Arguments : CL_Arguments.Argument_List.Vector) return Config is
      Cfg : Config;
      Arguments_Count : constant Natural := Natural (Arguments.Length);
   begin
      if Arguments_Count = 0 then
         return Cfg;
      end if;

      declare
         I : Positive := Arguments.First_Index;
      begin
         while I < Arguments_Count loop
            if Arguments (I) = "-H" then
               Cfg.Hostname := String_Holders.To_Holder (Arguments (I + 1));
            elsif Arguments (I) = "-p" then
               Cfg.Port := Sockets.Port_Type'Value (Arguments (I + 1));
            elsif Arguments (I) = "-r" then
               Cfg.Content_Root := String_Holders.To_Holder (Arguments (I + 1));
            elsif Arguments (I) = "-c" then
               Cfg.Cert_File := String_Holders.To_Holder (Arguments (I + 1));
            elsif Arguments (I) = "-k" then
               Cfg.Key_File := String_Holders.To_Holder (Arguments (I + 1));
            else
               raise Config_Error with "invalid option: " & Arguments (I);
            end if;

            I := I + 2;
         end loop;
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
