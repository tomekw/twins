with Ada.Text_IO;

with Twins.Acceptors;
with Twins.CL_Arguments;
with Twins.Configs;
with Twins.Shutdown_Handlers;
with Twins.Workers;

procedure Twins.Main is
   use Ada;

   procedure Print_Usage is
   begin
      Text_IO.Put ("Usage: twins --hostname example.com --port 1965 --content-root /var/gemini ");
      Text_IO.Put ("--cert-file /etc/ssl/certs/cert.pem --key-file /etc/ssl/certs/key.pem");
      Text_IO.New_Line;
   end Print_Usage;

   Hostname : constant String := "localhost";
   Acceptor_Cfg : constant Acceptors.Config := (Hostname => String_Holders.To_Holder (Hostname),
                                                Server_Port => 1965);
   Worker_Cfg : constant Workers.Config := (Cert_File => String_Holders.To_Holder ("cert.pem"),
                                            Key_File => String_Holders.To_Holder ("key.pem"),
                                            Content_Root => String_Holders.To_Holder ("content"),
                                            Hostname => String_Holders.To_Holder (Hostname));

   Arguments : constant CL_Arguments.Argument_List.Vector := CL_Arguments.Consume;
   Arguments_Count : constant Natural := Natural (Arguments.Length);

   Cfg : Configs.Config;
begin
   if Arguments_Count < 10 then
      Print_Usage;
      return;
   end if;

   declare
      Server_Acceptor : Acceptors.Acceptor;

      Workers_Count : constant Positive := 8;
      Workers_Pool : array (1 .. Workers_Count) of Workers.Worker;
   begin
      Server_Acceptor.Init (Acceptor_Cfg);

      for Worker of Workers_Pool loop
         Worker.Init (Worker_Cfg);
      end loop;

      Shutdown_Handlers.Shutdown_Handler.Wait;
   end;
end Twins.Main;
