-------------------------------------------------------------------------------
--                                                                           --
--                              Wee Noise Maker                              --
--                                                                           --
--                     Copyright (C) 2022 Fabien Chouteau                    --
--                                                                           --
--    Wee Noise Maker is free software: you can redistribute it and/or       --
--    modify it under the terms of the GNU General Public License as         --
--    published by the Free Software Foundation, either version 3 of the     --
--    License, or (at your option) any later version.                        --
--                                                                           --
--    Wee Noise Maker is distributed in the hope that it will be useful,     --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of         --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU       --
--    General Public License for more details.                               --
--                                                                           --
--    You should have received a copy of the GNU General Public License      --
--    along with We Noise Maker. If not, see <http://www.gnu.org/licenses/>. --
--                                                                           --
-------------------------------------------------------------------------------

with HAL;

private package WNM.Project.Storage.File_Out is

   type Instance
   is tagged limited
   private;

   function Open (Filename : String) return Instance;

   procedure Close (This : in out Instance);

   function Status (This : Instance) return Storage_Error;

   procedure Start_Global (This : in out Instance);

   procedure Start_Chord_Settings (This : in out Instance; C : Chords);
   procedure Start_Track_Settings (This : in out Instance; T : Tracks);

   procedure Start_Sequence (This : in out Instance);
   procedure Start_Step_Settings (This : in out Instance;
                                  S : Sequencer_Steps);
   procedure Change_Pattern_In_Seq (This : in out Instance; P : Patterns);
   procedure Change_Track_In_Seq (This : in out Instance; T : Tracks);
   procedure End_Section (This : in out Instance);
   procedure End_File (This : in out Instance);

   generic
      type T is (<>);
   procedure Push_Gen (This : in out Instance; A : T);

   procedure Push (This : in out Instance; A : HAL.UInt32);
   procedure Push (This : in out Instance; A : Character);
   procedure Push (This : in out Instance; A : String);
   procedure Push (This : in out Instance; A : Beat_Per_Minute);
   procedure Push (This : in out Instance; A : Step_Settings);
   procedure Push (This : in out Instance; A : Track_Settings);
   procedure Push (This : in out Instance; A : Chord_Setting_Kind);

private

   type Instance
   is tagged limited
           record
              Error : Storage_Error := Ok;
           end record;

   procedure Push (This : in out Instance; A : Token_Kind);

end WNM.Project.Storage.File_Out;
