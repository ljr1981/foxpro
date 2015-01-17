note
	description: "[
		Byte Helpers
		]"
	synopsis: "[
		In the context of handling Visual FoxPro Database File (DBF) creation and
		reading (parsing, importing), it is necessary to handle a number of byte-
		related functions. Typically, the DBF has a number of values stored in the
		file-stream, which represent {INTEGER_32} and {INTEGER_16} values. These
		values are split into 4 and 2 8-bit bytes, respectively. Moreover, the
		bytes are always stored in the files stream in order of LSB -> MSB.
		]"
	glossary: "[Glossary of Terms]"
	term: "[
		LSB: Least Significant Byte (right-most byte) in a collection of bytes.
		]"
	term: "[
		MSB: Most Significant Byte (left-most byte) in a collection of bytes.
		]"
	date: "$Date: 2015-01-15 16:49:21 -0500 (Thu, 15 Jan 2015) $"
	revision: "$Revision: 10591 $"

class
	FP_BYTE_HELPER

feature -- Multi-byte Operations

	all_bytes_tuple_64 (a_value: INTEGER_64): TUPLE [msb, msb2, msb3, msb4, msb5, msb6, msb7, lsb: NATURAL_8]
			-- Bytes of 64-bits of {INTEGER_64} `a_value' from MSB -> LSB (bytes 1-8)
		do
			Result :=
				[byte_n_of_8 (1, a_value).to_natural_8,
					byte_n_of_8 (2, a_value).to_natural_8,
					byte_n_of_8 (3, a_value).to_natural_8,
					byte_n_of_8 (4, a_value).to_natural_8,
					byte_n_of_8 (5, a_value).to_natural_8,
					byte_n_of_8 (6, a_value).to_natural_8,
					byte_n_of_8 (7, a_value).to_natural_8,
					byte_n_of_8 (8, a_value).to_natural_8]
		end

	all_bytes_tuple_32 (a_value: INTEGER_32): TUPLE [msb, msb2, msb3, lsb: NATURAL_8]
			-- Bytes of 32-bits of {INTEGER_32} `a_value' from MSB -> LSB (bytes 1-4)
		do
			Result :=
				[byte_n_of_8 (5, a_value.as_integer_64).to_natural_8,
					byte_n_of_8 (6, a_value.as_integer_64).to_natural_8,
					byte_n_of_8 (7, a_value.as_integer_64).to_natural_8,
					byte_n_of_8 (8, a_value.as_integer_64).to_natural_8]
		ensure
			valid_result: Result ~ [byte_n_of_8 (5, a_value.as_integer_64).to_natural_8,
									byte_n_of_8 (6, a_value.as_integer_64).to_natural_8,
									byte_n_of_8 (7, a_value.as_integer_64).to_natural_8,
									byte_n_of_8 (8, a_value.as_integer_64).to_natural_8]
		end

	all_bytes_tuple_16 (a_value: INTEGER_32): TUPLE [msb, lsb: NATURAL_8]
			-- Bytes of 16-bits of {INTEGER_32} `a_value' from MSB -> LSB (bytes 3-4)
		do
			Result :=
				[byte_n_of_8 (7, a_value.as_integer_64).to_natural_8,
					byte_n_of_8 (8, a_value.as_integer_64).to_natural_8]
		ensure
			valid_result: Result ~ [byte_n_of_8 (7, a_value.as_integer_64).to_natural_8,
									byte_n_of_8 (8, a_value.as_integer_64).to_natural_8]
		end

feature -- Single-byte Operations

	lsb_32 (a_value: INTEGER_32): NATURAL_8
			-- The LSB of `a_value' as an 4-byte {INTEGER_32}.
		note
			description: "Least Significant Byte"
			synopsis: "[
				MSB -> LSB on an {INTEGER_32} consisting of 4 bytes
				numbered 1 (MSB) to 4 (LSB), left to right.
				]"
		do
			Result := byte_n_of_8 (lsb_byte_position_64, a_value.as_integer_64).as_natural_8
		end

	msb_32 (a_value: INTEGER_32): NATURAL_8
			-- The MSB of `a_value' as an 4-byte {INTEGER_32}.
		note
			description: "Most Significant Byte"
			synopsis: "[
				MSB -> LSB on an {INTEGER_32} consisting of 4 bytes
				numbered 1 (MSB) to 4 (LSB), left to right.
				]"
		do
			Result := byte_n_of_8 (msb_byte_position, a_value.as_integer_64).as_natural_8
		end

	msb2_32 (a_value: INTEGER_32): NATURAL_8
			-- The MSB of `a_value' as an 4-byte {INTEGER_32}.
		note
			description: "Most Significant Byte"
			synopsis: "[
				MSB -> LSB on an {INTEGER_32} consisting of 4 bytes
				numbered 1 (MSB) to 4 (LSB), left to right.
				]"
		do
			Result := byte_n_of_8 (msb6_byte_position, a_value.as_integer_64).as_natural_8
		end

	msb_16 (a_value: INTEGER_32): NATURAL_8
			-- The MSB 16-bit-based of `a_value' as an 4-byte {INTEGER_32}.
		note
			description: "Most Significant Byte"
			synopsis: "[
				MSB -> LSB on an {INTEGER_32} consisting of 4 bytes
				numbered 1 (MSB) to 4 (LSB), left to right. In this
				case, the MSB will be byte #3, as we only want the
				last two bytes of the four.
				]"
		do
			Result := byte_n_of_8 (msb7_byte_position, a_value.as_integer_64).as_natural_8
		end

feature -- Constants

	msb_byte_position: INTEGER = 1
			-- MSB byte position in an {INTEGER_32} value.

	msb2_byte_position: INTEGER = 2
			-- MSB + 1 byte position in an {INTEGER_32} value.

	msb3_byte_position: INTEGER = 3
			-- MSB byte position in an {INTEGER_32} value.

	msb4_byte_position: INTEGER = 4
			-- MSB byte position in an {INTEGER_64} value.

	msb5_byte_position: INTEGER = 5
			-- MSB byte position in an {INTEGER_64} value.

	msb6_byte_position: INTEGER = 6
			-- MSB byte position in an {INTEGER_64} value.

	msb7_byte_position: INTEGER = 7
			-- MSB byte position in an {INTEGER_64} value.

	lsb_byte_position_32: INTEGER = 4
			-- LSB byte position in an {INTEGER_32} value.

	lsb_byte_position_64: INTEGER = 8
			-- LSB byte position in an {INTEGER_64} value.

feature -- Implementation: Test Support Only

	byte_n_of_8 (n: INTEGER; a_value: INTEGER_64): INTEGER_8
			-- The `n'th byte of 8-byte {INTEGER_64} `a_value' as an {INTEGER_8}
		note
			synopsis: "[
				An eight-byte {INTEGER_64} from MSB->LSB (1 - 8)
				parsed by various bit-shifts (see {INTEGER_64}.bit_shift_left
				"|<<" and {INTEGER_64}.bit_shift_right "|>>")
				]"
			warning: "[
				This feature is for internal implementation only. However, due to
				the present structure of the library, it cannot be limited to just
				{TEST_SET_HELPER}.
				]"
			todo: "[
				(1) The code commented out will change the bit-shift method
					(now used) to inline-C (`c_integer_8_at_offset'). At the
					moment, there are errors with using the inline-C, so we
					have left the bit-shift method in place because it works.
				(2) Modify the ECF of this library to accommodate limited export
					of this feature to just {TEST_SET_HELPER}
				]"
		require
			only_has_8: (n >= msb_byte_position) and (n <= lsb_byte_position_64)
		local
			l_result_64: INTEGER_64
--			l_value: INTEGER_64
		do
--			l_value := a_value
--			Result := c_integer_8_at_offset ($l_value, (n - 1))
			inspect n
			when msb_byte_position then
				do_nothing
			when msb2_byte_position then
				l_result_64 := a_value |<< 8
			when msb3_byte_position then
				l_result_64 := a_value |<< 16
			when msb4_byte_position then
				l_result_64 := a_value |<< 24
			when msb5_byte_position then
				l_result_64 := a_value |<< 32
			when msb6_byte_position then
				l_result_64 := a_value |<< 40
			when msb7_byte_position then
				l_result_64 := a_value |<< 48
			when lsb_byte_position_64 then
				l_result_64 := a_value |<< 56
			else
				check only_has_eight: False end
			end
			Result := (l_result_64 |>> 56).as_integer_8
		end

	c_integer_8_at_offset (a_addr: POINTER; a_offset: INTEGER_32): INTEGER_8
		   -- INTEGER_8 at address (`a_addr' + `a_offset')
		note
			warning: "[
				This feature is unused and untested, but is intended to replace the
				`byte_n_of_8' feature (e.g. substitute the inline-C below for the
				bit-shifting code aboe).
				]"
		external
			"C inline"
		alias
			"*(EIF_INTEGER_8 *)((char *)$a_addr + $a_offset)"
		end

end
