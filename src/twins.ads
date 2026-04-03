with Ada.Containers.Indefinite_Holders;

package Twins is
   use Ada;

   Version : constant String := "0.1.0";

   package String_Holders is new Containers.Indefinite_Holders (Element_Type => String);
end Twins;
