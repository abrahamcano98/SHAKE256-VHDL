library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.all;

entity tb_controller is
end entity;

architecture sim of tb_controller is

    signal clk              : std_logic := '0';
    signal rst              : std_logic := '0';

    signal start            : std_logic := '0';

    signal din              : std_logic_vector(63 downto 0) := (others => '0');
    signal din_valid        : std_logic := '0';
    signal din_ready        : std_logic;
    signal din_bytes        : integer range 0 to 8 := 0;
    signal din_last_block   : std_logic := '0';

    signal output_len_bytes : integer range 0 to 65535 := 64;

    signal dout             : std_logic_vector(63 downto 0);
    signal dout_valid       : std_logic;
    signal dout_ready       : std_logic := '1';
    signal dout_bytes       : integer range 0 to 8;

    signal done             : std_logic;

    constant CLK_PERIOD : time := 10 ns;

    type word64_array_t is array (natural range <>) of std_logic_vector(63 downto 0);

    constant MSG_EMPTY : word64_array_t(0 to 0) := (
        0 => x"0000000000000000"
    );

    constant EXP_EMPTY_32 : word64_array_t(0 to 3) := (
        0 => x"138DA80B2BDDB946",
        1 => x"24EB3E74EB3F3B23",
        2 => x"821BB862EA52CD3F",
        3 => x"2F76D56E64270CB5"
    );

    constant EXP_NIST_EMPTY_64 : word64_array_t(0 to 7) := (
        0 => x"138DA80B2BDDB946",
        1 => x"24EB3E74EB3F3B23",
        2 => x"821BB862EA52CD3F",
        3 => x"2F76D56E64270CB5",
        4 => x"00F2C0D8DDC45DD7",
        5 => x"F692B5679D0105CB",
        6 => x"86B49A47491C82FC",
        7 => x"BEC4B7B3AC2E2940"
    );

    constant MSG_ABC : word64_array_t(0 to 0) := (
        0 => x"0000000000636261"
    );

    constant EXP_ABC_10 : word64_array_t(0 to 1) := (
        0 => x"77A8601360663348",
        1 => x"000000000000681C"
    );

    constant EXP_ABC_64 : word64_array_t(0 to 7) := (
        0 => x"77A8601360663348",
        1 => x"4D11C40C0863681C",
        2 => x"EEE1F1F83045B48D",
        3 => x"39578BE737EA944F",
        4 => x"86536A18EF5BA1D5",
        5 => x"AA1F7E52C04457C7",
        6 => x"4F2AA162E426879F",
        7 => x"E451E70188BD06EB"
    );

    constant MSG_EIGHT : word64_array_t(0 to 0) := (
        0 => x"3837363534333231"
    );

    constant EXP_EIGHT_32 : word64_array_t(0 to 3) := (
        0 => x"2846033CBDEB8928",
        1 => x"2FD0BB8905E82B97",
        2 => x"5D2651B9ADB1172F",
        3 => x"BDA4314781CF4C86"
    );

    constant MSG_RATE_FULL_ZERO : word64_array_t(0 to 16) := (
        0  => x"0000000000000000",
        1  => x"0000000000000000",
        2  => x"0000000000000000",
        3  => x"0000000000000000",
        4  => x"0000000000000000",
        5  => x"0000000000000000",
        6  => x"0000000000000000",
        7  => x"0000000000000000",
        8  => x"0000000000000000",
        9  => x"0000000000000000",
        10 => x"0000000000000000",
        11 => x"0000000000000000",
        12 => x"0000000000000000",
        13 => x"0000000000000000",
        14 => x"0000000000000000",
        15 => x"0000000000000000",
        16 => x"0000000000000000"
    );

    constant EXP_RATE_FULL_ZERO_32 : word64_array_t(0 to 3) := (
        0 => x"9B1FEC5F837B94EA",
        1 => x"78EB1D90BAAB7E0A",
        2 => x"CCD5CBA19999FD81",
        3 => x"70FEF6B7FA9A5ABB"
    );

    constant MSG_CROSS_RATE_140 : word64_array_t(0 to 17) := (
        0  => x"0706050403020100",
        1  => x"0F0E0D0C0B0A0908",
        2  => x"1716151413121110",
        3  => x"1F1E1D1C1B1A1918",
        4  => x"2726252423222120",
        5  => x"2F2E2D2C2B2A2928",
        6  => x"3736353433323130",
        7  => x"3F3E3D3C3B3A3938",
        8  => x"4746454443424140",
        9  => x"4F4E4D4C4B4A4948",
        10 => x"5756555453525150",
        11 => x"5F5E5D5C5B5A5958",
        12 => x"6766656463626160",
        13 => x"6F6E6D6C6B6A6968",
        14 => x"7776757473727170",
        15 => x"7F7E7D7C7B7A7978",
        16 => x"8786858483828180",
        17 => x"000000008B8A8988"
    );

    constant EXP_CROSS_RATE_140_32 : word64_array_t(0 to 3) := (
        0 => x"A936D254CB7C07EC",
        1 => x"C1347ABCF7D39A53",
        2 => x"B3F3E0521DCC92F8",
        3 => x"59B28618A251267B"
    );

    -- FIPS 202 / NIST SHAKE256 example: 1600-bit message of all A3 bytes.
    constant MSG_NIST_A3_200 : word64_array_t(0 to 24) := (
        0  => x"A3A3A3A3A3A3A3A3",
        1  => x"A3A3A3A3A3A3A3A3",
        2  => x"A3A3A3A3A3A3A3A3",
        3  => x"A3A3A3A3A3A3A3A3",
        4  => x"A3A3A3A3A3A3A3A3",
        5  => x"A3A3A3A3A3A3A3A3",
        6  => x"A3A3A3A3A3A3A3A3",
        7  => x"A3A3A3A3A3A3A3A3",
        8  => x"A3A3A3A3A3A3A3A3",
        9  => x"A3A3A3A3A3A3A3A3",
        10 => x"A3A3A3A3A3A3A3A3",
        11 => x"A3A3A3A3A3A3A3A3",
        12 => x"A3A3A3A3A3A3A3A3",
        13 => x"A3A3A3A3A3A3A3A3",
        14 => x"A3A3A3A3A3A3A3A3",
        15 => x"A3A3A3A3A3A3A3A3",
        16 => x"A3A3A3A3A3A3A3A3",
        17 => x"A3A3A3A3A3A3A3A3",
        18 => x"A3A3A3A3A3A3A3A3",
        19 => x"A3A3A3A3A3A3A3A3",
        20 => x"A3A3A3A3A3A3A3A3",
        21 => x"A3A3A3A3A3A3A3A3",
        22 => x"A3A3A3A3A3A3A3A3",
        23 => x"A3A3A3A3A3A3A3A3",
        24 => x"A3A3A3A3A3A3A3A3"
    );

    constant EXP_NIST_A3_200_64 : word64_array_t(0 to 7) := (
        0 => x"04AA41D10E928ACD",
        1 => x"E9528628592DA207",
        2 => x"1C7C1E0CEEA7F1D9",
        3 => x"4D904AA84D4299A6",
        4 => x"CE6E39E7AA0C702D",
        5 => x"F3A47D5740446096",
        6 => x"1C967F85B8AE22AA",
        7 => x"0B61E60A6FE0D84C"
    );

    function mask_word(
        input_word : std_logic_vector(63 downto 0);
        valid_bytes : integer range 0 to 8
    ) return std_logic_vector is
        variable result_word : std_logic_vector(63 downto 0) := (others => '0');
    begin
        for i in 0 to 7 loop
            if i < valid_bytes then
                result_word(8 * i + 7 downto 8 * i) :=
                    input_word(8 * i + 7 downto 8 * i);
            end if;
        end loop;

        return result_word;
    end function;

