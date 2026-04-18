with Testy.Tests;

package Configs_Tests is
   use Testy.Tests;

   procedure Test_Valid_Arguments (T : in out Test_Context);
   procedure Test_Invalid_Port (T : in out Test_Context);
   procedure Test_Invalid_Root (T : in out Test_Context);
   procedure Test_Invalid_Cert_File (T : in out Test_Context);
   procedure Test_Invalid_Key_File (T : in out Test_Context);
   procedure Test_Invalid_Workers_Count (T : in out Test_Context);
end Configs_Tests;
