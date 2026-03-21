with Testy.Runners;
with Testy.Reporters.Text;

with Requests_Tests;

procedure Tests_Main is
   use Testy;

   Test_Runner : Runners.Runner := Runners.Create;
   Test_Reporter : Reporters.Text.Text_Reporter;
begin
   Test_Runner.Add ("Returns Request on valid request line", Requests_Tests.Test_Valid_Request'Access);
   Test_Runner.Add ("Raises Parse_Error on empty request line", Requests_Tests.Test_Empty_Request'Access);
   Test_Runner.Add ("Raises Parse_Error on too long request line", Requests_Tests.Test_Too_Long_Request'Access);
   Test_Runner.Add ("Raises Parse_Error on wrong scheme", Requests_Tests.Test_Wrong_Scheme'Access);
   Test_Runner.Add ("Raises Parse_Error on no CRLF at the end", Requests_Tests.Test_No_End_CRLF'Access);

   Test_Runner.Run (Test_Reporter);
end Tests_Main;