begin

    clk <= not clk after CLK_PERIOD / 2;

    dut : entity work.controller
        port map (
            clk              => clk,
            rst              => rst,

            start            => start,

            din              => din,
            din_valid        => din_valid,
            din_ready        => din_ready,
            din_bytes        => din_bytes,
            din_last_block   => din_last_block,

            output_len_bytes => output_len_bytes,

            dout             => dout,
            dout_valid       => dout_valid,
            dout_ready       => dout_ready,
            dout_bytes       => dout_bytes,

            done             => done
        );

    timeout_proc : process
    begin
        wait for 200 us;

        assert false
            report "Simulation timeout: testbench did not finish"
            severity failure;
    end process;

    stim : process
        procedure reset_dut is
        begin
            rst <= '1';
            start <= '0';
            din <= (others => '0');
            din_valid <= '0';
            din_bytes <= 0;
            din_last_block <= '0';
            dout_ready <= '1';

            wait for 3 * CLK_PERIOD;
            rst <= '0';
            wait for 2 * CLK_PERIOD;
        end procedure;

        procedure run_vector(
            name : string;
            message_words : word64_array_t;
            last_word_bytes : integer range 0 to 8;
            expected_words : word64_array_t;
            expected_bytes : integer range 0 to 65535;
            stall_first_output : boolean
        ) is
            variable out_count : integer := 0;
            variable expected_this_bytes : integer range 0 to 8;
            variable expected_word : std_logic_vector(63 downto 0);
            variable output_stall_count : integer range 0 to 3;
        begin
            report "Running " & name severity note;

            reset_dut;

            output_len_bytes <= expected_bytes;

            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            for i in message_words'range loop
                din <= message_words(i);
                din_valid <= '1';

                if i = message_words'high then
                    din_last_block <= '1';
                    din_bytes <= last_word_bytes;
                else
                    din_last_block <= '0';
                    din_bytes <= 8;
                end if;

                loop
                    wait until rising_edge(clk);
                    exit when din_ready = '1';
                end loop;
            end loop;

            din <= (others => '0');
            din_valid <= '0';
            din_bytes <= 0;
            din_last_block <= '0';

            if stall_first_output then
                dout_ready <= '0';
                output_stall_count := 0;

                loop
                    wait until rising_edge(clk);

                    if dout_valid = '1' then
                        output_stall_count := output_stall_count + 1;
                        exit when output_stall_count = 3;
                    end if;
                end loop;

                dout_ready <= '1';
            else
                dout_ready <= '1';
            end if;

            out_count := 0;

            while out_count < expected_words'length loop
                wait until rising_edge(clk);

                if dout_valid = '1' then
                    if out_count = expected_words'length - 1 then
                        expected_this_bytes := expected_bytes - (8 * out_count);
                    else
                        expected_this_bytes := 8;
                    end if;

                    assert dout_bytes = expected_this_bytes
                        report name & ": wrong dout_bytes"
                        severity error;

                    expected_word := mask_word(expected_words(expected_words'low + out_count), expected_this_bytes);

                    assert mask_word(dout, expected_this_bytes) = expected_word
                        report name & ": SHAKE256 output word mismatch"
                        severity error;

                    out_count := out_count + 1;
                end if;
            end loop;

            loop
                wait until rising_edge(clk);
                exit when done = '1';
            end loop;

            report name & " passed" severity note;
        end procedure;
    begin
        run_vector("empty message, 32-byte output", MSG_EMPTY, 0, EXP_EMPTY_32, 32, false);
        run_vector("NIST empty message, 64-byte output", MSG_EMPTY, 0, EXP_NIST_EMPTY_64, 64, true);
        run_vector("abc, 10-byte output", MSG_ABC, 3, EXP_ABC_10, 10, false);
        run_vector("abc, 64-byte output", MSG_ABC, 3, EXP_ABC_64, 64, false);
        run_vector("8-byte message, 32-byte output", MSG_EIGHT, 8, EXP_EIGHT_32, 32, false);
        run_vector("136-byte message, 32-byte output", MSG_RATE_FULL_ZERO, 8, EXP_RATE_FULL_ZERO_32, 32, false);
        run_vector("140-byte message, 32-byte output", MSG_CROSS_RATE_140, 4, EXP_CROSS_RATE_140_32, 32, false);
        run_vector("NIST A3 1600-bit message, 64-byte output", MSG_NIST_A3_200, 8, EXP_NIST_A3_200_64, 64, false);

        report "All SHAKE256 controller test vectors passed" severity note;
        std.env.stop;
        wait;
    end process;

end architecture;