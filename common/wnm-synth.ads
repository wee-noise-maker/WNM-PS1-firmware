-------------------------------------------------------------------------------
--                                                                           --
--                              Wee Noise Maker                              --
--                                                                           --
--                  Copyright (C) 2016-2017 Fabien Chouteau                  --
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

with Interfaces;

with WNM_HAL;

with WNM.Time;
with WNM.Sample_Library;
with WNM.Sample_Stream;
with WNM.MIDI;

with Tresses;

package WNM.Synth is

   type Sample_Time is new Interfaces.Unsigned_64;

   function Sample_Clock return Sample_Time;
   --  How many audio samples have been sent to the DAC so far.
   --  This number can be used to count time between two events.

   procedure Trig (Track  : Sample_Stream.Stream_Track;
                   Sample : Sample_Library.Valid_Sample_Index);

   function Update return WNM.Time.Time_Microseconds;

   procedure Next_Points (Output : out WNM_HAL.Stereo_Buffer;
                          Input  :     WNM_HAL.Stereo_Buffer);

   procedure Set_Passthrough (Kind : Audio_Input_Kind);
   function Get_Passthrough return Audio_Input_Kind;

   -----------
   -- Synth --
   -----------

   function Lead_Engine_Img (Engine : MIDI.MIDI_Data) return String;
   function Lead_Param_Label (Engine : MIDI.MIDI_Data;
                              Id : Tresses.Param_Id)
                              return String;
   function Lead_Param_Short_Label (Engine : MIDI.MIDI_Data;
                                    Id : Tresses.Param_Id)
                                    return Tresses.Short_Label;

   function Kick_Param_Label (Id : Tresses.Param_Id)
                              return String;
   function Kick_Param_Short_Label (Id : Tresses.Param_Id)
                                    return Tresses.Short_Label;

   function Snare_Param_Label (Id : Tresses.Param_Id)
                               return String;
   function Snare_Param_Short_Label (Id : Tresses.Param_Id)
                                     return Tresses.Short_Label;

   function Cymbal_Param_Label (Id : Tresses.Param_Id)
                                return String;
   function Cymbal_Param_Short_Label (Id : Tresses.Param_Id)
                                      return Tresses.Short_Label;

   ---------------
   -- Recording --
   ---------------

   type Rec_Source is (None, Line_In, Master_Output);

   function Now_Recording return Rec_Source;

   procedure Start_Recording (Filename : String;
                              Source   : Rec_Source;
                              Max_Size : Positive)
     with Pre => Now_Recording = None and then Source /= None;

   procedure Stop_Recording
     with Post => Now_Recording = None;

   function Record_Size return Natural;
   --  with Pre => Now_Recording /= None;

end WNM.Synth;
