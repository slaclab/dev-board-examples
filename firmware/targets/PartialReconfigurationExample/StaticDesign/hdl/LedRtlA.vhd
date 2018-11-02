-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : LedRtlA.vhd
-- Author     : Larry Ruckman  <ruckman@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2014-01-13
-- Last update: 2014-01-13
-- Platform   : Vivado2013.3
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Blinks the LED @ 1 Hz
-------------------------------------------------------------------------------
-- Copyright (c) 2014 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;

entity LedRtlA is
   port (
      clk : in  sl;
      cnt : in  slv(31 downto 0);
      led : out sl);
end LedRtlA;

architecture rtl of LedRtlA is
   
   constant TOGGLE_PERIOD_C : real             := (500.0E-3);  -- 500 ms (1 Hz) toggle rate
   constant CLK_PERIOD_C    : real             := 5.0E-9;  -- 5 ns (200 MHz)
   constant MAX_CNT_C       : slv(31 downto 0) := toSlv(getTimeRatio(TOGGLE_PERIOD_C, CLK_PERIOD_C), 32);

   signal counter : slv(31 downto 0) := (others => '0');
   signal toggle  : sl               := '0';
   
begin

   led <= toggle;

   process(clk)
   begin
      if rising_edge(clk) then
         counter <= counter + 1;
         if counter = MAX_CNT_C then
            counter <= (others => '0');
            if toggle = '1' then
               toggle <= '0';
            else
               toggle <= '1';
            end if;
         end if;
      end if;
   end process;
   
end rtl;
