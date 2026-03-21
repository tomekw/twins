package Twins.Loggers is
   type Log_Level is (Info, Warning, Error);

   procedure Log (Level : Log_Level; Message : String);
end Twins.Loggers;
