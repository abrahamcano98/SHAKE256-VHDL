library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.keccak_pkg.all;

entity controller is
    port (
        clk              : in  std_logic;
        rst              : in  std_logic;

        start            : in  std_logic;

        din              : in  std_logic_vector(63 downto 0);
        din_valid        : in  std_logic;
        din_ready        : out std_logic;

        din_bytes        : in  integer range 0 to 8;
        din_last_block   : in  std_logic;

        output_len_bytes : in  integer range 0 to 65535;

        dout             : out std_logic_vector(63 downto 0);
        dout_valid       : out std_logic;
        dout_ready       : in  std_logic;
        dout_bytes       : out integer range 0 to 8;

        done             : out std_logic
    );
end controller;


architecture behavioral of controller is

    constant RATE_LANES : integer := 17;
    constant RATE_BYTES : integer := 136;

    --FSM states. IDLE initializes the state and waits for start.
    --READ_BLOCK reads 17 words of 64 bits each into the block buffer. 
    --ABSORB applies the block to the state.
    --PERMUTE applies 24 Keccak rounds to the state.
    --SQUEEZE outputs a 64-bit word.
    --DONE_STATE indicates that the core is done.
    type state_type is (
        IDLE,
        READ_BLOCK,
        ABSORB,
        PERMUTE,
        SQUEEZE,
        DONE_STATE
    );

    signal current_state : state_type;

    signal block_buffer  : state_array_t;
    signal absorb_state  : state_array_t;
    signal state_reg     : state_array_t;
    signal permute_state : state_array_t;

    signal word_counter  : integer range 0 to 16 := 0;
    signal round_counter : integer range 0 to 23 := 0;

    signal final_block_seen    : std_logic := '0';
    signal extra_pad_pending   : std_logic := '0';

    signal output_lane_counter : integer range 0 to 16 := 0;
    signal bytes_remaining     : integer range 0 to 65535 := 0;
    signal current_dout_bytes  : integer range 0 to 8 := 0;

    function pad_last_word(
        input_word : std_logic_vector(63 downto 0);
        valid_bytes : integer range 0 to 8;
        last_rate_word : integer range 0 to 1
    ) return std_logic_vector is
        variable result_word : std_logic_vector(63 downto 0) := (others => '0');
    begin
        for i in 0 to 7 loop
            if i < valid_bytes then
                result_word(8 * i + 7 downto 8 * i) :=
                    input_word(8 * i + 7 downto 8 * i);
            elsif i = valid_bytes then
                result_word(8 * i + 7 downto 8 * i) := x"1F";
            end if;
        end loop;

        if last_rate_word = 1 then
            result_word(63 downto 56) := result_word(63 downto 56) xor x"80";
        end if;

        return result_word;
    end function;

