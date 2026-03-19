with Ada.Text_IO;

package body Twins is
   procedure Log_Line (Line : String) is
   begin
      Text_IO.Put_Line (Line);
   end Log_Line;
end Twins;
