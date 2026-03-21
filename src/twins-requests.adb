with Ada.Strings.Fixed;

package body Twins.Requests is
   function Parse (Request_Line : String) return Request is
      CRLF : constant String := [ASCII.CR, ASCII.LF];
   begin
      if Request_Line'Length > 1024 then
         raise Parse_Error with "request too long";
      end if;

      if Strings.Fixed.Index (Request_Line, "gemini://") /= Request_Line'First then
         raise Parse_Error with "request doesn't start with gemini://";
      end if;

      if Strings.Fixed.Index (Request_Line, CRLF, Going => Strings.Backward) /= Request_Line'Last - CRLF'Length + 1 then
         raise Parse_Error with "request doesn't end with \r\n";
      end if;

      return (Line => String_Holders.To_Holder (Request_Line (Request_Line'First .. Request_Line'Last - CRLF'Length)));
   end Parse;

   function Line (Self : Request) return String is
   begin
      return Self.Line.Element;
   end Line;
end Twins.Requests;
