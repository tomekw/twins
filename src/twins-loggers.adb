with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Calendar.Time_Zones;
with Ada.Containers.Synchronized_Queue_Interfaces;
with Ada.Containers.Bounded_Synchronized_Queues;
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

   type Log_Payload_Kind is (Log_Message, Shutdown);

   type Log_Payload (Kind : Log_Payload_Kind := Log_Message) is record
      case Kind is
         when Log_Message =>
            Level : Log_Level;
            Message_Holder : String_Holders.Holder;
         when Shutdown =>
            null;
      end case;
   end record;

   package Logger_Queue_Interfaces is new Containers.Synchronized_Queue_Interfaces
      (Element_Type => Log_Payload);

   package Bounded_Logger_Queues is new Containers.Bounded_Synchronized_Queues
      (Queue_Interfaces => Logger_Queue_Interfaces,
       Default_Capacity => 64);

   Queue : Bounded_Logger_Queues.Queue;

   task Log_Writer;

   task body Log_Writer is
      Payload : Log_Payload;
   begin
      loop
         Queue.Dequeue (Payload);

         exit when Payload.Kind = Shutdown;

         Text_IO.Put_Line ("[" & Payload.Level'Image & "] " & Time & " " & Payload.Message_Holder.Element);
      end loop;
   end Log_Writer;

   procedure Log (Level : Log_Level; Message : String) is
   begin
      Queue.Enqueue ((Kind => Log_Message,
                      Level => Level,
                      Message_Holder => String_Holders.To_Holder (Message)));
   end Log;

   procedure Shutdown is
   begin
      Queue.Enqueue ((Kind => Shutdown));
   end Shutdown;
end Twins.Loggers;
