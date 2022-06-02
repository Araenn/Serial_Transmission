library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_tx is
  Port (clk : in STD_LOGIC;
  clr : in STD_LOGIC;
  tx_data : in STD_LOGIC_VECTOR(7 downto 0);
  ready : in STD_LOGIC;
  tdre : out STD_LOGIC;
  --renvoie si la donnée est envoyée
  TxD : out STD_LOGIC
  );
end uart_tx;

architecture Behavioral of uart_tx is
type state_type is (mark, start, delay, shift, stop);
signal state : state_type;
signal txbuff : STD_LOGIC_VECTOR(7 downto 0);
signal baud_count : STD_LOGIC_VECTOR(11 downto 0);
signal bit_count : STD_LOGIC_VECTOR(3 downto 0);
constant bit_time : STD_LOGIC_VECTOR(11 downto 0) := X"A28"; --9600 baud
begin
uart2 : process(clk, clr, ready)
begin
  if clr = '1' then
    state <= mark; --etat depart avant le bit de start,
    --TxD à 1, bit de start à 0,
    --bits de donnee, bit de stop à 1
    txbuff <= "00000000";
    bit_count <= "0000";
    baud_count <= X"000";
    TxD <= '1';
  elsif (clk'event and clk='1') then
    case state is
    when mark =>
      bit_count <= "0000";
      tdre <= '1';
    if ready ='0' then --bouton n'est pas appuyé
      state <= mark;
      txbuff <= tx_data;
    else --bouton est appuyé
      baud_count <= X"000";
      state <= start;
    end if;
    when start =>
      baud_count <= X"000";
      TxD <= '0';
      tdre <= '0';
      state <= delay;
    when delay => --delay attend le temps de 1 bit
      tdre <= '0';
      if baud_count >= bit_time then
        baud_count <= X"000";
      if bit_count <8 then --si pas terminé
        state <= shift;
      else
        state <= stop;
      end if;
   else
     baud_count <= baud_count + 1;
     state <= delay; -- on reste dans le mm etat
   end if;
   when shift => --prochain bit, décale la donnée
     tdre <= '0';
     TxD <= txbuff(0);
     txbuff(6 downto 0) <= txbuff(7 downto 1);
     state <= delay;
   when stop =>
     tdre <= '0';
     TxD <= '1';
     if baud_count >= bit_time then
      baud_count <= X"000";
      state <= mark;
     else
      baud_count <= baud_count + 1; --temps du bit
      state <= stop;
     end if;
  end case;
  end if;
end process;
end Behavioral;
