package body Twins.Shutdown_Handlers is
   protected body Shutdown_Handler is
      entry Wait when Shutdown is
      begin
         null;
      end Wait;

      function Shutdown_Requested return Boolean is
      begin
         return Shutdown;
      end Shutdown_Requested;

      procedure Handle_SIGINT is
      begin
         Shutdown := True;
      end Handle_SIGINT;

      procedure Handle_SIGTERM is
      begin
         Shutdown := True;
      end Handle_SIGTERM;
   end Shutdown_Handler;
end Twins.Shutdown_Handlers;
