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

   procedure Empty_Host_With_Path is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini:///path" & CRLF);
   end Empty_Host_With_Path;

   procedure Test_Empty_Host_With_Path (T : in out Test_Context) is
   begin
      T.Expect_Raises (Empty_Host_With_Path'Access, Requests.Parse_Error'Identity, "host is empty");
   end Test_Empty_Host_With_Path;

   procedure Empty_Host_Bare is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini:///" & CRLF);
   end Empty_Host_Bare;

   procedure Test_Empty_Host_Bare (T : in out Test_Context) is
   begin
      T.Expect_Raises (Empty_Host_Bare'Access, Requests.Parse_Error'Identity, "host is empty");
   end Test_Empty_Host_Bare;

   procedure Empty_Host_With_Port is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://:1965/path" & CRLF);
   end Empty_Host_With_Port;

   procedure Test_Empty_Host_With_Port (T : in out Test_Context) is
   begin
      T.Expect_Raises (Empty_Host_With_Port'Access, Requests.Parse_Error'Identity, "host is empty");
   end Test_Empty_Host_With_Port;

   procedure Invalid_Percent_Encoding is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/foo%zz" & CRLF);
   end Invalid_Percent_Encoding;

   procedure Test_Invalid_Percent_Encoding (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Percent_Encoding'Access, Requests.Parse_Error'Identity, "invalid percent encoding");
   end Test_Invalid_Percent_Encoding;

   procedure Test_Valid_Percent_Encoded (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/foo%20bar" & CRLF);
      Expected_Line : constant String := "gemini://host/foo%20bar";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_Percent_Encoded;

   procedure Uppercase_Encoded_Traversal is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/%2E%2E/bar" & CRLF);
   end Uppercase_Encoded_Traversal;

   procedure Test_Uppercase_Encoded_Traversal (T : in out Test_Context) is
   begin
      T.Expect_Raises (Uppercase_Encoded_Traversal'Access, Requests.Parse_Error'Identity, "path contains ..");
   end Test_Uppercase_Encoded_Traversal;

   procedure Encoded_Slash_Traversal is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/foo%2f..%2fbar" & CRLF);
   end Encoded_Slash_Traversal;

   procedure Test_Encoded_Slash_Traversal (T : in out Test_Context) is
   begin
      T.Expect_Raises (Encoded_Slash_Traversal'Access, Requests.Parse_Error'Identity, "path contains ..");
   end Test_Encoded_Slash_Traversal;
end Requests_Tests;
