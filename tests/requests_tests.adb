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

   procedure Embedded_CRLF is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/pa" & CRLF & "th" & CRLF);
   end Embedded_CRLF;

   procedure Test_Embedded_CRLF (T : in out Test_Context) is
   begin
      T.Expect_Raises (Embedded_CRLF'Access, Requests.Parse_Error'Identity, "request contains embedded \r\n");
   end Test_Embedded_CRLF;

   procedure Path_Traversal is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/../etc/passwd" & CRLF);
   end Path_Traversal;

   procedure Test_Path_Traversal (T : in out Test_Context) is
   begin
      T.Expect_Raises (Path_Traversal'Access, Requests.Parse_Error'Identity, "path contains ..");
   end Test_Path_Traversal;

   procedure Encoded_Path_Traversal is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/%2e%2e/bar" & CRLF);
   end Encoded_Path_Traversal;

   procedure Test_Encoded_Path_Traversal (T : in out Test_Context) is
   begin
      T.Expect_Raises (Encoded_Path_Traversal'Access, Requests.Parse_Error'Identity, "path contains ..");
   end Test_Encoded_Path_Traversal;

   procedure Mixed_Encoded_Path_Traversal is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/.%2e/bar" & CRLF);
   end Mixed_Encoded_Path_Traversal;

   procedure Test_Mixed_Encoded_Path_Traversal (T : in out Test_Context) is
   begin
      T.Expect_Raises (Mixed_Encoded_Path_Traversal'Access, Requests.Parse_Error'Identity, "path contains ..");
   end Test_Mixed_Encoded_Path_Traversal;

   procedure Dot_Segment is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/foo/./bar" & CRLF);
   end Dot_Segment;

   procedure Test_Dot_Segment (T : in out Test_Context) is
   begin
      T.Expect_Raises (Dot_Segment'Access, Requests.Parse_Error'Identity, "path contains . segment");
   end Test_Dot_Segment;

   procedure Encoded_Dot_Segment is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/foo/%2e/bar" & CRLF);
   end Encoded_Dot_Segment;

   procedure Test_Encoded_Dot_Segment (T : in out Test_Context) is
   begin
      T.Expect_Raises (Encoded_Dot_Segment'Access, Requests.Parse_Error'Identity, "path contains . segment");
   end Test_Encoded_Dot_Segment;

   procedure Test_Valid_With_Port (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host:1965/foo" & CRLF);
      Expected_Line : constant String := "gemini://host:1965/foo";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_With_Port;

   procedure Test_Valid_With_Query (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/foo?query=1" & CRLF);
      Expected_Line : constant String := "gemini://host/foo?query=1";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_With_Query;

   procedure Test_Valid_Max_Length (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://" & [1 .. 1013 => 'a'] & CRLF);
      Expected_Line : constant String := "gemini://" & [1 .. 1013 => 'a'];
   begin
      T.Expect (Request.Line = Expected_Line, "Expected length:" & Expected_Line'Length'Image & ", got:" & Request.Line'Length'Image);
   end Test_Valid_Max_Length;
end Requests_Tests;
