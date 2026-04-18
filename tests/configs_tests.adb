with GNAT.Sockets;

with Tackle.Opts;
with Twins.Configs;

package body Configs_Tests is
   use GNAT;
   use Twins;
   use Tackle;
   use Tackle.Opts;

   use type Sockets.Port_Type;

   procedure Test_Valid_Arguments (T : in out Test_Context) is
      Arguments : constant Opts.Argument_List :=
         ["-H", "example.com", "-p", "1024", "-r", "resources/gemini/content",
          "-c", "resources/gemini/cert.pem", "-k", "resources/gemini/key.pem",
          "-w", "4"];
      Result : constant Opts.Result := Opts.Parse (Arguments, Configs.Options);

      Actual : constant Configs.Config := Configs.Parse (Result);
   begin
      T.Expect (Actual.Hostname = "example.com", "Hostname: expected: example.com, got: " & Actual.Hostname);
      T.Expect (Actual.Port = 1024, "Port: expected: 1024, got:" & Actual.Port'Image);
      T.Expect (Actual.Content_Root = "resources/gemini/content", "Content_Root: expected: resources/gemini/content, got: " & Actual.Content_Root);
      T.Expect (Actual.Cert_File = "resources/gemini/cert.pem", "Cert_File: expected: resources/gemini/cert.pem, got: " & Actual.Cert_File);
      T.Expect (Actual.Key_File = "resources/gemini/key.pem", "Key_File: expected: resources/gemini/key.pem, got: " & Actual.Key_File);
      T.Expect (Actual.Workers_Count = 4, "Workers_Count: expected: 4, got:" & Actual.Workers_Count'Image);
   end Test_Valid_Arguments;

   procedure Invalid_Port is
      Arguments : constant Argument_List := ["--port", "foo"];
      Result : constant Opts.Result := Opts.Parse (Arguments, Configs.Options);

      Unused_Config : Configs.Config;
   begin
      Unused_Config := Configs.Parse (Result);
   end Invalid_Port;

   procedure Test_Invalid_Port (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Port'Access, Configs.Config_Error'Identity, "invalid port: foo");
   end Test_Invalid_Port;

   procedure Invalid_Root is
      Arguments : constant Argument_List := ["--root", "/does/not/exist"];
      Result : constant Opts.Result := Opts.Parse (Arguments, Configs.Options);

      Unused_Config : Configs.Config;
   begin
      Unused_Config := Configs.Parse (Result);
   end Invalid_Root;

   procedure Test_Invalid_Root (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Root'Access, Configs.Config_Error'Identity, "invalid root: /does/not/exist");
   end Test_Invalid_Root;

   procedure Invalid_Cert_File is
      Arguments : constant Argument_List := ["--root", "resources/gemini/content", "--cert", "foo.pem"];
      Result : constant Opts.Result := Opts.Parse (Arguments, Configs.Options);

      Unused_Config : Configs.Config;
   begin
      Unused_Config := Configs.Parse (Result);
   end Invalid_Cert_File;

   procedure Test_Invalid_Cert_File (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Cert_File'Access, Configs.Config_Error'Identity, "invalid cert file: foo.pem");
   end Test_Invalid_Cert_File;

   procedure Invalid_Key_File is
      Arguments : constant Argument_List := ["--root", "resources/gemini/content", "--cert", "resources/gemini/cert.pem",
                                             "--key", "foo.pem"];
      Result : constant Opts.Result := Opts.Parse (Arguments, Configs.Options);

      Unused_Config : Configs.Config;
   begin
      Unused_Config := Configs.Parse (Result);
   end Invalid_Key_File;

   procedure Test_Invalid_Key_File (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Key_File'Access, Configs.Config_Error'Identity, "invalid key file: foo.pem");
   end Test_Invalid_Key_File;

   procedure Invalid_Workers_Count is
      Arguments : constant Argument_List := ["--root", "resources/gemini/content", "--cert", "resources/gemini/cert.pem",
                                             "--key", "resources/gemini/key.pem", "-w", "foo"];
      Result : constant Opts.Result := Opts.Parse (Arguments, Configs.Options);

      Unused_Config : Configs.Config;
   begin
      Unused_Config := Configs.Parse (Result);
   end Invalid_Workers_Count;

   procedure Test_Invalid_Workers_Count (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Workers_Count'Access, Configs.Config_Error'Identity, "invalid workers count: foo");
   end Test_Invalid_Workers_Count;
end Configs_Tests;
