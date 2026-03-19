package body Twins_Tests is
   procedure True_Is_True (T : in out Test_Context) is
   begin
      T.Expect (True, "expected True");
   end True_Is_True;
end Twins_Tests;
