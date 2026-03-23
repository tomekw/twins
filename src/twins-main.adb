with Twins.Acceptors;
with Twins.Shutdown_Handlers;
with Twins.Workers;

procedure Twins.Main is
   Acceptor_Cfg : constant Acceptors.Config := (Server_Port => 1965);
   Server_Acceptor : Acceptors.Acceptor;

   Worker_Cfg : constant Workers.Config := (Cert_File => String_Holders.To_Holder ("cert.pem"),
                                            Key_File => String_Holders.To_Holder ("key.pem"),
                                            Content_Root => String_Holders.To_Holder ("content"));
   Workers_Count : constant Positive := 8;
   Workers_Pool : array (1 .. Workers_Count) of Workers.Worker;
begin
   Server_Acceptor.Init (Acceptor_Cfg);

   for Worker of Workers_Pool loop
      Worker.Init (Worker_Cfg);
   end loop;

   Shutdown_Handlers.Shutdown_Handler.Wait;
end Twins.Main;
