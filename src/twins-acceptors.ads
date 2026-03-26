with Twins.Configs;

package Twins.Acceptors is
   task type Acceptor is
      entry Init (Cfg : Configs.Config);
   end Acceptor;
end Twins.Acceptors;
