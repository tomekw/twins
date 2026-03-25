with Ada.Strings;
with Ada.Strings.Fixed;

with Twins.Loggers;
with Twins.Shutdown_Handlers;
with Twins.Socket_Queues;

package body Twins.Acceptors is
   use Twins.Loggers;

   function Image (Port : Sockets.Port_Type) return String is
   begin
      return Strings.Fixed.Trim (Port'Image, Strings.Left);
   end Image;

   task body Acceptor is
      use type Sockets.Socket_Type;

      Acceptor_Cfg : Config;
      Server_Socket : Sockets.Socket_Type := Sockets.No_Socket;
   begin
      accept Init (Cfg : Config) do
         Acceptor_Cfg := Cfg;
      end Init;

      select
         Shutdown_Handlers.Shutdown_Handler.Wait;
      then abort
         declare
            Host : constant Sockets.Host_Entry_Type := Sockets.Get_Host_By_Name (Acceptor_Cfg.Host.Element);
            Bind_Address : constant Sockets.Inet_Addr_Type := Sockets.Addresses (Host);
            Address : Sockets.Sock_Addr_Type := (Family => Sockets.Family_Inet,
                                                 Addr => Bind_Address,
                                                 Port => Acceptor_Cfg.Server_Port);
            Client_Socket : Sockets.Socket_Type;
         begin
            Sockets.Create_Socket (Server_Socket);
            Sockets.Bind_Socket (Server_Socket, Address);
            Sockets.Listen_Socket (Server_Socket);

            Log (Info, "Twins, a Gemini server");
            Log (Info, "Listening on " & Acceptor_Cfg.Host.Element & ":" & Image (Acceptor_Cfg.Server_Port));

            loop
               Sockets.Accept_Socket (Server_Socket, Client_Socket, Address);

               Socket_Queues.Socket_Queue.Enqueue (Client_Socket);
            end loop;
         end;
      end select;

      if Server_Socket /= Sockets.No_Socket then
         Sockets.Close_Socket (Server_Socket);
      end if;

      Log (Info, "Server shutting down...");
   end Acceptor;
end Twins.Acceptors;
