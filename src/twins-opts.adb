with Ada.Characters.Conversions;
with Ada.Command_Line;
with Ada.Text_IO;

package body Twins.Opts is
   function Consume_Arguments return Arguments_List is
      Arguments : Arguments_List;
   begin
      for I in 1 .. Ada.Command_Line.Argument_Count loop
         Arguments.Append (Ada.Command_Line.Argument (I));
      end loop;

      return Arguments;
   end Consume_Arguments;

   function Argument (Long_Name : String; Short_Name : Character; Description : String) return Option is
      use String_Holders;
   begin
      return (Kind => Argument,
              Long_Name_Holder => To_Holder (Long_Name),
              Short_Name_Holder => Short_Name,
              Description_Holder => To_Holder (Description));
   end Argument;

   function Flag (Long_Name : String; Short_Name : Character; Description : String) return Option is
      use String_Holders;
   begin
      return (Kind => Flag,
              Long_Name_Holder => To_Holder (Long_Name),
              Short_Name_Holder => Short_Name,
              Description_Holder => To_Holder (Description));
   end Flag;

   function Long_Name (Opt : Option) return String is
   begin
      return Opt.Long_Name_Holder.Element;
   end Long_Name;

   function Short_Name (Opt : Option) return Character is
   begin
      return Opt.Short_Name_Holder;
   end Short_Name;

   function Description (Opt : Option) return String is
   begin
      return Opt.Description_Holder.Element;
   end Description;

   procedure Option_Put_Image
      (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
       Value : Option)
   is
      use Ada.Characters.Conversions;
   begin
      Buffer.Wide_Wide_Put ("--" & To_Wide_Wide_String (Value.Long_Name));
      Buffer.Wide_Wide_Put ("|");
      Buffer.Wide_Wide_Put ("-" & To_Wide_Wide_String (String'(1 => Value.Short_Name)));

      case Value.Kind is
         when Argument =>
            Buffer.Wide_Wide_Put (" <" & To_Wide_Wide_String (Value.Long_Name) & ">");
         when Flag =>
            null;
      end case;
   end Option_Put_Image;

   procedure Print_Usage (Program_Name : String; Options : Options_List) is
      Max_Option_Length : Natural := 0;
   begin
       Text_IO.Put_Line (Text_IO.Standard_Error, "Usage: " & Program_Name & " [options]");
       Text_IO.New_Line (Text_IO.Standard_Error);
       Text_IO.Put_Line (Text_IO.Standard_Error, "Options:");

       for Opt of Options loop
          if Opt'Image'Length > Max_Option_Length then
             Max_Option_Length := Opt'Image'Length;
          end if;
       end loop;

       declare
          Column_Length : constant Positive := 4 + Max_Option_Length + 4;
       begin
          for Opt of Options loop
             Text_IO.Set_Col (Text_IO.Standard_Error, 1);
             Text_IO.Put (Text_IO.Standard_Error, "    " & Opt'Image);
             Text_IO.Set_Col (Text_IO.Standard_Error, Text_IO.Positive_Count (Column_Length));
             Text_IO.Put (Text_IO.Standard_Error, Opt.Description);
          end loop;
       end;
   end Print_Usage;

   function Overlaps (Left, Right : Option) return Boolean is
   begin
      return (Left.Long_Name = Right.Long_Name or else
              Left.Short_Name = Right.Short_Name);
   end Overlaps;

   procedure Validate (Options : Options_List) is
   begin
      for I in Options'Range loop
         for J in I + 1 .. Options'Last loop
            if Options (I).Overlaps (Options (J)) then
               raise Option_Error with "overlapping options: " & Options (I)'Image & " and " & Options (J)'Image;
            end if;
         end loop;
      end loop;
   end Validate;

   function Parse (Options : Options_List; Arguments : Arguments_List) return Command is
      use String_Holders;

      Cmd : Command;

      Current_Arg_Index : Positive := Arguments.First_Index;

      function Find_Long_Option (Name : String) return Option is
      begin
         for I in Options'Range loop
            if Options (I).Long_Name = Name then
               return Options (I);
            end if;
         end loop;

         raise Option_Error with "unrecognized option: " & Name;
      end Find_Long_Option;

      function Find_Short_Option (Name : String) return Option is
      begin
         if Name'Length /= 1 then
            raise Option_Error with "invalid option: " & Name;
         end if;

         for I in Options'Range loop
            if Options (I).Short_Name = Name (Name'First) then
               return Options (I);
            end if;
         end loop;

         raise Option_Error with "unrecognized option: " & Name;
      end Find_Short_Option;

      procedure Register_Option (Opt : Option) is
      begin
         case Opt.Kind is
            when Argument =>
               if Current_Arg_Index + 1 <= Arguments.Last_Index then
                  declare
                     Next_Arg : constant String := Arguments (Current_Arg_Index + 1);
                  begin
                     if Next_Arg'Length > 2 and then Next_Arg (Next_Arg'First) /= '-' then
                        Cmd.Params.Insert (Opt.Long_Name,
                                           (Kind => Argument, Value => To_Holder (Arguments (Current_Arg_Index + 1))));
                     else
                        raise Option_Error with "option '" & Opt.Long_Name & "' requires an argument";
                     end if;
                  end;
               else
                  raise Option_Error with "option '" & Opt.Long_Name & "' requires an argument";
               end if;

               Current_Arg_Index := Current_Arg_Index + 2;
            when Flag  =>
               Cmd.Params.Insert (Opt.Long_Name, (Kind => Flag));

               Current_Arg_Index := Current_Arg_Index + 1;
         end case;
      end Register_Option;
   begin
      Validate (Options);

      while Current_Arg_Index <= Arguments.Last_Index loop
         declare
            Arg : constant String := Arguments (Current_Arg_Index);
         begin
            if Arg'Length > 2 and then Arg (Arg'First .. Arg'First + 1) = "--" then
               Register_Option (Find_Long_Option (Arg (Arg'First + 2 .. Arg'Last)));
            elsif Arg'Length > 1 and then Arg (Arg'First) = '-' then
               Register_Option (Find_Short_Option (Arg (Arg'First + 1 .. Arg'Last)));
            else
               raise Option_Error with "unrecognized option: " & Arg;
            end if;
         end;
      end loop;

      return Cmd;
   end Parse;

   function Argument (Cmd : Command; Key : String; Default : String := "") return String is
      use Command_Params_Maps;

      C : constant Cursor := Cmd.Params.Find (Key);
   begin
      if C /= No_Element then
         declare
            Opt : constant Parsed_Option := Element (C);
         begin
            case Opt.Kind is
               when Argument =>
                  return Opt.Value.Element;
               when Flag =>
                  return Default;
            end case;
         end;
      end if;

      return Default;
   end Argument;

   function Has_Flag (Cmd : Command; Key : String) return Boolean is
      use Command_Params_Maps;

      C : constant Cursor := Cmd.Params.Find (Key);
   begin
      if C /= No_Element then
         declare
            Opt : constant Parsed_Option := Element (C);
         begin
            case Opt.Kind is
               when Argument =>
                  return False;
               when Flag =>
                  return True;
            end case;
         end;
      end if;

      return False;
   end Has_Flag;
end Twins.Opts;
