with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Calendar.Time_Zones;
with Ada.Text_IO;

package body Twins.Loggers is
   function Prefix (Level : Log_Level) return String is
   begin
      return (case Level is
         when Info => "[info]",
         when Warning => "[warning]",
         when Error => "[error]");
   end Prefix;

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
      Text_IO.Put_Line (Prefix (Level) & " " & Time & " " & Message);
   end Log;

   procedure Log_Request (Level : Log_Level; Request : Requests.Request; Client_IP : String; Status : String) is
   begin
      Text_IO.Put_Line (Prefix (Level) & " " & Time & " " & Request.Content_Path & " " & Client_IP & " " & Status);
   end Log_Request;
end Twins.Loggers;
