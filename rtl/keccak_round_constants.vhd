library ieee;
use ieee.std_logic_1164.all;

entity keccak_round_constants is
    port(
        input_round: in std_logic_vector(4 downto 0);
        output_constant: out std_logic_vector(63 downto 0)
    );
end keccak_round_constants;

architecture behavioral of keccak_round_constants is
begin
    lut: process(input_round) is
    begin
        case input_round is
            when "00000" => output_constant <= x"0000000000000001";
            when "00001" => output_constant <= x"0000000000008082";
            when "00010" => output_constant <= x"800000000000808A";
            when "00011" => output_constant <= x"8000000080008000";
            when "00100" => output_constant <= x"000000000000808B";
            when "00101" => output_constant <= x"0000000080000001";
            when "00110" => output_constant <= x"8000000080008081";
            when "00111" => output_constant <= x"8000000000008009";
            when "01000" => output_constant <= x"000000000000008A";
            when "01001" => output_constant <= x"0000000000000088";
            when "01010" => output_constant <= x"0000000080008009";
            when "01011" => output_constant <= x"000000008000000A";
            when "01100" => output_constant <= x"000000008000808B";
            when "01101" => output_constant <= x"800000000000008B";
            when "01110" => output_constant <= x"8000000000008089";
            when "01111" => output_constant <= x"8000000000008003";
            when "10000" => output_constant <= x"8000000000008002";
            when "10001" => output_constant <= x"8000000000000080";
            when "10010" => output_constant <= x"000000000000800A";
            when "10011" => output_constant <= x"800000008000000A";
            when "10100" => output_constant <= x"8000000080008081";
            when "10101" => output_constant <= x"8000000000008080";
            when "10110" => output_constant <= x"0000000080000001";
            when "10111" => output_constant <= x"8000000080008008";
            when others => output_constant <= (others => '0');
        end case;
    end process lut;
end architecture behavioral;
