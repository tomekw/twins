with Ada.Directories;
with Ada.Streams;
with Ada.Strings.Equal_Case_Insensitive;
with Ada.Streams.Stream_IO;
with GNAT.Sockets;

with Padlock.Configs;
with Padlock.Contexts;
with Padlock.Contexts.Servers;
with Padlock.Streams;

with Tackle.MIME;

with Twins.Loggers;
with Twins.Requests;
with Twins.Socket_Queues;

package body Twins.Workers is
   use Tackle;
   use Twins.Loggers;

   package TLS renames Padlock;

   CRLF : constant String := [ASCII.CR, ASCII.LF];

   function Request_Log_Line (Content_Path : String; Client_IP : String; Status : String) return String is
   begin
      return Content_Path & " " & Client_IP & " " & Status;
   end Request_Log_Line;

   procedure Shutdown (Count : Positive) is
   begin
      for Unused_I in 1 .. Count loop
         Socket_Queues.Socket_Queue.Enqueue (Sockets.No_Socket);
      end loop;
   end Shutdown;

   task body Worker is
      use type Sockets.Socket_Type;

      Worker_Cfg : Configs.Config;
      Client_Socket : Sockets.Socket_Type := Sockets.No_Socket;
   begin
      accept Init (Cfg : Configs.Config) do
         Worker_Cfg := Cfg;
      end Init;

      declare
         Cfg : constant TLS.Configs.Config := TLS.Configs.Init (Worker_Cfg.Cert_File, Worker_Cfg.Key_File);
         Ctx : TLS.Contexts.Servers.Server_Context := TLS.Contexts.Servers.Init (Cfg);

         Child_Ctx : TLS.Contexts.Context;

         Buffer : Streams.Stream_Element_Array (1 .. 1026);
         Last : Streams.Stream_Element_Offset;

         Mime_DB : constant MIME.Database := MIME.Init;

         procedure Close_Sockets is
         begin
            Child_Ctx.Close;
            Sockets.Close_Socket (Client_Socket);
            Client_Socket := Sockets.No_Socket;
         end Close_Sockets;
      begin
         loop
            declare
               use type Streams.Stream_Element_Offset;
            begin
               Socket_Queues.Socket_Queue.Dequeue (Client_Socket);

               if Client_Socket = Sockets.No_Socket then
                  exit;
               end if;

               Ctx.Accept_Socket (Child_Ctx, Client_Socket);

               Child_Ctx.Read (Buffer, Last);

               declare
                  Client_IP : constant String := Sockets.Image (Sockets.Get_Peer_Name (Client_Socket).Addr);
                  Request_Line : constant String := TLS.Streams.To_String (Buffer (Buffer'First .. Last));
                  Request : Requests.Request;
               begin
                  Request := Requests.Parse (Request_Line);

                  if not Strings.Equal_Case_Insensitive (Request.Host, Worker_Cfg.Hostname) and then
                     not Strings.Equal_Case_Insensitive (Request.Host, Worker_Cfg.Hostname & ":" & Image (Worker_Cfg.Port))
                  then
                     declare
                        Response : constant String := "53 Proxy Request Refused";
                     begin
                        Log (Error, Request_Log_Line (Request.Content_Path, Client_IP, Response));
                        Child_Ctx.Write (TLS.Streams.To_Elements (Response & CRLF));
                     end;
                  else
                     declare
                        Content_Full_Path : constant String := Worker_Cfg.Content_Root & "/" & Request.Content_Path;
                     begin
                        if not Directories.Exists (Content_Full_Path) then
                           declare
                              Response : constant String := "51 Not Found";
                           begin
                              Log (Info, Request_Log_Line (Request.Content_Path, Client_IP, Response));
                              Child_Ctx.Write (TLS.Streams.To_Elements (Response & CRLF));
                           end;
                        else
                           declare
                              File : Streams.Stream_IO.File_Type;
                              Transfer_Buffer : Streams.Stream_Element_Array (1 .. 8192);
                              Transfer_Last : Streams.Stream_Element_Offset;

                              Extension : constant String := Directories.Extension (Request.Content_Path);
                              Mime_Type : constant String := Mime_DB.Mime_Type (Extension, "text/plain");
                           begin
                              Streams.Stream_IO.Open (File, Streams.Stream_IO.In_File, Content_Full_Path);

                              declare
                                 Response : constant String := "20 " & Mime_Type;
                              begin
                                 Log (Info, Request_Log_Line (Request.Content_Path, Client_IP, Response));
                                 Child_Ctx.Write (TLS.Streams.To_Elements (Response & CRLF));
                              end;

                              loop
                                 Streams.Stream_IO.Read (File, Transfer_Buffer, Transfer_Last);
                                 exit when Transfer_Last < Transfer_Buffer'First;
                                 Child_Ctx.Write (Transfer_Buffer (Transfer_Buffer'First .. Transfer_Last));
                              end loop;

                              Streams.Stream_IO.Close (File);
                           exception
                              when others =>
                                 if Streams.Stream_IO.Is_Open (File) then
                                    Streams.Stream_IO.Close (File);
                                 end if;

                                 raise;
                           end;
                        end if;
                     end;
                  end if;
               exception
                  when E : Requests.Parse_Error =>
                     declare
                        Response : constant String := "59 Bad Request";
                     begin
                        Log (Error, Client_IP & " " & Response & " " & E.Exception_Message);
                        Child_Ctx.Write (TLS.Streams.To_Elements (Response & CRLF));
                     end;
                  when E : Requests.Scheme_Error =>
                     declare
                        Response : constant String := "53 Proxy Request Refused";
                     begin
                        Log (Error, Client_IP & " " & Response & " " & E.Exception_Message);
                        Child_Ctx.Write (TLS.Streams.To_Elements (Response & CRLF));
                     end;
                  when Streams.Stream_IO.Name_Error | Streams.Stream_IO.Use_Error =>
                     begin
                        declare
                           Response : constant String := "40 Temporary Failure";
                        begin
                           Log (Error, Client_IP & " " & Response & " " & "Unable to open file");
                           Child_Ctx.Write (TLS.Streams.To_Elements (Response & CRLF));
                        end;
                     exception
                        when Cleanup_E : others =>
                           Log (Error, Cleanup_E.Exception_Message);
                     end;
               end;

               Close_Sockets;
            exception
               when E : others =>
                  Log (Error, E.Exception_Message);

                  begin
                     Close_Sockets;
                  exception
                     when Cleanup_E : others =>
                        Log (Error, Cleanup_E.Exception_Message);
                  end;
            end;
         end loop;
      end;

      if Client_Socket /= Sockets.No_Socket then
         Sockets.Close_Socket (Client_Socket);
      end if;
   end Worker;
end Twins.Workers;
