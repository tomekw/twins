with Ada.Text_IO;

package body Twins.Loggers is
   procedure Log (Level : Log_Level; Message : String) is
      Prefix : constant String := (case Level is
         when Info => "[info]",
         when Warning => "[warning]",
         when Error => "[error]");
   begin
      Text_IO.Put_Line (Prefix & " " & Message);
   end Log;
end Twins.Loggers;
