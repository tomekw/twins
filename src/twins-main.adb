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

      Arguments : constant Opts.Argument_List := Opts.Consume_Arguments;
      Result : constant Opts.Result := Opts.Parse (Arguments, Configs.Options);
   begin
      if Result.Has_Flag ("help") then
         Opts.Print_Usage ("twins", Configs.Options);
         Loggers.Shutdown;

         return;
      end if;

      declare
         Cfg : constant Configs.Config := Configs.Parse (Result);
      begin
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

      Loggers.Shutdown;
   exception
      when E : others =>
         Loggers.Shutdown;

         Text_IO.Put_Line (Text_IO.Standard_Error, "twins: " & Exceptions.Exception_Message (E));
         Text_IO.New_Line (Text_IO.Standard_Error);
         Text_IO.Put_Line (Text_IO.Standard_Error, "Run 'twins --help' for usage.");
         Command_Line.Set_Exit_Status (Command_Line.Failure);
   end;
end Twins.Main;
