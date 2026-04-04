with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Calendar.Time_Zones;
with Ada.Text_IO;

package body Twins.Loggers is
   function Time return String is
      T : String := Calendar.Formatting.Image
         (Date => Calendar.Clock,
         Time_Zone => Calendar.Time_Zones.UTC_Time_Offset);
   begin
      T (11) := 'T';
      return "[" & T & "Z]";
   end Time;

   procedure Log (Level : Log_Level; Message : String) is
   begin
      Text_IO.Put_Line ("[" & Level'Image & "] " & Time & " " & Message);
   end Log;
end Twins.Loggers;
