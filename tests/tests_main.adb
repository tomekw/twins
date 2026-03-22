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
   Test_Runner.Add ("Raises Parse_Error on embedded CRLF", Requests_Tests.Test_Embedded_CRLF'Access);
   Test_Runner.Add ("Raises Parse_Error on path traversal", Requests_Tests.Test_Path_Traversal'Access);
   Test_Runner.Add ("Raises Parse_Error on encoded path traversal", Requests_Tests.Test_Encoded_Path_Traversal'Access);
   Test_Runner.Add ("Raises Parse_Error on mixed encoded path traversal", Requests_Tests.Test_Mixed_Encoded_Path_Traversal'Access);
   Test_Runner.Add ("Raises Parse_Error on dot segment", Requests_Tests.Test_Dot_Segment'Access);
   Test_Runner.Add ("Raises Parse_Error on encoded dot segment", Requests_Tests.Test_Encoded_Dot_Segment'Access);
   Test_Runner.Add ("Returns Request on valid request with port", Requests_Tests.Test_Valid_With_Port'Access);
   Test_Runner.Add ("Returns Request on valid request with query", Requests_Tests.Test_Valid_With_Query'Access);
   Test_Runner.Add ("Returns Request on max length request", Requests_Tests.Test_Valid_Max_Length'Access);
   Test_Runner.Add ("Raises Parse_Error on invalid percent encoding", Requests_Tests.Test_Invalid_Percent_Encoding'Access);
   Test_Runner.Add ("Returns Request on valid percent-encoded path", Requests_Tests.Test_Valid_Percent_Encoded'Access);
   Test_Runner.Add ("Raises Parse_Error on uppercase encoded traversal", Requests_Tests.Test_Uppercase_Encoded_Traversal'Access);
   Test_Runner.Add ("Raises Parse_Error on encoded slash traversal", Requests_Tests.Test_Encoded_Slash_Traversal'Access);

   Test_Runner.Run (Test_Reporter);
end Tests_Main;
