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

with WNM.GUI.Menu.Drawing; use WNM.GUI.Menu.Drawing;
with WNM.GUI.Popup;
with WNM.GUI.Menu.Text_Dialog;

with WNM.Utils;

package body WNM.GUI.Menu.Track_Settings is

   Track_Settings_Singleton : aliased Track_Settings_Menu;

   Valid_Top_Settings : array (Track_Mode_Kind, Top_Settings) of
     Boolean := (others => (others => False));

   Top_Settings_Count_Cache : array (Track_Mode_Kind) of Natural :=
     (others => 0);

   Top_Settings_Position_Cache : array (Track_Mode_Kind, Top_Settings) of
     Integer := (others => (others => -1));

   ------------
   -- To_Top --
   ------------

   function To_Top (S : Sub_Settings) return Top_Settings
   is (case S is
       when Project.Track_Mode => Track_Mode,
       when Project.Sample => Sample,
       when Project.Speech_Word => Speech_Word,
       when Project.Engine => Engine,
       when Project.Volume => Volume,
       when Project.Pan => Pan,
       when Project.Arp_Mode => Arp_Mode,
       when Project.Arp_Notes => Arp_Notes,
       when Project.Notes_Per_Chord => Notes_Per_Chord,
       when Project.MIDI_Chan => MIDI_Chan,
       when Project.MIDI_Instrument => MIDI_Instrument,
       when Project.CC_Default_A => CC_Default,
       when Project.CC_Default_B => CC_Default,
       when Project.CC_Default_C => CC_Default,
       when Project.CC_Default_D => CC_Default,
       when Project.CC_Ctrl_A => CC_Ctrl_A,
       when Project.CC_Label_A => CC_Label_A,
       when Project.CC_Ctrl_B => CC_Ctrl_B,
       when Project.CC_Label_B => CC_Label_B,
       when Project.CC_Ctrl_C => CC_Ctrl_C,
       when Project.CC_Label_C => CC_Label_C,
       when Project.CC_Ctrl_D => CC_Ctrl_D,
       when Project.CC_Label_D => CC_Label_D);

   -------------------------
   -- Fix_Current_Setting --
   -------------------------

   procedure Fix_Current_Setting (This : in out Track_Settings_Menu) is
   begin
      if not Valid_Setting (Mode (Editing_Track), This.Current_Setting) then
         Prev_Valid_Setting (Mode (Editing_Track), This.Current_Setting);
      end if;
   end Fix_Current_Setting;

   ------------------------
   -- Top_Settings_Count --
   ------------------------

   function Top_Settings_Count (M : Project.Track_Mode_Kind) return Positive is
   begin
      --  Computed at elaboration
      return Top_Settings_Count_Cache (M);
   end Top_Settings_Count;

   --------------------------
   -- Top_Setting_Position --
   --------------------------

   function Top_Setting_Position (S : Top_Settings;
                                  M : Project.Track_Mode_Kind)
                                  return Natural
   is
   begin
      --  Computed at elaboration
      return Top_Settings_Position_Cache (M, S);
   end Top_Setting_Position;

   ------------------------
   -- Next_Valid_Setting --
   ------------------------

   procedure Next_Valid_Setting (M : Project.Track_Mode_Kind;
                                 S : in out Sub_Settings)
   is
      Result : Sub_Settings := S;
   begin
      while Result /= Sub_Settings'Last loop
         Result := Sub_Settings'Succ (Result);
         if Valid_Setting (M, Result) then
            S := Result;
            return;
         end if;
      end loop;

      if Valid_Setting (M, Result) then
         S := Result;
      end if;
   end Next_Valid_Setting;

   ------------------------
   -- Prev_Valid_Setting --
   ------------------------

   procedure Prev_Valid_Setting (M : Project.Track_Mode_Kind;
                                 S : in out Sub_Settings)
   is
      Result : Sub_Settings := S;
   begin
      while Result /= Sub_Settings'First loop
         Result := Sub_Settings'Pred (Result);
         if Valid_Setting (M, Result) then
            S := Result;
            return;
         end if;
      end loop;

      if Valid_Setting (M, Result) then
         S := Result;
      end if;
   end Prev_Valid_Setting;

   --------------
   -- To_CC_Id --
   --------------

   function To_CC_Id (S : Sub_Settings) return Project.CC_Id
   is (case S is
          when CC_Default_A | CC_Ctrl_A | CC_Label_A => A,
          when CC_Default_B | CC_Ctrl_B | CC_Label_B => B,
          when CC_Default_C | CC_Ctrl_C | CC_Label_C => C,
          when CC_Default_D | CC_Ctrl_D | CC_Label_D => D,
          when others => raise Program_Error);

   -----------------
   -- Push_Window --
   -----------------

   procedure Push_Window is
   begin
      Push (Track_Settings_Singleton'Access);
   end Push_Window;

   ----------
   -- Draw --
   ----------

   overriding
   procedure Draw
     (This : in out Track_Settings_Menu)
   is
      Mode : Project.Track_Mode_Kind;
      Sub : Sub_Settings;
      Top : Top_Settings;
   begin
      This.Fix_Current_Setting;

      Mode := Project.Mode (Editing_Track);
      Sub := This.Current_Setting;
      Top := To_Top (This.Current_Setting);

      Draw_Menu_Box ("Track settings",
                     Count => Top_Settings_Count (Mode),
                     Index => Top_Setting_Position (Top, Mode));
      case Top is
         when Track_Mode =>
            Draw_Title ("Track mode:", "");
            Draw_Value (Img (Mode));

         when Volume =>
            Draw_Volume ("Volume:", Project.Track_Volume);

         when Pan =>
            Draw_Pan ("Pan:", Project.Track_Pan);

         when Arp_Mode =>
            Draw_Title ("Arpeggiator mode:", "");
            Draw_Value (Project.Img (Project.Arp_Mode));

         when Arp_Notes =>
            Draw_Title ("Arpeggiator notes:", "");
            Draw_Value (Project.Img (Project.Arp_Notes));

         when Notes_Per_Chord =>
            Draw_Title ("Notes per Chord:", "");
            Draw_Value (Project.Notes_Per_Chord (Editing_Track)'Img);

         when MIDI_Chan =>
            Draw_Title ("MIDI Channel:", "");
            Draw_Value (Project.MIDI_Chan (Editing_Track)'Img);

         when MIDI_Instrument =>
            Draw_Title ("MIDI instrument:", "");
            Draw_Value (Builtin_Instruments (This.Instrument).Name);

         when Sample =>

            Draw_Sample_Select (Project.Selected_Sample (Editing_Track));

         when Speech_Word =>

            Draw_Word_Select (Project.Selected_Word (Editing_Track));

         when Engine =>

            Draw_Title ("Synth Engine:", "");
            Draw_Value (Project.Selected_Engine_Img (Editing_Track));

         when CC_Default =>
            declare
               Selected : constant Project.CC_Id := To_CC_Id (Sub);
            begin

               for Id in CC_Id loop
                  Draw_CC_Value
                    (Id, Project.CC_Default (Editing_Track, Id),
                     Project.CC_Controller_Short_Label (Editing_Track, Id),
                     Id = Selected);
               end loop;

               Draw_Title
                 (Project.CC_Controller_Label (Editing_Track, Selected), "");
            end;

         when CC_Ctrl_A | CC_Ctrl_B | CC_Ctrl_C | CC_Ctrl_D =>
            declare
               CC : constant Project.CC_Id := To_CC_Id (Sub);
            begin
               Draw_Title ("MIDI CC " & Project.CC_Letter (CC) & ":", "");
               Draw_Value ("Controller:" &
                             Project.CC_Controller (Editing_Track, CC)'Img);
            end;

         when CC_Label_A | CC_Label_B | CC_Label_C | CC_Label_D =>
            declare
               CC : constant Project.CC_Id :=
                 To_CC_Id (This.Current_Setting);
            begin
               Draw_Title ("MIDI CC " & Project.CC_Letter (CC) & " Label:",
                           "");
               Draw_Value (Project.CC_Controller_Label (Editing_Track, CC));
            end;

      end case;

   end Draw;

   --------------
   -- On_Event --
   --------------

   overriding
   procedure On_Event
     (This  : in out Track_Settings_Menu;
      Event : Menu_Event)
   is
   begin
      This.Fix_Current_Setting;

      case Event.Kind is
         when Left_Press =>
            case This.Current_Setting is
               when MIDI_Instrument =>

                  --  Apply selected instrument settings
                  declare
                     I : MIDI_Instrument_Settings renames
                       Builtin_Instruments (This.Instrument);
                  begin
                     Set_CC_Controller (Editing_Track, A, I.CC_Target_A);
                     Set_CC_Controller (Editing_Track, B, I.CC_Target_B);
                     Set_CC_Controller (Editing_Track, C, I.CC_Target_C);
                     Set_CC_Controller (Editing_Track, D, I.CC_Target_D);

                     Set_CC_Controller_Label (Editing_Track, A, I.CC_A_Label);
                     Set_CC_Controller_Label (Editing_Track, B, I.CC_B_Label);
                     Set_CC_Controller_Label (Editing_Track, C, I.CC_C_Label);
                     Set_CC_Controller_Label (Editing_Track, D, I.CC_D_Label);
                  end;

               when CC_Label_A | CC_Label_B | CC_Label_C | CC_Label_D =>

                  --  Push text edit dialog

                  declare
                     CC : constant Project.CC_Id :=
                       To_CC_Id (This.Current_Setting);
                  begin
                     WNM.GUI.Menu.Text_Dialog.Set_Title
                       ("CC " & Project.CC_Letter (CC) & " Label");
                     WNM.GUI.Menu.Text_Dialog.Push_Window
                       (Project.CC_Controller_Label (Editing_Track, CC));
                  end;

               when others =>
                  null;
            end case;

         when Right_Press =>
            --  Never exit the step settings
            null;
         when Encoder_Right =>

            case This.Current_Setting is
               when MIDI_Instrument =>
                  if Event.Value > 0 then
                     if This.Instrument < Builtin_Instruments'Last then
                        This.Instrument := This.Instrument + 1;
                     end if;
                  else
                     if This.Instrument > Builtin_Instruments'First then
                        This.Instrument := This.Instrument - 1;
                     end if;
                  end if;

               when CC_Label_A | CC_Label_B | CC_Label_C | CC_Label_D =>
                  GUI.Popup.Display ("L press to edit ", 500_000);

               when CC_Default_A .. CC_Default_D =>
                  if Event.Value > 0 then
                     Project.Next_Value_Fast (This.Current_Setting);
                  else
                     Project.Prev_Value_Fast (This.Current_Setting);
                  end if;

               when others =>
                  if Event.Value > 0 then
                     Project.Next_Value (This.Current_Setting);
                  else
                     Project.Prev_Value (This.Current_Setting);
                  end if;
            end case;
         when Encoder_Left =>
            if Event.Value > 0 then
               Next_Valid_Setting (Mode (Editing_Track),
                                   This.Current_Setting);
            elsif Event.Value < 0 then
               Prev_Valid_Setting (Mode (Editing_Track),
                                   This.Current_Setting);
            end if;
      end case;
   end On_Event;

   ---------------
   -- On_Pushed --
   ---------------

   overriding
   procedure On_Pushed
     (This  : in out Track_Settings_Menu)
   is
   begin
      null;
   end On_Pushed;

   --------------
   -- On_Focus --
   --------------

   overriding
   procedure On_Focus
     (This       : in out Track_Settings_Menu;
      Exit_Value : Window_Exit_Value)
   is
   begin
      This.Fix_Current_Setting;

      if This.Current_Setting
          in CC_Label_A | CC_Label_B | CC_Label_C | CC_Label_D
      then

         --  Return from controller label text edit

         if Exit_Value = Success then
            declare
               CC : constant CC_Id := To_CC_Id (This.Current_Setting);
               Output : constant String := WNM.GUI.Menu.Text_Dialog.Value;
               Label : Controller_Label := Empty_Controller_Label;
            begin
               Utils.Copy_Str (Output, Label);
               Project.Set_CC_Controller_Label (Editing_Track, CC, Label);
            end;
         end if;
      else
         raise Program_Error;
      end if;
   end On_Focus;

begin

   for Mode in Project.Track_Mode_Kind loop

      for Sub in Sub_Settings loop
         if Valid_Setting (Mode, Sub) then
            Valid_Top_Settings (Mode, To_Top (Sub)) := True;
         end if;
      end loop;

      --  I don't think there is a way to know the number of settings per
      --  mode at compile time because it depends on the results of the
      --  Valid_Setting function. So we compute the numbers here and cache
      --  the result for futre calls.

      for Top in Top_Settings loop
         if Valid_Top_Settings (Mode, Top) then
            Top_Settings_Count_Cache (Mode) :=
              Top_Settings_Count_Cache (Mode) + 1;
         end if;
      end loop;

      --  Same as Settings_Count, we compute the numbers here and cache the
      --  result for futre calls.

      declare
         Cnt : Natural := 0;
      begin
         for Top in Top_Settings loop
            if Valid_Top_Settings (Mode, Top) then
               Top_Settings_Position_Cache (Mode, Top) := Cnt;
               Cnt := Cnt + 1;
            end if;
         end loop;
      end;

   end loop;
end WNM.GUI.Menu.Track_Settings;
