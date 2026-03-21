with Testy.Tests;

package Requests_Tests is
   use Testy.Tests;

   procedure Test_Valid_Request (T : in out Test_Context);
   procedure Test_Empty_Request (T : in out Test_Context);
   procedure Test_Too_Long_Request (T : in out Test_Context);
   procedure Test_Wrong_Scheme (T : in out Test_Context);
   procedure Test_No_End_CRLF (T : in out Test_Context);
end Requests_Tests;
