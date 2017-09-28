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

--  Hold record to enter sequencer mode. Move between steps with an encoder
--  The current step number is shown on the screen. Press a note to add/remove
--  it to/from the current step. Active notes for this step are shown with the
--  LEDs. Press the current chan to erase the squence.

with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;
with WNM.Sequencer;                use WNM.Sequencer;
with WNM.Encoders;                 use WNM.Encoders;
with Quick_Synth;                  use Quick_Synth;
with WNM.Master_Volume;
with WNM.Pattern_Sequencer;
with WNM.GUI.Menu;
with WNM.GUI.Menu.Root;
with WNM.LED;

package body WNM.UI is

   UI_Task_Start   : Suspension_Object;

   procedure Signal_Event (B : Buttons; Evt : Buttton_Event);

   procedure Set_FX (B : Buttons);

   Default_Input_Mode : constant Input_Mode_Type := Note;

   FX_Is_On : array (Buttons) of Boolean := (others => False);
   Current_Input_Mode : Input_Mode_Type := Note;

   Editting_Step : Sequencer_Steps := 1;

   ----------------
   -- Input_Mode --
   ----------------

   function Input_Mode return Input_Mode_Type
   is (Current_Input_Mode);

   ------------------
   -- Signal_Event --
   ------------------

   procedure Signal_Event (B : Buttons; Evt : Buttton_Event) is
   begin
      if GUI.Menu.In_Menu and then Evt = On_Press then
         if B = Encoder_L then
            GUI.Menu.On_Event ((Kind => GUI.Menu.Left_Press));
            return;
         end if;

         if B = Encoder_R then
            GUI.Menu.On_Event ((Kind => GUI.Menu.Right_Press));
            return;
         end if;
      end if;

      case Current_Input_Mode is
         when Note =>
            case Evt is
               when On_Press =>
                  case B is
                     when FX =>
                        --  Switch to FX mode
                        Current_Input_Mode := FX_Select;
                     when Play =>
                        Sequencer.Play_Pause;
                     when Rec =>
                        Sequencer.Rec_Pressed;
                     when Keyboard_Buttons =>
                        Sequencer.On_Press (B);
                     when Track_B =>
                        Current_Input_Mode := Track_Select;
                     when Track_C =>
                        Current_Input_Mode := Pattern_Select;
                     when Track_E =>
                        if not GUI.Menu.In_Menu then
                           GUI.Menu.Root.Push_Root_Window;
                        end if;
                     when others => null;
                  end case;
               when On_Long_Press =>
                  case B is
                     when Play =>
                        --  Switch to volume/BPM config mode
                        Current_Input_Mode := Volume_BPM;
                     when Rec =>
                        --  Switch to squence edition mode
                        Sequencer.Rec_Long;
                     when B1 .. B16 =>
                        Current_Input_Mode := Trig_Edit;
                        Editting_Step := To_Value (B);
                     when others => null;
                  end case;
               when On_Release =>
                  case B is
                     when Keyboard_Buttons =>
                        --  Release note or octave Up/Down
                        Sequencer.On_Release (B);
                     when Rec =>
                        Sequencer.Rec_Release;
                     when others => null;
                  end case;
               when others => null;
            end case;

         when Volume_BPM =>
            if B = Play and Evt = On_Release then
               Current_Input_Mode := Default_Input_Mode;
               WNM.Pattern_Sequencer.End_Sequence_Edit;
            end if;

            if B in B1 .. B16 and Evt = On_Press then
               Quick_Synth.Toggle_Mute (B);
            end if;
         when FX_Select =>
            case Evt is
               when On_Press =>
                  case B is
                     when B1 .. B16 =>
                        Set_FX (B);
                     when others =>
                        null;
                  end case;
               when On_Release =>
                  if B = FX then
                     Current_Input_Mode := Default_Input_Mode;
                  end if;
               when others =>
                  null;
            end case;

         when Track_Select =>
            if B in B1 .. B16 and then Evt = On_Press then
               Sequencer.Select_Track (B);
            elsif B = Track_B and then Evt = On_Release then
               Current_Input_Mode := Default_Input_Mode;
            end if;
         when Pattern_Select =>
            if B in B1 .. B16 and then Evt = On_Press then
               Pattern_Sequencer.Add_To_Sequence (B);
            elsif B = Track_C and then Evt = On_Release then
               Pattern_Sequencer.End_Sequence_Edit;
               Current_Input_Mode := Default_Input_Mode;
            end if;
         when Trig_Edit =>
            if To_Value (B) = Editting_Step and then Evt = On_Release then
               Current_Input_Mode := Default_Input_Mode;
            end if;
      end case;
   end Signal_Event;

   ------------
   -- Set_FX --
   ------------

   procedure Set_FX (B : Buttons) is
   begin
      FX_Is_On (B) := not FX_Is_On (B);
   end Set_FX;

   -----------
   -- Start --
   -----------

   procedure Start is
      Config : GPIO_Port_Configuration;
   begin

      Config.Speed := Speed_2MHz;

      -- Buttons --

      Config.Mode := Mode_In;
      Config.Output_Type := Push_Pull;
      Config.Resistors := Pull_Up;

      for Pt of Key_To_Point loop
         Enable_Clock (Pt);
         Pt.Configure_IO (Config);
      end loop;

      Enable_Clock (Wakeup);
      Config.Mode := Mode_Out;
      Config.Output_Type := Push_Pull;
      Config.Resistors := Floating;
      Wakeup.Configure_IO (Config);
      Wakeup.Clear;

      Set_True (UI_Task_Start);
   end Start;

   ----------------
   -- Is_Pressed --
   ----------------

   function Is_Pressed (B : Buttons) return Boolean is
      (Key_State (B) = Down);

   ---------------------------
   -- Current_Editting_Trig --
   ---------------------------

   function Current_Editting_Trig return Sequencer_Steps
   is (Editting_Step);

   --------------------
   -- Has_Long_Press --
   --------------------

   function Has_Long_Press (Button : Buttons) return Boolean is
      In_Edit : constant Boolean := Sequencer.State in Play_And_Edit | Edit;
   begin
      return (case Button is
              when B1        => In_Edit,
              when B2        => In_Edit,
              when B3        => In_Edit,
              when B4        => In_Edit,
              when B5        => In_Edit,
              when B6        => In_Edit,
              when B7        => In_Edit,
              when B8        => In_Edit,
              when B9        => In_Edit,
              when B10       => In_Edit,
              when B11       => In_Edit,
              when B12       => In_Edit,
              when B13       => In_Edit,
              when B14       => In_Edit,
              when B15       => In_Edit,
              when B16       => In_Edit,
              when Rec       => True,
              when Play      => True,
              when FX        => False,
              when Track_A   => False,
              when Track_B   => False,
              when Track_C   => False,
              when Track_D   => False,
              when Track_E   => False,
              when Encoder_L => True,
              when Encoder_R => True);
   end Has_Long_Press;

   -------------
   -- UI_Task --
   -------------

   task UI_Task is
      pragma Priority (UI_Task_Priority);
      pragma Storage_Size (UI_Task_Stack_Size);
      pragma Secondary_Stack_Size (UI_Task_Secondary_Stack_Size);
   end UI_Task;

   task body UI_Task is
      Period     : Time_Span renames UI_Task_Period;

      Next_Start : Time;
      Now        : Time renames Next_Start;
      Last_State    : array (Buttons) of Raw_Key_State := (others => Up);
      Pressed_Since : array (Buttons) of Time := (others => Time_First);
      Last_Event    : array (Buttons) of Buttton_Event := (others => On_Release);

      L_Enco : Integer;
      R_Enco : Integer;
   begin
      Suspend_Until_True (UI_Task_Start);

      Next_Start := Clock;
      loop

         --  Call the sequencer that may have something to do
         Sequencer.Execute_Step;

         Next_Start := Next_Start + Period;
         delay until Next_Start;

         --  Handle buttons
         for B in Buttons loop
            Key_State (B) := (if Key_To_Point (B).Set then Up else Down);

            if Last_State (B) = Key_State (B) then
               --  The button didn't change, let's check if we are waiting for
               --  a long press event.
               if Has_Long_Press (B)
                 and then
                   Key_State (B) = Down
                 and then
                   Last_Event (B) = Waiting_For_Long_Press
                 and then
                   Pressed_Since (B) + Long_Press_Time_Span < Now
               then
                  Last_Event (B) := On_Long_Press;
                  Signal_Event (B, Last_Event (B));
               end if;

            elsif Key_State (B) = Down then
               --  Button was justed pressed

               if Has_Long_Press (B) then
                  --  If this button has long press event we don't signal the
                  --  On_Press right now, but we record the time at wich it was
                  --  pressed.

                  Last_Event (B) := Waiting_For_Long_Press;
                  Pressed_Since (B) := Now;
               else
                  Last_Event (B) := On_Press;
                  Signal_Event (B, Last_Event (B));
               end if;
            else
               --  Button was just released

               if Last_Event (B) = Waiting_For_Long_Press then
                  --  The button was released before we reached the long press
                  --  delay. It was not a long press after all so we first send
                  --  The On_Press event and then the On_Realease.
                  Signal_Event (B, On_Press);
               end if;

               Last_Event (B) := On_Release;
               Signal_Event (B, Last_Event (B));
            end if;

            Last_State (B) := Key_State (B);
         end loop;

         --------------
         -- Encoders --
         --------------

         L_Enco := WNM.Encoders.Left_Diff;
         R_Enco := WNM.Encoders.Right_Diff;

         if GUI.Menu.In_Menu then
            if L_Enco /= 0 then
               GUI.Menu.On_Event ((Kind  => GUI.Menu.Encoder_Left,
                                   Value => L_Enco));
            end if;
            if R_Enco /= 0 then
               GUI.Menu.On_Event ((Kind  => GUI.Menu.Encoder_Right,
                                   Value => R_Enco));
            end if;
         else
            case Current_Input_Mode is
            when Volume_BPM =>
               WNM.Sequencer.Change_BPM (R_Enco * 5);
               WNM.Master_Volume.Change (L_Enco * 5);
            when Track_Select =>
               Quick_Synth.Change_Pan (Sequencer.Track, R_Enco * 10);
               Quick_Synth.Change_Volume (Sequencer.Track, L_Enco * 10);
            when Trig_Edit =>
               if L_Enco > 0 then
                  WNM.Sequencer.Trig_Next (Editting_Step);
               elsif L_Enco < 0 then
                  WNM.Sequencer.Trig_Prev (Editting_Step);
               end if;
            when others =>
               null;
            end case;
         end if;

         --------------
         -- Set LEDs --
         --------------

         LED.Turn_Off_All;

         -- Play LED --
         if Sequencer.State not in Pause | Edit then
            LED.Turn_On (Play);
            if Sequencer.Step in 1 | 5 | 9 | 13 then
               LED.Turn_On (Play);
            end if;
         end if;

         -- Rec LED --
         if Sequencer.State = Edit
           or else
            Sequencer.State in Play_And_Rec | Play_And_Edit
         then
            LED.Turn_On (Rec);
         end if;

         --  B1 .. B16 LEDs --
         case Current_Input_Mode is

            -- FX selection mode --
            when FX_Select =>
               --  The FX LED will be on if there's at least one FX enabled

               for B in B4 .. B8 loop
                  FX_Is_On (B) := (Quick_Synth.In_Solo
                                   and then
                                   Quick_Synth.Solo = (case B is
                                        when B4 => Track_A,
                                        when B5 => Track_B,
                                        when B6 => Track_C,
                                        when B7 => Track_D,
                                        when others => Track_E));
               end loop;

               for B in B1 .. B16 loop
                  if FX_Is_On (B) then
                     LED.Turn_On (B);
                     LED.Turn_On (FX);
                  end if;
               end loop;

            -- Track assign mode --
            when Track_Select =>
               for B in B1 .. B16 loop
                  if Sequencer.Track = B then
                     LED.Turn_On (B);
                  end if;
               end loop;

            --  Pattern select --
            when Pattern_Select =>
               for B in B1 .. B16 loop
                  if Pattern_Sequencer.Current_Pattern = B then
                     LED.Turn_On (B);
                  end if;
                  if Pattern_Sequencer.Is_In_Pattern_Sequence (B) then
                     LED.Turn_On (B);
                  end if;
               end loop;

            --  Volume and BPM mode --
            when Volume_BPM =>
               for B in B1 .. B16 loop
                  if not Quick_Synth.Muted (B) then
                     LED.Turn_On (B);
                  end if;
               end loop;

            --  Any other mode --
            when others =>
               case Sequencer.State is
                  when Edit | Play_And_Edit =>
                        for B in B1 .. B16 loop
                           if Sequencer.Set (To_Value (B)) then
                              LED.Turn_On (B);
                           end if;
                        end loop;
                  when Play | Play_And_Rec =>
                     for B in B1 .. B16 loop
                        if Sequencer.Set (B, Sequencer.Step) then
                           LED.Turn_On (B);
                        end if;
                     end loop;
                  when others =>
                     null;
               end case;
         end case;

         if Sequencer.State in Play_And_Edit | Play_And_Rec | Play then
            LED.Turn_On (To_Button (Sequencer.Step));
         end if;
      end loop;
   end UI_Task;

end WNM.UI;
