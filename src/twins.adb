with Ada.Strings;
with Ada.Strings.Fixed;

package body Twins is
   function Image (Port : Sockets.Port_Type) return String is
   begin
      return Strings.Fixed.Trim (Port'Image, Strings.Left);
   end Image;
end Twins;
