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

with WNM_HAL;
with WNM.MIDI;
with LPC_Synth;

package WNM.Speech is

   type Word is range 1 .. 286
     with size => 9;

   function Img (W : Word) return String;

   procedure Start (T : Tracks;
                    W : Word;
                    K : MIDI.MIDI_Key);

   procedure Stop (T : Tracks);

   procedure Set_Stretch (T : Tracks; V : MIDI.MIDI_Data);

   procedure Next_Points (Buffer : in out WNM_HAL.Stereo_Buffer);

   type Speech_Event_Rec is record
      On       : Boolean;
      Track    : Tracks;
      W        : Word;
      Key      : MIDI.MIDI_Key;
   end record
     with Pack, Size => 22;

   type Speech_CC_Event_Rec is record
      Track   : Tracks;
      Stretch : MIDI.MIDI_Data;
   end record;

   --  python -c 'print("\n".join(["           \
   --  %d => %f," % (x, (0.5 + (x * (5.5/127.0)))) for x in range(0,128)]))'
   No_Strech_MIDI_Val : constant MIDI.MIDI_Data := 12;
   MIDI_To_Stretch : constant array (MIDI.MIDI_Data)
     of LPC_Synth.Time_Stretch_Factor
       := (0 => 0.500000,
           1 => 0.543307,
           2 => 0.586614,
           3 => 0.629921,
           4 => 0.673228,
           5 => 0.716535,
           6 => 0.759843,
           7 => 0.803150,
           8 => 0.846457,
           9 => 0.889764,
           10 => 0.933071,
           11 => 0.976378,
           12 => 1.019685,
           13 => 1.062992,
           14 => 1.106299,
           15 => 1.149606,
           16 => 1.192913,
           17 => 1.236220,
           18 => 1.279528,
           19 => 1.322835,
           20 => 1.366142,
           21 => 1.409449,
           22 => 1.452756,
           23 => 1.496063,
           24 => 1.539370,
           25 => 1.582677,
           26 => 1.625984,
           27 => 1.669291,
           28 => 1.712598,
           29 => 1.755906,
           30 => 1.799213,
           31 => 1.842520,
           32 => 1.885827,
           33 => 1.929134,
           34 => 1.972441,
           35 => 2.015748,
           36 => 2.059055,
           37 => 2.102362,
           38 => 2.145669,
           39 => 2.188976,
           40 => 2.232283,
           41 => 2.275591,
           42 => 2.318898,
           43 => 2.362205,
           44 => 2.405512,
           45 => 2.448819,
           46 => 2.492126,
           47 => 2.535433,
           48 => 2.578740,
           49 => 2.622047,
           50 => 2.665354,
           51 => 2.708661,
           52 => 2.751969,
           53 => 2.795276,
           54 => 2.838583,
           55 => 2.881890,
           56 => 2.925197,
           57 => 2.968504,
           58 => 3.011811,
           59 => 3.055118,
           60 => 3.098425,
           61 => 3.141732,
           62 => 3.185039,
           63 => 3.228346,
           64 => 3.271654,
           65 => 3.314961,
           66 => 3.358268,
           67 => 3.401575,
           68 => 3.444882,
           69 => 3.488189,
           70 => 3.531496,
           71 => 3.574803,
           72 => 3.618110,
           73 => 3.661417,
           74 => 3.704724,
           75 => 3.748031,
           76 => 3.791339,
           77 => 3.834646,
           78 => 3.877953,
           79 => 3.921260,
           80 => 3.964567,
           81 => 4.007874,
           82 => 4.051181,
           83 => 4.094488,
           84 => 4.137795,
           85 => 4.181102,
           86 => 4.224409,
           87 => 4.267717,
           88 => 4.311024,
           89 => 4.354331,
           90 => 4.397638,
           91 => 4.440945,
           92 => 4.484252,
           93 => 4.527559,
           94 => 4.570866,
           95 => 4.614173,
           96 => 4.657480,
           97 => 4.700787,
           98 => 4.744094,
           99 => 4.787402,
           100 => 4.830709,
           101 => 4.874016,
           102 => 4.917323,
           103 => 4.960630,
           104 => 5.003937,
           105 => 5.047244,
           106 => 5.090551,
           107 => 5.133858,
           108 => 5.177165,
           109 => 5.220472,
           110 => 5.263780,
           111 => 5.307087,
           112 => 5.350394,
           113 => 5.393701,
           114 => 5.437008,
           115 => 5.480315,
           116 => 5.523622,
           117 => 5.566929,
           118 => 5.610236,
           119 => 5.653543,
           120 => 5.696850,
           121 => 5.740157,
           122 => 5.783465,
           123 => 5.826772,
           124 => 5.870079,
           125 => 5.913386,
           126 => 5.956693,
           127 => 6.000000);

end WNM.Speech;
