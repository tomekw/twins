with Ada.Interrupts;
with Ada.Interrupts.Names;

package Twins.Shutdown_Handlers is
   protected Shutdown_Handler is
      entry Wait;

      function Shutdown_Requested return Boolean;

   private

      procedure Handle_SIGINT;

      procedure Handle_SIGTERM;

      pragma Unreserve_All_Interrupts;
      pragma Attach_Handler (Handle_SIGINT, Interrupts.Names.SIGINT);
      pragma Attach_Handler (Handle_SIGTERM, Interrupts.Names.SIGTERM);

      Shutdown : Boolean := False;
   end Shutdown_Handler;
end Twins.Shutdown_Handlers;