begin

    -- While reading the block, the input is ready.
    din_ready <= '1' when current_state = READ_BLOCK else '0';

    --Output stream: The current state is output as a 64-bit word.
    dout <= state_reg(output_lane_counter);

    --Output valid: Only valid when squeezing and there are bytes remaining.
    dout_valid <= '1' when current_state = SQUEEZE and bytes_remaining > 0 else '0';

    --Output bytes: The number of bytes remaining is the number of bytes to output.
    current_dout_bytes <=
        8 when bytes_remaining >= 8 else
        bytes_remaining;

    dout_bytes <= current_dout_bytes;
    --Combinational absorb: The absorb state is the current state XOR the block buffer (input message block)
    process(state_reg, block_buffer)
    begin
        absorb_state <= state_reg;

        for i in 0 to 16 loop
            absorb_state(i) <= state_reg(i) xor block_buffer(i);
        end loop;
    end process;

    --Keccak permutation round: The input state is the current state.
    --The round index is the current round counter.
    --The output state is the permuted state.
    round_inst : entity work.keccak_round
        port map(
            input_state  => state_reg,
            round_index  => round_counter,
            output_state => permute_state
        );

    --FSM state transitions.
    process(clk, rst)
    begin
        if rst = '1' then

            current_state       <= IDLE;

            state_reg           <= (others => (others => '0'));
            block_buffer        <= (others => (others => '0'));

            word_counter        <= 0;
            round_counter       <= 0;

            final_block_seen    <= '0';
            extra_pad_pending   <= '0';

            output_lane_counter <= 0;
            bytes_remaining     <= 0;

            done                <= '0';

        elsif rising_edge(clk) then

            done <= '0';

            case current_state is

                -- Wait for start and initialize the state.
                when IDLE =>

                    if start = '1' then
                        state_reg           <= (others => (others => '0'));
                        block_buffer        <= (others => (others => '0'));

                        word_counter        <= 0;
                        round_counter       <= 0;

                        final_block_seen    <= '0';
                        extra_pad_pending   <= '0';

                        output_lane_counter <= 0;
                        bytes_remaining     <= output_len_bytes;

                        current_state       <= READ_BLOCK;
                    end if;

                -- Read 17 x 64-bit words = 1088-bit SHAKE256 rate block
                when READ_BLOCK =>

                    if din_valid = '1' then

                        if din_last_block = '1' then

                            word_counter <= 0;

                            if din_bytes = 8 then

                                block_buffer(word_counter) <= din;

                                if word_counter = 16 then
                                    extra_pad_pending <= '1';
                                    final_block_seen  <= '0';
                                else
                                    block_buffer(word_counter + 1) <= x"000000000000001F";
                                    block_buffer(16)               <= x"8000000000000000";
                                    final_block_seen                <= '1';
                                end if;

                            else

                                if word_counter = 16 then
                                    block_buffer(word_counter) <= pad_last_word(din, din_bytes, 1);
                                else
                                    block_buffer(word_counter) <= pad_last_word(din, din_bytes, 0);
                                    block_buffer(16)           <= x"8000000000000000";
                                end if;

                                final_block_seen <= '1';

                            end if;

                            current_state <= ABSORB;

                        elsif word_counter = 16 then

                            word_counter <= 0;
                            block_buffer(word_counter) <= din;
                            current_state <= ABSORB;

                        else

                            block_buffer(word_counter) <= din;
                            word_counter <= word_counter + 1;

                        end if;

                    end if;

                -- Absorb one 1088-bit block
                -- Set the state to the absorb state and reset the block buffer.
                when ABSORB =>

                    state_reg     <= absorb_state;
                    block_buffer  <= (others => (others => '0'));
                    round_counter <= 0;
                    current_state <= PERMUTE;

                -- Apply 24 Keccak rounds to the state.
                when PERMUTE =>

                    state_reg <= permute_state;

                    if round_counter = 23 then

                        if final_block_seen = '1' then
                            output_lane_counter <= 0;
                            current_state       <= SQUEEZE;
                        elsif extra_pad_pending = '1' then
                            block_buffer(0)     <= x"000000000000001F";
                            block_buffer(16)    <= x"8000000000000000";
                            extra_pad_pending   <= '0';
                            final_block_seen    <= '1';
                            round_counter       <= 0;
                            current_state       <= ABSORB;
                        else
                            current_state       <= READ_BLOCK;
                        end if;

                    else

                        round_counter <= round_counter + 1;

                    end if;

                -- Stream SHAKE output, 64 bits at a time
                when SQUEEZE =>

                    if bytes_remaining = 0 then

                        current_state <= DONE_STATE;

                    elsif dout_ready = '1' then

                        if bytes_remaining <= 8 then

                            bytes_remaining <= 0;
                            current_state   <= DONE_STATE;

                        else

                            bytes_remaining <= bytes_remaining - 8;

                            if output_lane_counter = 16 then
                                output_lane_counter <= 0;
                                round_counter       <= 0;
                                current_state       <= PERMUTE;
                            else
                                output_lane_counter <= output_lane_counter + 1;
                            end if;

                        end if;

                    end if;

                -- Finished
                when DONE_STATE =>

                    done <= '1';
                    current_state <= IDLE;

                when others =>

                    current_state <= IDLE;

            end case;

        end if;
    end process;

end architecture behavioral;