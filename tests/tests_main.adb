with Testy.Runners;
with Testy.Reporters.Text;

with Twins_Tests;

procedure Tests_Main is
   use Testy;

   Test_Runner : Runners.Runner := Runners.Create;
   Test_Reporter : Reporters.Text.Text_Reporter;
begin
   Test_Runner.Add ("True is True", Twins_Tests.True_Is_True'Access);

   Test_Runner.Run (Test_Reporter);
end Tests_Main;
