with Twins.Loggers;
with Twins.Socket_Queues;

package body Twins.Acceptors is
   use Twins.Loggers;

   Selector : aliased Sockets.Selector_Type;

   procedure Shutdown is
   begin
      Sockets.Abort_Selector (Selector);
   end Shutdown;

   task body Acceptor is
      use type Sockets.Socket_Type;

      Acceptor_Cfg : Configs.Config;
      Server_Socket : Sockets.Socket_Type := Sockets.No_Socket;
   begin
      accept Init (Cfg : Configs.Config) do
         Acceptor_Cfg := Cfg;
      end Init;

      declare
         use type Sockets.Selector_Status;

         Host : constant Sockets.Host_Entry_Type := Sockets.Get_Host_By_Name (Acceptor_Cfg.Hostname);
         Bind_Address : constant Sockets.Inet_Addr_Type := Sockets.Addresses (Host);
         Address : constant Sockets.Sock_Addr_Type := (Family => Sockets.Family_Inet,
                                                       Addr => Bind_Address,
                                                       Port => Acceptor_Cfg.Port);
         R_Set, W_Set : Sockets.Socket_Set_Type;
         Status : Sockets.Selector_Status;
      begin
         Sockets.Create_Socket (Server_Socket);
         Sockets.Set_Socket_Option
            (Socket => Server_Socket,
            Level => Sockets.Socket_Level,
            Option => (Name => Sockets.Reuse_Address,
            Enabled => True));

         Sockets.Bind_Socket (Server_Socket, Address);
         Sockets.Listen_Socket (Server_Socket);

         Log (Info, "twins " & Version);
         Log (Info, "Listening on " & Acceptor_Cfg.Hostname & ":" & Image (Acceptor_Cfg.Port) & " (workers:" & Acceptor_Cfg.Workers_Count'Image & ")");

         loop
            Sockets.Empty (R_Set);
            Sockets.Empty (W_Set);
            Sockets.Set (R_Set, Server_Socket);

            Sockets.Check_Selector (Selector, R_Set, W_Set, Status);

            if Status = Sockets.Aborted then
               Log (Info, "Server shutting down");
               exit;
            end if;

            declare
               Client_Socket : Sockets.Socket_Type;
               Client_Addr : Sockets.Sock_Addr_Type;
            begin
               Sockets.Accept_Socket (Server_Socket, Client_Socket, Client_Addr);
               Socket_Queues.Socket_Queue.Enqueue (Client_Socket);
            end;
         end loop;
      end;

      Sockets.Close_Selector (Selector);
      if Server_Socket /= Sockets.No_Socket then
         Sockets.Close_Socket (Server_Socket);
      end if;
   end Acceptor;
begin
   Sockets.Create_Selector (Selector);
end Twins.Acceptors;
