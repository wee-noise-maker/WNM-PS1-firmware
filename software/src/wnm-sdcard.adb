------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2015-2016, AdaCore                     --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with HAL.SDMMC;               use HAL.SDMMC;
with STM32_SVD.RCC;           use STM32_SVD.RCC;

with STM32.SDMMC;             use STM32.SDMMC;
with STM32.SDMMC_Interrupt;   use STM32.SDMMC_Interrupt;

with File_IO;                 use File_IO;

package body WNM.SDCard is

   SD_Interrupt_Handler : aliased SDMMC_Interrupt_Handler (SD_Interrupt);

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      SDCard_Device.Initialize;

      BD_Monitor.Disable;

      if Mount_Drive ("sdcard", BD_Monitor'Access) /= OK then
         raise Program_Error with "No file system...";
      end if;
   end Initialize;

   ---------------
   -- Mount_Dir --
   ---------------

   function Mount_Dir return String
   is ("/sdcard/");

   ----------------
   -- Mon_Enable --
   ----------------

   procedure Mon_Enable is
   begin
      BD_Monitor.Enable;
   end Mon_Enable;

   -----------------
   -- Mon_Disable --
   -----------------

   procedure Mon_Disable is
   begin
      BD_Monitor.Disable;
   end Mon_Disable;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (This : in out SDCard_Controller)
   is
   begin
      --  Enable the GPIOs
      Enable_Clock (SD_Pins);

      --  GPIO configuration for the SDIO pins
      Configure_IO
        (SD_Pins,
         (Mode        => Mode_AF,
          Output_Type => Push_Pull,
          Speed       => Speed_High,
          Resistors   => Pull_Up));
      Configure_Alternate_Function (SD_Pins, SD_Pins_AF);

      --  Enable the SDIO clock
      STM32.Device.Enable_Clock (This.Device.all);
      STM32.Device.Reset (This.Device.all);

      --  Enable the DMA2 clock
      Enable_Clock (SD_DMA);

      Disable (SD_DMA, SD_DMA_RX_Stream);
      Configure
        (SD_DMA,
         SD_DMA_RX_Stream,
         (Channel                      => SD_DMA_RX_Channel,
          Direction                    => Peripheral_To_Memory,
          Increment_Peripheral_Address => False,
          Increment_Memory_Address     => True,
          Peripheral_Data_Format       => Words,
          Memory_Data_Format           => Words,
          Operation_Mode               => Peripheral_Flow_Control_Mode,
          Priority                     => Priority_Very_High,
          FIFO_Enabled                 => True,
          FIFO_Threshold               => FIFO_Threshold_Full_Configuration,
          Memory_Burst_Size            => Memory_Burst_Inc4,
          Peripheral_Burst_Size        => Peripheral_Burst_Inc4));
      Clear_All_Status (SD_DMA, SD_DMA_RX_Stream);

      Disable (SD_DMA, SD_DMA_TX_Stream);
      Configure
        (SD_DMA,
         SD_DMA_TX_Stream,
         (Channel                      => SD_DMA_TX_Channel,
          Direction                    => Memory_To_Peripheral,
          Increment_Peripheral_Address => False,
          Increment_Memory_Address     => True,
          Peripheral_Data_Format       => Words,
          Memory_Data_Format           => Words,
          Operation_Mode               => Peripheral_Flow_Control_Mode,
          Priority                     => Priority_Very_High,
          FIFO_Enabled                 => True,
          FIFO_Threshold               => FIFO_Threshold_Full_Configuration,
          Memory_Burst_Size            => Memory_Burst_Inc4,
          Peripheral_Burst_Size        => Peripheral_Burst_Inc4));
      Clear_All_Status (SD_DMA, SD_DMA_TX_Stream);

      This.Device.Enable_DMA_Transfers (RX_Int => SD_Rx_DMA_Int'Access,
                                        TX_Int => SD_Tx_DMA_Int'Access,
                                        SD_Int => SD_Interrupt_Handler'Access);

   end Initialize;

   --------------------------
   -- Get_Card_information --
   --------------------------

   function Get_Card_Information
     (This : in out SDCard_Controller)
      return HAL.SDMMC.Card_Information
   is
   begin
      This.Device.Ensure_Card_Informations;

      if not This.Device.Has_Card_Information then
         raise Device_Error;
      end if;

      return This.Device.Card_Information;
   end Get_Card_Information;

   ----------------
   -- Block_Size --
   ----------------

   function Block_Size
     (This : in out SDCard_Controller)
      return UInt32
   is
   begin
      return This.Get_Card_Information.Card_Block_Size;
   end Block_Size;

   -----------
   -- Write --
   -----------

   overriding function Write
     (This         : in out SDCard_Controller;
      Block_Number : UInt64;
      Data         : Block) return Boolean
   is
   begin
      return This.Device.Write (Block_Number, Data);
   end Write;

   ----------
   -- Read --
   ----------

   overriding function Read
     (This         : in out SDCard_Controller;
      Block_Number : UInt64;
      Data         : out Block) return Boolean
   is
   begin
      return This.Device.Read (Block_Number, Data);
   end Read;

end WNM.SDCard;

