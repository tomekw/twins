with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Directories;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Strings.Equal_Case_Insensitive;
with Ada.Strings.Hash_Case_Insensitive;
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

   package Extension_To_Mime_Type_Maps is new Containers.Indefinite_Hashed_Maps
      (Key_Type => String,
       Element_Type => String,
       Hash => Strings.Hash_Case_Insensitive,
       Equivalent_Keys => Strings.Equal_Case_Insensitive);

   Extension_To_Mime_Types : constant Extension_To_Mime_Type_Maps.Map :=
      ["gmi" => "text/gemini",
       "txt" => "text/plain",
       "md" => "text/markdown",
       "png" => "image/png",
       "jpg" => "image/jpeg",
       "jpeg" => "image/jpeg",
       "gif" => "image/gif"];

   CRLF : constant String := [ASCII.CR, ASCII.LF];

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

                     Log (Info, Request.Content_Path);

                     declare
                        Content_Full_Path : constant String := Worker_Cfg.Content_Root.Element & "/" & Request.Content_Path;
                        Extension : constant String := Directories.Extension (Request.Content_Path);
                     begin
                        if not Directories.Exists (Content_Full_Path) or else
                           not Extension_To_Mime_Types.Contains (Extension)
                        then
                           Child_Ctx.Write (TLS.Streams.To_Elements ("51 Not Found" & CRLF));
                        else
                           declare
                              File : Streams.Stream_IO.File_Type;
                              Transfer_Buffer : Streams.Stream_Element_Array (1 .. 8192);
                              Transfer_Last : Streams.Stream_Element_Offset;

                              Mime_Type : constant String := Extension_To_Mime_Types.Element (Extension);
                           begin
                              Streams.Stream_IO.Open (File, Streams.Stream_IO.In_File, Content_Full_Path);

                              Child_Ctx.Write (TLS.Streams.To_Elements ("20 " & Mime_Type & CRLF));

                              loop
                                 Streams.Stream_IO.Read (File, Transfer_Buffer, Transfer_Last);
                                 exit when Transfer_Last < Transfer_Buffer'First;
                                 Child_Ctx.Write (Transfer_Buffer (Transfer_Buffer'First .. Transfer_Last));
                              end loop;

                              Streams.Stream_IO.Close (File);
                           end;
                        end if;
                     end;
                  exception
                     when E : Requests.Parse_Error =>
                        Log (Error, E.Exception_Message);
                        Child_Ctx.Write (TLS.Streams.To_Elements ("59 Bad Request" & CRLF));
                  end;

                  Child_Ctx.Close;
                  Sockets.Close_Socket (Client_Socket);
                  Client_Socket := Sockets.No_Socket;
               exception
                  when Streams.Stream_IO.Name_Error | Streams.Stream_IO.Use_Error =>
                     Log (Error, "Unable to open file");

                     begin
                        Child_Ctx.Write (TLS.Streams.To_Elements ("40 Temporary Failure" & CRLF));
                        Child_Ctx.Close;
                        Sockets.Close_Socket (Client_Socket);
                        Client_Socket := Sockets.No_Socket;
                     exception
                        when Cleanup_E : others =>
                           Log (Error, Cleanup_E.Exception_Message);
                     end;
                  when E : others =>
                     Log (Error, E.Exception_Message);

                     begin
                        Child_Ctx.Close;
                        Sockets.Close_Socket (Client_Socket);
                        Client_Socket := Sockets.No_Socket;
                     exception
                        when Cleanup_E : others =>
                           Log (Error, Cleanup_E.Exception_Message);
                     end;
               end;
            end loop;
         end;
      end select;

      if Client_Socket /= Sockets.No_Socket then
         Sockets.Close_Socket (Client_Socket);
      end if;
   end Worker;
end Twins.Workers;
