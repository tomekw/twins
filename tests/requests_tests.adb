with Twins.Requests;

package body Requests_Tests is
   use Twins;

   CRLF : constant String := [ASCII.CR, ASCII.LF];

   procedure Test_Valid_Request (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://example.com/" & CRLF);
      Expected_Line : constant String := "gemini://example.com/";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_Request;

   procedure Empty_Request is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("");
   end Empty_Request;

   procedure Test_Empty_Request (T : in out Test_Context) is
   begin
      T.Expect_Raises (Empty_Request'Access, Requests.Parse_Error'Identity, "request doesn't start with gemini://");
   end Test_Empty_Request;

   procedure Too_Long_Request is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://" & [1 .. 1014 => 'a'] & CRLF);
   end Too_Long_Request;

   procedure Test_Too_Long_Request (T : in out Test_Context) is
   begin
      T.Expect_Raises (Too_Long_Request'Access, Requests.Parse_Error'Identity, "request too long");
   end Test_Too_Long_Request;

   procedure Wrong_Scheme is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("https://example.com" & CRLF);
   end Wrong_Scheme;

   procedure Test_Wrong_Scheme (T : in out Test_Context) is
   begin
      T.Expect_Raises (Wrong_Scheme'Access, Requests.Parse_Error'Identity, "request doesn't start with gemini://");
   end Test_Wrong_Scheme;

   procedure No_End_CRLF is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://example.com" & CRLF & "foo");
   end No_End_CRLF;

   procedure Test_No_End_CRLF (T : in out Test_Context) is
   begin
      T.Expect_Raises (No_End_CRLF'Access, Requests.Parse_Error'Identity, "request doesn't end with \r\n");
   end Test_No_End_CRLF;
end Requests_Tests;
