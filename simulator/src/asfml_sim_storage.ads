with System;
with Littlefs;

with GNAT.Strings;

package ASFML_SIM_Storage is

   function Load_ROM (Path : String) return String;
   --  Load ROM from a binary file.
   --  Return empty string on success, an error message otherwise

   function Create_ROM return String;
   --  Create a ROM from TOML description file
   --  Return empty string on success, an error message otherwise

   function Save_ROM (Path : String) return String;
   --  Save ROM to a binary file.
   --  Return empty string on success, an error message otherwise

   function Get_LFS_Config return not null access Littlefs.LFS_Config;

   procedure Print_FS_Tree;

   function Sample_Data_Base return System.Address;

   function ROM_Path return String;
   --  Return path to either the default ROM in user config dir or ROM path
   --  provided on the command line.

   function TOML_Path return String;
   --  Return path to either the default TOML description in resources dir or
   --  a TOML file path provided on the command line.

   Switch_Storage_ROM : aliased GNAT.Strings.String_Access;
   Switch_Storage_TOML : aliased GNAT.Strings.String_Access;
   Switch_Reset_ROM : aliased Boolean := False;

end ASFML_SIM_Storage;
