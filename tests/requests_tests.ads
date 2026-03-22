with Testy.Tests;

package Requests_Tests is
   use Testy.Tests;

   procedure Test_Valid_Request (T : in out Test_Context);
   procedure Test_Empty_Request (T : in out Test_Context);
   procedure Test_Too_Long_Request (T : in out Test_Context);
   procedure Test_Wrong_Scheme (T : in out Test_Context);
   procedure Test_No_End_CRLF (T : in out Test_Context);
   procedure Test_Embedded_CRLF (T : in out Test_Context);
   procedure Test_Path_Traversal (T : in out Test_Context);
   procedure Test_Encoded_Path_Traversal (T : in out Test_Context);
   procedure Test_Mixed_Encoded_Path_Traversal (T : in out Test_Context);
   procedure Test_Dot_Segment (T : in out Test_Context);
   procedure Test_Encoded_Dot_Segment (T : in out Test_Context);
   procedure Test_Valid_With_Port (T : in out Test_Context);
   procedure Test_Valid_With_Query (T : in out Test_Context);
   procedure Test_Valid_Max_Length (T : in out Test_Context);
   procedure Test_Invalid_Percent_Encoding (T : in out Test_Context);
   procedure Test_Valid_Percent_Encoded (T : in out Test_Context);
   procedure Test_Uppercase_Encoded_Traversal (T : in out Test_Context);
   procedure Test_Encoded_Slash_Traversal (T : in out Test_Context);
end Requests_Tests;
