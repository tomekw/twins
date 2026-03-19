with Ada.Containers.Indefinite_Holders;

package Twins is
   use Ada;

   package String_Holders is new Containers.Indefinite_Holders (Element_Type => String);

   procedure Log_Line (Line : String);
end Twins;
