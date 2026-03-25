with Twins.Requests;

package Twins.Loggers is
   type Log_Level is (Info, Warning, Error);

   procedure Log (Level : Log_Level; Message : String);

   procedure Log_Request (Level : Log_Level; Request : Requests.Request; Client_IP : String; Status : String);
end Twins.Loggers;
