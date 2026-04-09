with Testy.Tests;

package Opts_Tests is
   use Testy.Tests;

   procedure Test_Valid_Options (T : in out Test_Context);
   procedure Test_Invalid_Option (T : in out Test_Context);
   procedure Test_Missing_Argument (T : in out Test_Context);
   procedure Test_Missing_Arguments (T : in out Test_Context);
end Opts_Tests;
