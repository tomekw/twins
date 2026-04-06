with Ada.Containers.Indefinite_Holders;

with GNAT.Sockets;

package Twins is
   use Ada;
   use GNAT;

   Version : constant String := "0.1.0";

   package String_Holders is new Containers.Indefinite_Holders (Element_Type => String);

   function Image (Port : Sockets.Port_Type) return String;
end Twins;
