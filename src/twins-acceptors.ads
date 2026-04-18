with GNAT.Sockets;

with Twins.Configs;

package Twins.Acceptors is
   type Selector_Access is access all Sockets.Selector_Type;

   procedure Shutdown;

   task type Acceptor is
      entry Init (Cfg : Configs.Config);
   end Acceptor;
end Twins.Acceptors;
