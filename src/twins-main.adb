with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO;

with Twins.Acceptors;
with Twins.Configs;
with Twins.Loggers;
with Twins.Opts;
with Twins.Shutdown_Handlers;
with Twins.Workers;

procedure Twins.Main is
   use Ada;
begin
   declare
      use Twins.Opts;

      Arguments : constant Opts.Arguments_List := Opts.Consume_Arguments;

      Options : constant Options_List := [Argument ("hostname", 'H', "Server hostname (default: localhost)"),
                                          Argument ("port",     'p', "Server port (default: 1965)"),
                                          Argument ("root",     'r', "Content root (default: ""content"" in the current directory)"),
                                          Argument ("cert",     'c', "TLS certificate path (default: ""cert.pem"" in the current directory)"),
                                          Argument ("key",      'k', "TLS key path (default: ""key.pem"" in the current directory)"),
                                          Flag     ("help",     'h', "Print this message")];

      Cmd : constant Command := Opts.Parse (Options, Arguments);
   begin
      if Cmd.Has_Flag ("help") then
         Shutdown_Handlers.Shutdown_Handler.Shutdown;
         Loggers.Shutdown;

         Opts.Print_Usage ("twins", Options);

         return;
      end if;

      declare
         Cfg : constant Configs.Config := Configs.Parse (Cmd);
         Server_Acceptor : Acceptors.Acceptor;

         Workers_Count : constant Positive := 8;
         Workers_Pool : array (1 .. Workers_Count) of Workers.Worker;
      begin
         Server_Acceptor.Init (Cfg);

         for Worker of Workers_Pool loop
            Worker.Init (Cfg);
         end loop;

         Shutdown_Handlers.Shutdown_Handler.Wait;
         Loggers.Shutdown;
      end;
   end;
exception
   when E : others =>
      Shutdown_Handlers.Shutdown_Handler.Shutdown;
      Loggers.Shutdown;

      Text_IO.Put_Line (Text_IO.Standard_Error, "twins: " & Exceptions.Exception_Message (E));
      Text_IO.New_Line (Text_IO.Standard_Error);
      Text_IO.Put_Line (Text_IO.Standard_Error, "Run 'twins --help' for usage.");
      Command_Line.Set_Exit_Status (Command_Line.Failure);
end Twins.Main;
