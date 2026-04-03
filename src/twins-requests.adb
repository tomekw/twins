with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;

package body Twins.Requests is
   function Percent_Decode (Input : String) return String is
      use Ada.Strings.Unbounded;

      Result : Unbounded_String;
      I : Positive := Input'First;
   begin
      while I <= Input'Last loop
         if Input (I) = '%' and then
            I + 2 <= Input'Last
         then
            declare
               Decimal_Value : constant Integer := Integer'Value ("16#" & Input (I + 1 .. I + 2) & "#");
               Decoded_Character : constant Character := Character'Val (Decimal_Value);
            begin
               Append (Result, Decoded_Character);
               I := I + 3;
            end;
         else
            Append (Result, Input (I));
            I := I + 1;
         end if;
      end loop;

      return To_String (Result);
   exception
      when Constraint_Error =>
         raise Parse_Error with "invalid percent encoding";
   end Percent_Decode;

   function Parse (Request_Line : String) return Request is
      CRLF : constant String := [ASCII.CR, ASCII.LF];
      Scheme : constant String := "gemini://";
   begin
      if Request_Line'Length > 1026 then
         raise Parse_Error with "request too long";
      end if;

      if Strings.Fixed.Index (Request_Line, "gemini://") /= Request_Line'First then
         raise Parse_Error with "request doesn't start with gemini://";
      end if;

      if Request_Line (Request_Line'Last - 1 .. Request_Line'Last) /= CRLF then
         raise Parse_Error with "request doesn't end with \r\n";
      end if;

      if Strings.Fixed.Index (Request_Line (Request_Line'First .. Request_Line'Last - 2), CRLF) /= 0 then
         raise Parse_Error with "request contains embedded \r\n";
      end if;

      declare
         Line : constant String := Request_Line (Request_Line'First + Scheme'Length .. Request_Line'Last - CRLF'Length);

         Slash : constant Natural := Strings.Fixed.Index (Line, "/");
         Line_After_Host : constant String := (if Slash = 0 then "" else Line (Slash + 1 .. Line'Last));
         Q_Mark : constant Natural := Strings.Fixed.Index (Line_After_Host, "?");

         Host : constant String := Line (Line'First .. (if Slash = 0 then Line'Last else Slash - 1));
         Path : constant String := Percent_Decode ((if Slash = 0 then "" elsif Q_Mark = 0 then Line_After_Host else Line (Line_After_Host'First .. Q_Mark - 1)));
         Params : constant String := (if Q_Mark = 0 then "" else Line_After_Host (Q_Mark + 1 .. Line_After_Host'Last));
      begin
         if Host'Length = 0 or else
            Host (Host'First) = ':'
         then
            raise Parse_Error with "host is empty";
         end if;

         if Strings.Fixed.Index (Path, "/../") /= 0 or else
            Strings.Fixed.Index (Path, "/..", Going => Strings.Backward) = Path'Last - 2 or else
            Path = ".." or else
            (Path'Length >= 3 and then Path (Path'First .. Path'First + 2) = "../")
         then
            raise Parse_Error with "path contains ..";
         end if;

         if Strings.Fixed.Index (Path, "/./") /= 0 or else
            Strings.Fixed.Index (Path, "/.", Going => Strings.Backward) = Path'Last - 1 or else
            Path = "." or else
            (Path'Length >= 2 and then Path (Path'First .. Path'First + 1) = "./")
         then
            raise Parse_Error with "path contains . segment";
         end if;

         return (Host => String_Holders.To_Holder (Host), Path => String_Holders.To_Holder (Path), Params => String_Holders.To_Holder (Params));
      end;
   end Parse;

   function Host (Self : Request) return String is
   begin
      return Self.Host.Element;
   end Host;

   function Path (Self : Request) return String is
   begin
      return Self.Path.Element;
   end Path;

   function Params (Self : Request) return String is
   begin
      return Self.Params.Element;
   end Params;

   function Content_Path (Self : Request) return String is
      Path : constant String := Self.Path.Element;
   begin
      if Path'Length = 0 then
         return "index.gmi";
      elsif Directories.Extension (Path)'Length = 0 then
         if Path (Path'Last) = '/' then
            return Path & "index.gmi";
         else
            return Path & "/index.gmi";
         end if;
      else
         return Path;
      end if;
   end Content_Path;
end Twins.Requests;
