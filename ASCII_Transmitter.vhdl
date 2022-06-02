library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;

entity x7segb is
  Port ( x : in std_logic_vector(15 downto 0);
  cclk, clr : in std_logic;
  a_to_g : out std_logic_vector(6 downto 0);
  an : out std_logic_vector(3 downto 0));
end x7segb;
  
architecture arch_x7segb of x7segb is
signal digit : std_logic_vector(3 downto 0);
signal count : std_logic_vector(1 downto 0);
signal aen: std_logic_vector(3 downto 0);
begin
  aen(3) <= (x(15) or x(14) or x(13) or x(12));
  aen(2) <= (x(15) or x(14) or x(13) or x(12) or x(11) or
  x(10) or x(9) or x(8));
  aen(1) <= (x(15) or x(14) or x(13) or x(12) or x(11) or
  x(10) or x(9) or x(8) or x(7) or x(6) or x(5) or x(4));
  aen(0) <= '1';

  ctr2bit: process(cclk,clr)
  begin
    if(clr = '1') then
      count <= "00";
    elsif(cclk'event and cclk = '1') then
      count <= count + 1;
    end if;
  end process;
  -- MUX4
  with count select
    digit <= x(3 downto 0) when "00",
    x(7 downto 4) when "01",
    x(11 downto 8) when "10",
    x(15 downto 12) when others;
  -- seg7dec
  with digit select
    a_to_g <= "1111001" when "0001", --1
    "0100100" when "0010", --2
    "0110000" when "0011", --3
    "0011001" when "0100", --4
    "0010010" when "0101", --5
    "0000010" when "0110", --6
    "1111000" when "0111", --7
    "0000000" when "1000", --8
    "0010000" when "1001", --9
    "0001000" when "1010", --A
    "0000011" when "1011", --b
    "1000110" when "1100", --C
    "0100001" when "1101", --d
    "0000110" when "1110", --E
    "0001110" when "1111", --F
    "1000000" when others; --0
  ancode: process(count)
  begin
    if(aen(conv_integer(count)) = '1') then
      an <= (others => '1');
      an(conv_integer(count)) <= '0';
    else
      an <= "1111";
    end if;
  end process;
end arch_x7segb;
