with GNAT.Sockets;

with Twins.CL_Arguments;
with Twins.Configs;

package body Configs_Tests is
   use GNAT;
   use Twins;

   use type Sockets.Port_Type;

   procedure Test_Valid_Arguments (T : in out Test_Context) is
      Arguments : constant CL_Arguments.Argument_List.Vector :=
         ["--hostname", "example.com", "--port", "1965", "--content-root", "/var/gemini",
          "--cert-file", "/etc/ssl/certs/cert.pem", "--key-file", "/etc/ssl/certs/key.pem"];

      Actual : constant Configs.Config := Configs.Parse (Arguments);
   begin
      T.Expect (Actual.Hostname = "example.com", "Hostname: expected: example.com, got: " & Actual.Hostname);
      T.Expect (Actual.Port = 1965, "Port: expected: 1965, got:" & Actual.Port'Image);
      T.Expect (Actual.Content_Root = "/var/gemini", "Content_Root: expected: /var/gemini, got: " & Actual.Content_Root);
      T.Expect (Actual.Cert_File = "/etc/ssl/certs/cert.pem", "Cert_File: expected: /etc/ssl/certs/cert.pem, got: " & Actual.Cert_File);
      T.Expect (Actual.Key_File = "/etc/ssl/certs/key.pem", "Key_File: expected: /etc/ssl/certs/key.pem, got: " & Actual.Key_File);
   end Test_Valid_Arguments;
end Configs_Tests;
