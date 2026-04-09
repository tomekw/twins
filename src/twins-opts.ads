with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Hash;
with Ada.Strings.Text_Buffers;

package Twins.Opts is
   package Argument_Vectors is new Containers.Indefinite_Vectors
      (Index_Type => Positive,
       Element_Type => String);

   subtype Arguments_List is Argument_Vectors.Vector;

   Option_Error : exception;

   type Option is private
      with Put_Image => Option_Put_Image;

   procedure Option_Put_Image
      (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
       Value : Option);

   type Options_List is array (Positive range <>) of Option;

   type Command is private;

   function Consume_Arguments return Arguments_List;

   function Argument (Long_Name : String; Short_Name : Character; Description : String) return Option;
   function Flag (Long_Name : String; Short_Name : Character; Description : String) return Option;

   procedure Print_Usage (Program_Name : String; Options : Options_List);

   function Parse (Options : Options_List; Arguments : Arguments_List) return Command;

   function Argument (Cmd : Command; Key : String; Default : String := "") return String;
   function Has_Flag (Cmd : Command; Key : String) return Boolean;

private

   type Option_Kind is (Argument, Flag);

   type Option is record
      Kind : Option_Kind;
      Long_Name_Holder : String_Holders.Holder;
      Short_Name_Holder : Character;
      Description_Holder : String_Holders.Holder;
   end record;

   type Parsed_Option (Kind : Option_Kind) is record
      case Kind is
         when Argument =>
            Value : String_Holders.Holder;
         when Flag =>
            null;
      end case;
   end record;

   package Command_Params_Maps is new Ada.Containers.Indefinite_Hashed_Maps
      (Key_Type => String,
       Element_Type => Parsed_Option,
       Hash => Ada.Strings.Hash,
       Equivalent_Keys => "=");

   type Command is record
      Params : Command_Params_Maps.Map;
   end record;
end Twins.Opts;
