with Testy.Runners;
with Testy.Reporters.Text;

with Requests_Tests;
with Configs_Tests;

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
   Test_Runner.Add ("Raises Parse_Error on empty host with path", Requests_Tests.Test_Empty_Host_With_Path'Access);
   Test_Runner.Add ("Raises Parse_Error on empty host bare", Requests_Tests.Test_Empty_Host_Bare'Access);
   Test_Runner.Add ("Raises Parse_Error on empty host with port", Requests_Tests.Test_Empty_Host_With_Port'Access);
   Test_Runner.Add ("Raises Parse_Error on invalid percent encoding", Requests_Tests.Test_Invalid_Percent_Encoding'Access);
   Test_Runner.Add ("Returns Request on valid percent-encoded path", Requests_Tests.Test_Valid_Percent_Encoded'Access);
   Test_Runner.Add ("Raises Parse_Error on uppercase encoded traversal", Requests_Tests.Test_Uppercase_Encoded_Traversal'Access);
   Test_Runner.Add ("Raises Parse_Error on encoded slash traversal", Requests_Tests.Test_Encoded_Slash_Traversal'Access);

   Test_Runner.Add ("Rejects CRLF only", Requests_Tests.Test_CRLF_Only'Access);
   Test_Runner.Add ("Rejects garbage input", Requests_Tests.Test_Garbage_Input'Access);
   Test_Runner.Add ("Rejects uppercase scheme", Requests_Tests.Test_Uppercase_Scheme'Access);
   Test_Runner.Add ("Rejects leading space in scheme", Requests_Tests.Test_Leading_Space_Scheme'Access);
   Test_Runner.Add ("Rejects no line ending", Requests_Tests.Test_No_Line_Ending'Access);
   Test_Runner.Add ("Rejects LF only ending", Requests_Tests.Test_LF_Only_Ending'Access);
   Test_Runner.Add ("Rejects CR only ending", Requests_Tests.Test_CR_Only_Ending'Access);
   Test_Runner.Add ("Rejects bare .. at end of path", Requests_Tests.Test_Bare_Dotdot'Access);
   Test_Runner.Add ("Rejects bare . at end of path", Requests_Tests.Test_Bare_Dot'Access);
   Test_Runner.Add ("Rejects uppercase encoded dot segment", Requests_Tests.Test_Uppercase_Encoded_Dot'Access);
   Test_Runner.Add ("Valid request with no path", Requests_Tests.Test_Valid_No_Path'Access);
   Test_Runner.Add ("Valid request with fragment", Requests_Tests.Test_Valid_Fragment'Access);
   Test_Runner.Add ("Valid request with query and fragment", Requests_Tests.Test_Valid_Query_Fragment'Access);
   Test_Runner.Add ("Valid request with UTF-8 percent encoding", Requests_Tests.Test_Valid_UTF8_Encoded'Access);
   Test_Runner.Add ("Valid request with encoded regular char", Requests_Tests.Test_Valid_Encoded_Regular_Char'Access);
   Test_Runner.Add ("Valid .. as filename prefix", Requests_Tests.Test_Valid_Dotdot_Prefix'Access);
   Test_Runner.Add ("Valid .. in middle of filename", Requests_Tests.Test_Valid_Dotdot_Middle'Access);
   Test_Runner.Add ("Valid .. as filename suffix", Requests_Tests.Test_Valid_Dotdot_Suffix'Access);
   Test_Runner.Add ("Valid dotfile", Requests_Tests.Test_Valid_Dotfile'Access);
   Test_Runner.Add ("Valid nested dotfile", Requests_Tests.Test_Valid_Nested_Dotfile'Access);

   Test_Runner.Add ("Content_Path for empty path", Requests_Tests.Test_Content_Path_Empty'Access);
   Test_Runner.Add ("Content_Path for trailing slash", Requests_Tests.Test_Content_Path_Trailing_Slash'Access);
   Test_Runner.Add ("Content_Path for no extension", Requests_Tests.Test_Content_Path_No_Extension'Access);
   Test_Runner.Add ("Content_Path with extension", Requests_Tests.Test_Content_Path_With_Extension'Access);
   Test_Runner.Add ("Content_Path nested with extension", Requests_Tests.Test_Content_Path_Nested_With_Extension'Access);
   Test_Runner.Add ("Content_Path root level file", Requests_Tests.Test_Content_Path_Root_Level_File'Access);
   Test_Runner.Add ("Content_Path nested no extension", Requests_Tests.Test_Content_Path_Nested_No_Extension'Access);

   Test_Runner.Add ("No options return default Config", Configs_Tests.Test_Default_Options'Access);
   Test_Runner.Add ("Valid arguments return Config", Configs_Tests.Test_Valid_Arguments'Access);

   Test_Runner.Run (Test_Reporter);
end Tests_Main;
