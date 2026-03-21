with Ada.Containers.Indefinite_Holders;

package Twins is
   use Ada;

   package String_Holders is new Containers.Indefinite_Holders (Element_Type => String);
end Twins;
