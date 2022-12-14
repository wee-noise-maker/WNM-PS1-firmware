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

with WNM_Configuration;
with WNM_HAL;

with WNM.Sample_Stream;
with WNM.Speech;

with WNM.MIDI;

private with Ada.Unchecked_Conversion;

package WNM.Coproc is

   type Message_Kind is (Sampler_Event,
                         Speech_Event,
                         Speech_CC_Event,
                         Track_Vol_Pan,
                         MIDI_Event)
     with Size => 4;

   subtype MIDI_Event_Rec is MIDI.Message;

   type Message (Kind : Message_Kind := Sampler_Event) is record
      case Kind is
         when Sampler_Event =>
            Sampler_Evt : Sample_Stream.Sampler_Event_Rec;

         when Speech_Event =>
            Speech_Evt : Speech.Speech_Event_Rec;

         when Speech_CC_Event =>
            Speech_CC_Evt : Speech.Speech_CC_Event_Rec;

         when Track_Vol_Pan =>
            TVP_Track : Tracks;
            TVP_Vol : WNM_HAL.Audio_Volume;
            TVP_Pan : WNM_HAL.Audio_Pan;

         when MIDI_Event =>
            MIDI_Evt : MIDI_Event_Rec;
      end case;
   end record
     with Size => WNM_Configuration.Coproc_Data_Size;

   for Message use record
      Kind        at 0 range 0 .. 3;
      Sampler_Evt at 0 range 6 .. 31;
      Speech_Evt  at 0 range 6 .. 31;
      MIDI_Evt    at 0 range 6 .. 31;
   end record;

   procedure Push (Msg : Message);
   --  Send a message to the synth coprocessor. Fails silently if the message
   --  cannot be pushed (e.g. queue is full).

   procedure Pop (Msg : out Message; Success : out Boolean);
   --  Tentatively get a message for the synth coprocessor. Success is False
   --  if no message is available.

private

   function To_Coproc_Data
   is new Ada.Unchecked_Conversion (Message, WNM_HAL.Coproc_Data);

   function From_Coproc_Data
   is new Ada.Unchecked_Conversion (WNM_HAL.Coproc_Data, Message);

end WNM.Coproc;
