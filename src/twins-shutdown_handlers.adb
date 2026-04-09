package body Twins.Shutdown_Handlers is
   protected body Shutdown_Handler is
      entry Wait when Perform_Shutdown is
      begin
         null;
      end Wait;

      entry Shutdown when not Perform_Shutdown is
      begin
         Perform_Shutdown := True;
      end Shutdown;

      function Shutdown_Requested return Boolean is
      begin
         return Perform_Shutdown;
      end Shutdown_Requested;

      procedure Handle_SIGINT is
      begin
         Perform_Shutdown := True;
      end Handle_SIGINT;

      procedure Handle_SIGTERM is
      begin
         Perform_Shutdown := True;
      end Handle_SIGTERM;
   end Shutdown_Handler;
end Twins.Shutdown_Handlers;
