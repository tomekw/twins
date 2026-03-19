with Twins.Acceptors;
with Twins.Workers;

procedure Twins.Main is
   Acceptor_Cfg : constant Acceptors.Config := (Server_Port => 1965);
   Server_Acceptor : Acceptors.Acceptor;

   Workers_Count : constant Positive := 8;
   Workers_Pool : array (1 .. Workers_Count) of Workers.Worker;
begin
   Server_Acceptor.Init (Acceptor_Cfg);
end Twins.Main;
