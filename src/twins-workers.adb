with Ada.Streams;
with GNAT.Sockets;

with Padlock.Configs;
with Padlock.Contexts;
with Padlock.Contexts.Servers;
with Padlock.Streams;

with Twins.Socket_Queues;

package body Twins.Workers is
   use GNAT;

   package TLS renames Padlock;

   task body Worker is
      Worker_Cfg : Config;
   begin
      accept Init (Cfg : Config) do
         Worker_Cfg := Cfg;
      end Init;

      declare
         CRLF : constant String := ASCII.CR & ASCII.LF;

         Cfg : constant TLS.Configs.Config := TLS.Configs.Init (Worker_Cfg.Cert_File.Element, Worker_Cfg.Key_File.Element);
         Ctx : TLS.Contexts.Servers.Server_Context := TLS.Contexts.Servers.Init (Cfg);

         Client_Socket : Sockets.Socket_Type;
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

               Log_Line ("Request: " & TLS.Streams.To_String (Buffer (Buffer'First .. Last)));

               Child_Ctx.Write (TLS.Streams.To_Elements ("20 text/gemini" & CRLF));
               Child_Ctx.Write (TLS.Streams.To_Elements ("# Hello from Twins!" & CRLF));

               Child_Ctx.Close;
               Sockets.Close_Socket (Client_Socket);
            end;
         end loop;
      end;
   end Worker;
end Twins.Workers;
