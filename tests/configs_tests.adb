with GNAT.Sockets;

with Twins.Configs;
with Twins.Opts;

package body Configs_Tests is
   use GNAT;
   use Twins;
   use Twins.Opts;

   use type Sockets.Port_Type;

   Options : constant Options_List := [Argument ("hostname", 'H', "Server hostname (default: localhost)"),
                                       Argument ("port",     'p', "Server port (default: 1965)"),
                                       Argument ("root",     'r', "Content root (default: ""content"" in the current directory)"),
                                       Argument ("cert",     'c', "TLS certificate path (default: ""cert.pem"" in the current directory)"),
                                       Argument ("key",      'k', "TLS key path (default: ""key.pem"" in the current directory)"),
                                       Flag     ("help",     'h', "Print this message")];

   procedure Test_Valid_Arguments (T : in out Test_Context) is
      Arguments : constant Opts.Arguments_List :=
         ["-H", "example.com", "-p", "1024", "-r", "resources/gemini/content",
          "-c", "resources/gemini/cert.pem", "-k", "resources/gemini/key.pem"];
      Cmd : constant Opts.Command := Opts.Parse (Options, Arguments);

      Actual : constant Configs.Config := Configs.Parse (Cmd);
   begin
      T.Expect (Actual.Hostname = "example.com", "Hostname: expected: example.com, got: " & Actual.Hostname);
      T.Expect (Actual.Port = 1024, "Port: expected: 1024, got:" & Actual.Port'Image);
      T.Expect (Actual.Content_Root = "resources/gemini/content", "Content_Root: expected: resources/gemini/content, got: " & Actual.Content_Root);
      T.Expect (Actual.Cert_File = "resources/gemini/cert.pem", "Cert_File: expected: resources/gemini/cert.pem, got: " & Actual.Cert_File);
      T.Expect (Actual.Key_File = "resources/gemini/key.pem", "Key_File: expected: resources/gemini/key.pem, got: " & Actual.Key_File);
   end Test_Valid_Arguments;

   procedure Invalid_Port is
      Arguments : constant Arguments_List := ["--port", "foo"];
      Cmd : constant Command := Opts.Parse (Options, Arguments);

      Unused_Config : Configs.Config;
   begin
      Unused_Config := Configs.Parse (Cmd);
   end Invalid_Port;

   procedure Test_Invalid_Port (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Port'Access, Configs.Config_Error'Identity, "invalid port: foo");
   end Test_Invalid_Port;

   procedure Invalid_Root is
      Arguments : constant Arguments_List := ["--root", "/does/not/exist"];
      Cmd : constant Command := Opts.Parse (Options, Arguments);

      Unused_Config : Configs.Config;
   begin
      Unused_Config := Configs.Parse (Cmd);
   end Invalid_Root;

   procedure Test_Invalid_Root (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Root'Access, Configs.Config_Error'Identity, "invalid root: /does/not/exist");
   end Test_Invalid_Root;

   procedure Invalid_Cert_File is
      Arguments : constant Arguments_List := ["--root", "resources/gemini/content", "--cert", "foo.pem"];
      Cmd : constant Command := Opts.Parse (Options, Arguments);

      Unused_Config : Configs.Config;
   begin
      Unused_Config := Configs.Parse (Cmd);
   end Invalid_Cert_File;

   procedure Test_Invalid_Cert_File (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Cert_File'Access, Configs.Config_Error'Identity, "invalid cert file: foo.pem");
   end Test_Invalid_Cert_File;

   procedure Invalid_Key_File is
      Arguments : constant Arguments_List := ["--root", "resources/gemini/content", "--cert", "resources/gemini/cert.pem",
                                              "--key", "foo.pem"];
      Cmd : constant Command := Opts.Parse (Options, Arguments);

      Unused_Config : Configs.Config;
   begin
      Unused_Config := Configs.Parse (Cmd);
   end Invalid_Key_File;

   procedure Test_Invalid_Key_File (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Key_File'Access, Configs.Config_Error'Identity, "invalid key file: foo.pem");
   end Test_Invalid_Key_File;
end Configs_Tests;
