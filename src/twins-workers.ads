with Twins.Configs;

package Twins.Workers is
   procedure Shutdown (Count : Positive);

   task type Worker is
      entry Init (Cfg : Configs.Config);
   end Worker;
end Twins.Workers;
