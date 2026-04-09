with Twins.Opts;

package body Opts_Tests is
   use Twins;
   use Twins.Opts;

   Options : constant Options_List := [Argument ("hostname", 'H', "Server hostname (default: localhost)"),
                                       Argument ("port",     'p', "Server port (default: 1965)"),
                                       Argument ("root",     'r', "Content root (default: ""content"" in the current directory)"),
                                       Argument ("cert",     'c', "TLS certificate path (default: ""cert.pem"" in the current directory)"),
                                       Argument ("key",      'k', "TLS key path (default: ""key.pem"" in the current directory)"),
                                       Flag     ("help",     'h', "Print this message")];

   procedure Test_Valid_Options (T : in out Test_Context) is
      Arguments : constant Opts.Arguments_List :=
         ["-H", "example.com", "-p", "1024", "-r", "/var/gemini",
          "-c", "/etc/ssl/certs/cert.pem", "-k", "/etc/ssl/certs/key.pem", "--help"];
      Cmd : constant Opts.Command := Opts.Parse (Options, Arguments);
   begin
      T.Expect (Cmd.Argument ("hostname") = "example.com", "Hostname: expected example.com, got: " & Cmd.Argument ("hostname"));
      T.Expect (Cmd.Argument ("port") = "1024", "Port: expected 1024, got: " & Cmd.Argument ("port"));
      T.Expect (Cmd.Argument ("root") = "/var/gemini", "Content root: expected /var/gemini, got: " & Cmd.Argument ("root"));
      T.Expect (Cmd.Argument ("cert") = "/etc/ssl/certs/cert.pem", "Cert file: expected /etc/ssl/certs/cert.pem, got: " & Cmd.Argument ("cert"));
      T.Expect (Cmd.Argument ("key") = "/etc/ssl/certs/key.pem", "Key file: expected /etc/ssl/certs/key.pem, got: " & Cmd.Argument ("key"));

      T.Expect (Cmd.Has_Flag ("help"), "Help: expected flag to be set");
   end Test_Valid_Options;

   procedure Invalid_Option is
      Arguments : constant Opts.Arguments_List := ["--foo"];
      Unused_Cmd : Opts.Command;
   begin
      Unused_Cmd := Opts.Parse (Options, Arguments);
   end Invalid_Option;

   procedure Test_Invalid_Option (T : in out Test_Context) is
   begin
      T.Expect_Raises (Invalid_Option'Access, Option_Error'Identity, "unrecognized option: foo");
   end Test_Invalid_Option;

   procedure Missing_Argument is
      Arguments : constant Opts.Arguments_List := ["--hostname"];
      Unused_Cmd : Opts.Command;
   begin
      Unused_Cmd := Opts.Parse (Options, Arguments);
   end Missing_Argument;

   procedure Test_Missing_Argument (T : in out Test_Context) is
   begin
      T.Expect_Raises (Missing_Argument'Access, Option_Error'Identity, "option 'hostname' requires an argument");
   end Test_Missing_Argument;

   procedure Missing_Arguments is
      Arguments : constant Opts.Arguments_List := ["--hostname", "--port"];
      Unused_Cmd : Opts.Command;
   begin
      Unused_Cmd := Opts.Parse (Options, Arguments);
   end Missing_Arguments;

   procedure Test_Missing_Arguments (T : in out Test_Context) is
   begin
      T.Expect_Raises (Missing_Arguments'Access, Option_Error'Identity, "option 'hostname' requires an argument");
   end Test_Missing_Arguments;
end Opts_Tests;
