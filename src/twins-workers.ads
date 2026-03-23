package Twins.Workers is
   type Config is record
      Cert_File : String_Holders.Holder;
      Key_File : String_Holders.Holder;
      Content_Root : String_Holders.Holder;
   end record;

   task type Worker is
      entry Init (Cfg : Config);
   end Worker;
end Twins.Workers;
