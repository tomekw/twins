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
   procedure CRLF_Only is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse (CRLF);
   end CRLF_Only;

   procedure Test_CRLF_Only (T : in out Test_Context) is
   begin
      T.Expect_Raises (CRLF_Only'Access, Requests.Parse_Error'Identity, "request doesn't start with gemini://");
   end Test_CRLF_Only;

   procedure Garbage_Input is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("hello" & CRLF);
   end Garbage_Input;

   procedure Test_Garbage_Input (T : in out Test_Context) is
   begin
      T.Expect_Raises (Garbage_Input'Access, Requests.Parse_Error'Identity, "request doesn't start with gemini://");
   end Test_Garbage_Input;

   procedure Uppercase_Scheme is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("GEMINI://example.com/" & CRLF);
   end Uppercase_Scheme;

   procedure Test_Uppercase_Scheme (T : in out Test_Context) is
   begin
      T.Expect_Raises (Uppercase_Scheme'Access, Requests.Parse_Error'Identity, "request doesn't start with gemini://");
   end Test_Uppercase_Scheme;

   procedure Leading_Space_Scheme is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse (" gemini://example.com/" & CRLF);
   end Leading_Space_Scheme;

   procedure Test_Leading_Space_Scheme (T : in out Test_Context) is
   begin
      T.Expect_Raises (Leading_Space_Scheme'Access, Requests.Parse_Error'Identity, "request doesn't start with gemini://");
   end Test_Leading_Space_Scheme;

   procedure No_Line_Ending is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://example.com/");
   end No_Line_Ending;

   procedure Test_No_Line_Ending (T : in out Test_Context) is
   begin
      T.Expect_Raises (No_Line_Ending'Access, Requests.Parse_Error'Identity, "request doesn't end with \r\n");
   end Test_No_Line_Ending;

   procedure LF_Only_Ending is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://example.com/" & ASCII.LF);
   end LF_Only_Ending;

   procedure Test_LF_Only_Ending (T : in out Test_Context) is
   begin
      T.Expect_Raises (LF_Only_Ending'Access, Requests.Parse_Error'Identity, "request doesn't end with \r\n");
   end Test_LF_Only_Ending;

   procedure CR_Only_Ending is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://example.com/" & ASCII.CR);
   end CR_Only_Ending;

   procedure Test_CR_Only_Ending (T : in out Test_Context) is
   begin
      T.Expect_Raises (CR_Only_Ending'Access, Requests.Parse_Error'Identity, "request doesn't end with \r\n");
   end Test_CR_Only_Ending;

   procedure Bare_Dotdot is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/.." & CRLF);
   end Bare_Dotdot;

   procedure Test_Bare_Dotdot (T : in out Test_Context) is
   begin
      T.Expect_Raises (Bare_Dotdot'Access, Requests.Parse_Error'Identity, "path contains ..");
   end Test_Bare_Dotdot;

   procedure Bare_Dot is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/." & CRLF);
   end Bare_Dot;

   procedure Test_Bare_Dot (T : in out Test_Context) is
   begin
      T.Expect_Raises (Bare_Dot'Access, Requests.Parse_Error'Identity, "path contains . segment");
   end Test_Bare_Dot;

   procedure Uppercase_Encoded_Dot is
      Unused_Request : Requests.Request;
   begin
      Unused_Request := Requests.Parse ("gemini://host/%2E/foo" & CRLF);
   end Uppercase_Encoded_Dot;

   procedure Test_Uppercase_Encoded_Dot (T : in out Test_Context) is
   begin
      T.Expect_Raises (Uppercase_Encoded_Dot'Access, Requests.Parse_Error'Identity, "path contains . segment");
   end Test_Uppercase_Encoded_Dot;

   procedure Test_Valid_No_Path (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host" & CRLF);
      Expected_Line : constant String := "gemini://host";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_No_Path;

   procedure Test_Valid_Fragment (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/foo#section" & CRLF);
      Expected_Line : constant String := "gemini://host/foo#section";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_Fragment;

   procedure Test_Valid_Query_Fragment (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/foo?q=1#frag" & CRLF);
      Expected_Line : constant String := "gemini://host/foo?q=1#frag";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_Query_Fragment;

   procedure Test_Valid_UTF8_Encoded (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/caf%C3%A9" & CRLF);
      Expected_Line : constant String := "gemini://host/caf%C3%A9";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_UTF8_Encoded;

   procedure Test_Valid_Encoded_Regular_Char (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/%66oo" & CRLF);
      Expected_Line : constant String := "gemini://host/%66oo";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_Encoded_Regular_Char;

   procedure Test_Valid_Dotdot_Prefix (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/..foo" & CRLF);
      Expected_Line : constant String := "gemini://host/..foo";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_Dotdot_Prefix;

   procedure Test_Valid_Dotdot_Middle (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/foo..bar" & CRLF);
      Expected_Line : constant String := "gemini://host/foo..bar";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_Dotdot_Middle;

   procedure Test_Valid_Dotdot_Suffix (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/foo.." & CRLF);
      Expected_Line : constant String := "gemini://host/foo..";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_Dotdot_Suffix;

   procedure Test_Valid_Dotfile (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/.hidden" & CRLF);
      Expected_Line : constant String := "gemini://host/.hidden";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_Dotfile;

   procedure Test_Valid_Nested_Dotfile (T : in out Test_Context) is
      Request : constant Requests.Request := Requests.Parse ("gemini://host/foo/.hidden" & CRLF);
      Expected_Line : constant String := "gemini://host/foo/.hidden";
   begin
      T.Expect (Request.Line = Expected_Line, "Expected: '" & Expected_Line & "', got: '" & Request.Line & "'");
   end Test_Valid_Nested_Dotfile;
end Requests_Tests;
