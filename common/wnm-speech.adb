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

with Interfaces;

with WNM.Speech_Dictionary;

package body WNM.Speech is

   LPC_Out : LPC_Synth.Out_Array (Mono_Buffer'Range);
   LPC_Arr : array (Tracks) of LPC_Synth.Instance;
   Pitch : array (Tracks) of Float :=
     (others => MIDI.Key_To_Frequency (MIDI.C4));

   Stretch : array (Tracks) of LPC_Synth.Time_Stretch_Factor
     := (others => MIDI_To_Stretch (No_Strech_MIDI_Val));

   ---------
   -- Img --
   ---------

   function Img (W : Word) return String
   is (WNM.Speech_Dictionary.Image (W).all);

   -----------
   -- Start --
   -----------

   procedure Start (T : Tracks; W : Word; K : MIDI.MIDI_Key) is
   begin
      LPC_Synth.Set_Data (LPC_Arr (T), WNM.Speech_Dictionary.Data (W));
      Pitch (T) := MIDI.Key_To_Frequency (K);
   end Start;

   ----------
   -- Stop --
   ----------

   procedure Stop (T : Tracks) is
   begin
      null;
   end Stop;

   -----------------
   -- Set_Stretch --
   -----------------

   procedure Set_Stretch (T : Tracks; V : MIDI.MIDI_Data) is
   begin
      Stretch (T) := MIDI_To_Stretch (V);
   end Set_Stretch;

   -----------------
   -- Next_Points --
   -----------------

   procedure Next_Points (Buffer : in out WNM_HAL.Stereo_Buffer) is
      use Interfaces;

      Val : Integer_32;
   begin
      for T in Tracks loop
         declare
            LPC : LPC_Synth.Instance renames LPC_Arr (T);
         begin
            if LPC_Synth.Has_Data (LPC) then
               LPC_Synth.Next_Points
                 (LPC, LPC_Out,
                  Sample_Rate => WNM_Configuration.Audio.Sample_Frequency,
                  Pitch => Pitch (T),
                  Time_Stretch => Stretch (T));

               for Idx in Buffer'Range loop
                  Val :=
                    Integer_32 (Buffer (Idx).L) + Integer_32 (LPC_Out (Idx));
                  if Val > Integer_32 (Mono_Point'Last) then
                     Buffer (Idx).L := Mono_Point'Last;
                  elsif Val < Integer_32 (Mono_Point'First) then
                     Buffer (Idx).L := Mono_Point'First;
                  else
                     Buffer (Idx).L := Mono_Point (Val);
                  end if;

                  Val :=
                    Integer_32 (Buffer (Idx).R) + Integer_32 (LPC_Out (Idx));
                  if Val > Integer_32 (Mono_Point'Last) then
                     Buffer (Idx).R := Mono_Point'Last;
                  elsif Val < Integer_32 (Mono_Point'First) then
                     Buffer (Idx).R := Mono_Point'First;
                  else
                     Buffer (Idx).R := Mono_Point (Val);
                  end if;
               end loop;
            end if;
         end;
      end loop;
   end Next_Points;

end WNM.Speech;
