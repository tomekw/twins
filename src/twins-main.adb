with Ada.Text_IO;

with Twins.Acceptors;
with Twins.CL_Arguments;
with Twins.Configs;
with Twins.Shutdown_Handlers;
with Twins.Workers;

procedure Twins.Main is
   use Ada;

   procedure Print_Help is
   begin
      Text_IO.Put_Line ("Usage: twins [options]");
      Text_IO.New_Line;
      Text_IO.Put_Line ("Options:");
      Text_IO.Put_Line ("    -H  hostname             default: localhost");
      Text_IO.Put_Line ("    -p  port                 default: 1965");
      Text_IO.Put_Line ("    -r  content root         default: ""content"" in the current directory");
      Text_IO.Put_Line ("    -c  certificate file     default: ""cert.pem"" in the current directory");
      Text_IO.Put_Line ("    -k  certificate key      default: ""key.pem"" in the current directory");
      Text_IO.Put_Line ("    -h  print this message");
   end Print_Help;

   Arguments : constant CL_Arguments.Argument_List.Vector := CL_Arguments.Consume;
   Arguments_Count : constant Natural := Natural (Arguments.Length);

   Cfg : Configs.Config;
begin
   if Arguments_Count = 1 and then
      Arguments (1) = "-h"
   then
      Print_Help;
      return;
   end if;

   Cfg := Configs.Parse (Arguments);

   declare
      Server_Acceptor : Acceptors.Acceptor;

      Workers_Count : constant Positive := 8;
      Workers_Pool : array (1 .. Workers_Count) of Workers.Worker;
   begin
      Server_Acceptor.Init (Cfg);

      for Worker of Workers_Pool loop
         Worker.Init (Cfg);
      end loop;

      Shutdown_Handlers.Shutdown_Handler.Wait;
   end;
end Twins.Main;
