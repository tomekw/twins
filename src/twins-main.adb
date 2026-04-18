with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO;

with Tackle.Opts;

with Twins.Acceptors;
with Twins.Configs;
with Twins.Loggers;
with Twins.Shutdown_Handlers;
with Twins.Workers;

procedure Twins.Main is
   use Ada;
begin
   declare
      use Tackle;
      use Tackle.Opts;

      Arguments : constant Opts.Argument_List := Opts.Consume_Arguments;

      Options : constant Option_List := [Arg  ("hostname", 'H', "Server hostname (default: localhost)"),
                                         Arg  ("port",     'p', "Server port (default: 1965)"),
                                         Arg  ("root",     'r', "Content root (default: ""content"" in the current directory)"),
                                         Arg  ("cert",     'c', "TLS certificate path (default: ""cert.pem"" in the current directory)"),
                                         Arg  ("key",      'k', "TLS key path (default: ""key.pem"" in the current directory)"),
                                         Arg  ("workers",  'w', "Workers count (default: 8)"),
                                         Flag ("help",     'h', "Print this message")];

      Result : constant Opts.Result := Opts.Parse (Arguments, Options);
      Cfg : constant Configs.Config := Configs.Parse (Result);
   begin
      if Result.Has_Flag ("help") then
         Opts.Print_Usage ("twins", Options);
         Loggers.Shutdown;

         return;
      end if;

      declare
         Server_Acceptor : Acceptors.Acceptor;

         Workers_Pool : array (1 .. Cfg.Workers_Count) of Workers.Worker;
      begin
         for Worker of Workers_Pool loop
            Worker.Init (Cfg);
         end loop;

         Server_Acceptor.Init (Cfg);

         Shutdown_Handlers.Shutdown_Handler.Wait;
         Acceptors.Shutdown;
         Workers.Shutdown (Cfg.Workers_Count);
      end;

      Loggers.Shutdown;
   exception
      when E : others =>
         Acceptors.Shutdown;
         Workers.Shutdown (Cfg.Workers_Count);
         Loggers.Shutdown;

         Text_IO.Put_Line (Text_IO.Standard_Error, "twins: " & Exceptions.Exception_Message (E));
         Text_IO.New_Line (Text_IO.Standard_Error);
         Text_IO.Put_Line (Text_IO.Standard_Error, "Run 'twins --help' for usage.");
         Command_Line.Set_Exit_Status (Command_Line.Failure);
   end;
end Twins.Main;
