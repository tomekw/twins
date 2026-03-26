with Twins.Configs;

package Twins.Workers is
   task type Worker is
      entry Init (Cfg : Configs.Config);
   end Worker;
end Twins.Workers;
