with GNAT.Sockets;

package Twins.Acceptors is
   use GNAT;

   type Config is record
      Hostname : String_Holders.Holder;
      Server_Port : Sockets.Port_Type;
   end record;

   task type Acceptor is
      entry Init (Cfg : Config);
   end Acceptor;
end Twins.Acceptors;
