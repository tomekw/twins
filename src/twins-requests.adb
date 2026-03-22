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
      if Request_Line'Length > 1024 then
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
         Decoded_Line : constant String := Percent_Decode (Request_Line (Request_Line'First + Scheme'Length .. Request_Line'Last));
      begin
         if Strings.Fixed.Index (Decoded_Line, "/../") /= 0 or else
            Strings.Fixed.Index (Decoded_Line, "/.." & CRLF) /= 0
         then
            raise Parse_Error with "path contains ..";
         end if;

         if Strings.Fixed.Index (Decoded_Line, "/./") /= 0 or else
            Strings.Fixed.Index (Decoded_Line, "/." & CRLF) /= 0
         then
            raise Parse_Error with "path contains . segment";
         end if;

         if Strings.Fixed.Index (Decoded_Line, "/") = Decoded_Line'First or else
            Strings.Fixed.Index (Decoded_Line, ":") = Decoded_Line'First or else
            Strings.Fixed.Index (Decoded_Line, CRLF) = Decoded_Line'First
         then
            raise Parse_Error with "host is empty";
         end if;

         return (Line => String_Holders.To_Holder (Scheme & Decoded_Line (Decoded_Line'First .. Decoded_Line'Last - CRLF'Length)));
      end;
   end Parse;

   function Line (Self : Request) return String is
   begin
      return Self.Line.Element;
   end Line;
end Twins.Requests;
