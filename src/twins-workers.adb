with Ada.Streams;
with GNAT.Sockets;

with Padlock.Configs;
with Padlock.Contexts;
with Padlock.Contexts.Servers;
with Padlock.Streams;

with Twins.Loggers;
with Twins.Requests;
with Twins.Shutdown_Handlers;
with Twins.Socket_Queues;

package body Twins.Workers is
   use GNAT;
   use Twins.Loggers;

   package TLS renames Padlock;

   task body Worker is
      use type Sockets.Socket_Type;

      Worker_Cfg : Config;
      Client_Socket : Sockets.Socket_Type := Sockets.No_Socket;
   begin
      accept Init (Cfg : Config) do
         Worker_Cfg := Cfg;
      end Init;

      select
         Shutdown_Handlers.Shutdown_Handler.Wait;
      then abort
         declare
            CRLF : constant String := [ASCII.CR, ASCII.LF];

            Cfg : constant TLS.Configs.Config := TLS.Configs.Init (Worker_Cfg.Cert_File.Element, Worker_Cfg.Key_File.Element);
            Ctx : TLS.Contexts.Servers.Server_Context := TLS.Contexts.Servers.Init (Cfg);

            Child_Ctx : TLS.Contexts.Context;

            Buffer : Streams.Stream_Element_Array (1 .. 1024);
            Last : Streams.Stream_Element_Offset;
         begin
            loop
               declare
                  use type Streams.Stream_Element_Offset;
               begin
                  Socket_Queues.Socket_Queue.Dequeue (Client_Socket);

                  Ctx.Accept_Socket (Child_Ctx, Client_Socket);

                  Child_Ctx.Read (Buffer, Last);

                  declare
                     Request_Line : constant String := TLS.Streams.To_String (Buffer (Buffer'First .. Last));
                     Request : Requests.Request;
                  begin
                     Request := Requests.Parse (Request_Line);

                     Log (Info, Request.Path);

                     Child_Ctx.Write (TLS.Streams.To_Elements ("20 text/gemini" & CRLF));
                     Child_Ctx.Write (TLS.Streams.To_Elements ("# Hello from Twins!" & CRLF));
                  exception
                     when E : Requests.Parse_Error =>
                        Log (Error, E.Exception_Message);
                        Child_Ctx.Write (TLS.Streams.To_Elements ("59 Bad Request" & CRLF));
                  end;

                  Child_Ctx.Close;
                  Sockets.Close_Socket (Client_Socket);
                  Client_Socket := Sockets.No_Socket;
               end;
            end loop;
         end;
      end select;

      if Client_Socket /= Sockets.No_Socket then
         Sockets.Close_Socket (Client_Socket);
      end if;
   end Worker;
end Twins.Workers;
