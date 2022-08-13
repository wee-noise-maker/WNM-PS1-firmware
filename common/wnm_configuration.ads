package WNM_Configuration is

   Screen_Width  : constant := 128;
   Screen_Height : constant := 64;

   Coproc_Data_Size : constant := 32;
   Coproc_Queue_Capacity : constant := 8;

   type Button is (B1, B2, B3, B4, B5, B6, B7, B8,
                   B9, B10, B11, B12, B13, B14, B15, B16,
                   Rec, Play,
                   Menu, Func, Step_Button, Track_Button, Pattern_Button,
                   Chord,
                   Encoder_L, Encoder_R);

   subtype LED is Button range B1 .. Chord;

   LED_Position : constant array (LED) of Positive :=
     (B1             => 6,
      B2             => 7,
      B3             => 8,
      B4             => 9,
      B5             => 10,
      B6             => 11,
      B7             => 12,
      B8             => 13,
      B9             => 16,
      B10            => 17,
      B11            => 18,
      B12            => 19,
      B13            => 20,
      B14            => 21,
      B15            => 22,
      B16            => 23,
      Rec            => 24,
      Play           => 14,
      Menu           => 1,
      Func           => 4,
      Step_Button    => 15,
      Track_Button   => 5,
      Pattern_Button => 3,
      Chord          => 2);

   package Storage is
      pragma Style_Checks ("M120");

      Sector_Size : constant := 4096;

      Sample_Library_Sectors : constant := 2200;
      Sample_Library_Size : constant := Sector_Size * Sample_Library_Sectors;

      FS_Sectors : constant := 512;
      FS_Size    : constant := Sector_Size * FS_Sectors;

      Total_Storage_Size : constant := Sample_Library_Size + FS_Size;

      Nbr_Samples             : constant := 50;
      Global_Sample_Byte_Size : constant := Sample_Library_Sectors * Sector_Size;
      Sectors_Per_Sample      : constant := Sample_Library_Sectors / Nbr_Samples;
      Single_Sample_Byte_Size : constant := Global_Sample_Byte_Size / Nbr_Samples;
      Single_Sample_Point_Cnt : constant := Single_Sample_Byte_Size / 2;
      Sample_Name_Lenght      : constant := 15;

   end Storage;
end WNM_Configuration;
