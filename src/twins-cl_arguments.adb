with Ada.Command_Line;

package body Twins.CL_Arguments is
   function Consume return Argument_List.Vector is
      Arguments : Argument_List.Vector;
   begin
      for I in 1 .. Ada.Command_Line.Argument_Count loop
         Arguments.Append (Ada.Command_Line.Argument (I));
      end loop;

      return Arguments;
   end Consume;
end Twins.CL_Arguments;
