with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Text_IO;

with Twins.Socket_Queues;

package body Twins.Acceptors is
   use Ada;

   function Image (Port : Sockets.Port_Type) return String is
   begin
      return Strings.Fixed.Trim (Port'Image, Strings.Left);
   end Image;

   task body Acceptor is
      Cfg : Config;
   begin
      accept Init (Acceptor_Cfg : Config) do
         Cfg := Acceptor_Cfg;
      end Init;

      declare
         Bind_Address : constant Sockets.Inet_Addr_Type := Sockets.Any_Inet_Addr;
         Server_Socket : Sockets.Socket_Type;
         Address : Sockets.Sock_Addr_Type := (Family => Sockets.Family_Inet,
                                              Addr => Bind_Address,
                                              Port => Cfg.Server_Port);
         Client_Socket : Sockets.Socket_Type;
      begin
         Sockets.Create_Socket (Server_Socket);
         Sockets.Bind_Socket (Server_Socket, Address);
         Sockets.Listen_Socket (Server_Socket);

         Text_IO.Put_Line ("Twins, a Gemini server");
         Text_IO.Put_Line ("Listening on " & Sockets.Image (Bind_Address) & ":" & Image (Cfg.Server_Port));

         loop
            Sockets.Accept_Socket (Server_Socket, Client_Socket, Address);

            Socket_Queues.Socket_Queue.Enqueue (Client_Socket);
         end loop;
      end;
   end Acceptor;
end Twins.Acceptors;
