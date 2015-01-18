note
	description: "[
		Tests of the {FP_HEADER} specification.
	]"
	testing: "[
		(1) Once the `header_test' is executed, a "generated_table.dbf" will be created.
			You may use this DBF file from within VFP to open, browse, and otherwise
			use to verify and confirm the file is usable by VFP directly.
		(2) Pay special attention to the multi-line manifest string constant features
			(`test_header' and `test_header_with_subrecord') as they contain the hex
			output from {FP_HEX_HELPER} needed to quickly ascertain if the output is
			correct.
			
			Moreover, from within VFP, one can use the "hex-edit" APP (see VFP) to view
			the raw outputs of files for comparison (e.g. example_table.dbf Vs. generated_table.dbf).
			The following VFP command-lines will launch a copy of the hex-edit APP:
			
			SET DEFAULT TO "c:\program files (x86)\microsoft visual foxpro 9\tools\hexedit"
			DO hexedit.app
			
			The APP will present you will a "File-open" dialog asking you to locate a
			file for inspection. Find the DBF file you want to inspect and select it.
			Moreover, note that you can run multiple instances of the APP to load up
			multiple DBF files for side-by-side inspection. This is the method used to
			work with this test set in order to calibrate the code to produce an exact
			match between the "example_table.dbf" file (which was created using VFP) and
			the "generated_table.dbf", which is created from the `header_test' feature
			below as a part of the testing cycle.
		]"
	todo: "[
		(1) Create other tests that produce other forms of DBF for loading into VFP.
			For example: DBF's with multiple fields, various column data types, and
			Memo (FPT) files. It might be nice to see about create a DBC as well.
			However, indexes (IDX, NDX, and CDX) are all off-limits as they are not
			needed (presently).
		(2) Most all testing is done with great satisfaction on the byte-parsing code
			(see `byte_test' below). There are a few more out-laying edge-case tests
			yet to be coded. These need to be done soon.
		]"
	date: "$Date: 2015-01-08 00:48:24 -0500 (Thu, 08 Jan 2015) $"
	revision: "$Revision: 10522 $"
	testing: "type/manual"

class
	FP_HEADER_TEST_SET

inherit
	TEST_SET_HELPER

	FP_HEX_HELPER
		undefine
			default_create
		end

feature -- Test routines

	header_test
			-- Test {FP_HEADER}
		local
			l_header: FP_HEADER
			l_sub: FP_FIELD_SUBRECORD [STRING]
		do
			create l_header
			l_header.set_file_type_vfp -- set_file_type_foxpro_2x
			l_header.set_record_count (0)
			assert_strings_equal ("header_same", test_header_string, header_string_as_hex (l_header, 2014, 12, 19))
				-- Subrecord
			l_header.add_character_field ("FLD_CHAR", 10)
			assert_strings_equal ("header_with_subrecord_same", test_header_with_subrecord, header_string_as_hex (l_header, 2014, 12, 19))
				-- Write the header and subrecord to a file.
				--| This file is now available to load (open/browse) in VFP 9.x
			generate_dbf ("generated_table.dbf", l_header)
		end

	header_multi_column_test
			-- Test {FP_HEADER} creating table with multiple columns
		local
			l_header: FP_HEADER
			l_sub: FP_FIELD_SUBRECORD [STRING]
		do
			create l_header
			l_header.set_file_type_vfp
			l_header.set_record_count (0)
			l_header.add_character_field ("FLD_CHAR", 10)
			l_header.add_currency_field ("FLD_CURR")
			l_header.add_date_field ("FLD_DATE")
			l_header.add_datetime_field ("FLD_DATETM")
			l_header.add_double_field ("FLD_DBL", 10, 0)
			l_header.add_float_field ("FLD_FLT", 10, 0)
			l_header.add_integer_field ("FLD_INT")
			l_header.add_logical_field ("FLD_BOOL")
			generate_dbf ("generated_multi_table.dbf", l_header)
		end


	dbf_file_creation_tests
			-- Creating various DBF files for testing with VFP.
		local
			l_header: FP_HEADER
			l_file: RAW_FILE
		do
			l_header := test_header
			l_header.add_character_field ("FLD_ONE", 10)
			l_header.add_character_field ("FLD_TWO", 10)
			generate_dbf ("generated_table_2.dbf", l_header)
			l_header := test_header
			l_header.add_character_field ("FLD_ONE", 10)
			l_header.add_character_field ("FLD_TWO", 10)
			l_header.add_character_field ("FLD_THREE", 10)
			generate_dbf ("generated_table_3.dbf", l_header)
		end

	byte_test_64
			-- Test {FP_HEADER}.byte_n_of_8
		note
			example: "[
				Example: 99_999_999 = F0-E8-A4-D4-E8-00-00-00 --> 240-232-164-212-232-0-0-0
				]"
		local
			l_header: FP_HEADER
			l_tuple: TUPLE [msb, msb2, msb3, msb4, msb5, msb6, msb7, lsb: NATURAL_8]
		do
			create l_header
				-- 999_999_990_000 (e.g. 99_999_999.0000)
			l_tuple := l_header.all_bytes_tuple_64 (999_999_990_000)
			assert_equals ("msb", (0).as_natural_8, l_tuple.msb)
			assert_equals ("msb2", (0).as_natural_8, l_tuple.msb2)
			assert_equals ("msb3", (0).as_natural_8, l_tuple.msb3)
			assert_equals ("msb4", (232).as_natural_8, l_tuple.msb4)
			assert_equals ("msb5", (212).as_natural_8, l_tuple.msb5)
			assert_equals ("msb6", (164).as_natural_8, l_tuple.msb6)
			assert_equals ("msb7", (232).as_natural_8, l_tuple.msb7)
			assert_equals ("lsb", (240).as_natural_8, l_tuple.lsb)
			assert_equals ("same_value", (999_999_990_000).as_integer_64, calculate_from_msb (l_tuple))

			assert_strings_equal ("hex_strings_match", "F0-E8-A4-D4-E8-00-00-00", l_tuple.lsb.to_hex_string + "-" + l_tuple.msb7.to_hex_string + "-" + l_tuple.msb6.to_hex_string + "-" + l_tuple.msb5.to_hex_string + "-" + l_tuple.msb4.to_hex_string + "-" + l_tuple.msb3.to_hex_string + "-" + l_tuple.msb2.to_hex_string + "-" + l_tuple.msb.to_hex_string)

				--	Bit#	6...6..55.....544......44......33.3....22...2..11.....100......0
				--	Bit#	4321098765432109876543210987654321098765432109876543210987654321
				--	Byte#	├───8──┤├───7──┤├───6──┤├───5──┤├───4──┤├───3──┤├───2──┤├───1──┤
				--	        0000000000000000000000001110100011010100101001001110100011110000 --000000E8D4A4E8F0
			l_tuple := l_header.all_bytes_tuple_64 (999_999_990_000)
			assert_equals ("msb", (0).as_natural_8, l_tuple.msb)
			assert_equals ("msb2", (0).as_natural_8, l_tuple.msb2)
			assert_equals ("msb3", (0).as_natural_8, l_tuple.msb3)
				-- msb4	232
				-- | << 24	1110100011010100101001001110100011110000◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|
				-- | >> 56	►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►11101000 = 232 x 4_294_967_296
			assert_equals ("996_432_412_672", (996_432_412_672).to_integer_64, 232 * 4_294_967_296)
			assert_equals ("msb4", (232).as_natural_8, l_tuple.msb4)

				-- msb5	212
				-- | << 32	11010100101001001110100011110000◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|
				-- | >> 56	►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►11010100 = 212 x 16_777_216
			assert_equals ("msb5", (212).as_natural_8, l_tuple.msb5)
			assert_equals ("3_556_769_792", (3_556_769_792).to_integer_64, (212).to_integer_64 * (16_777_216).to_integer_64)

				-- msb6	164
				-- | << 40	101001001110100011110000◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|
				-- | >> 56	►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►10100100 = 164 x 65_536
			assert_equals ("msb6", (164).as_natural_8, l_tuple.msb6)
			assert_equals ("10_747_904", (10_747_904).to_integer_64, (164).to_integer_64 * (65_536).to_integer_64)

				-- msb7	232
				-- |<< 48	1110100011110000◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|
				-- |>> 56	►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►11101000 = 232 x 256
			assert_equals ("msb7", (232).as_natural_8, l_tuple.msb7)
			assert_equals ("59_392", (59_392).to_integer_64, (232).to_integer_64 * (256).to_integer_64)

				-- lsb	240
				-- <<56	    11110000◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|◄◄◄◄◄◄◄|
				-- |>> 56	►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►►11110000 = 240 x 1
			assert_equals ("lsb", (240).as_natural_8, l_tuple.lsb)
			assert_equals ("999_999_990_000", (999_999_990_000).to_integer_64, (240).to_integer_64 +
																				(59_392).to_integer_64 +
																				(10_747_904).to_integer_64 +
																				(3_556_769_792).to_integer_64 +
																				(996_432_412_672).to_integer_64)

			print ((999_999_990_000).as_integer_64 - calculate_from_msb (l_tuple))
			assert_equals ("999_999_990_000", (999_999_990_000).as_integer_64, calculate_from_msb (l_tuple))

		end

	byte_test
			-- Test {FP_HEADER}.byte_n_of_4
		note
			attention: "[
				(1) Note the various `assert_equals' calls where earlier versions have
					calls to `(n).to_integer_8', whereas others use '%/0x00/'-style
					calls instead. This was a discovery that turned out to be more
					convenient when inspecting the "hex-edit" of a file, where the
					bytes of the file are presented as hex-digits instead of decimal.
					Thus, it is easier to read the hex in this code when comparing to
					the hex-edit output/GUI. I have left both ways and this note to
					point out that you can do the testing either way depending on 
					your need.
				]"
		local
			l_header: FP_HEADER
		do
			create l_header
				-- 363 (1 x 256 + 107)
			assert_equals ("byte_3", (1).to_integer_8, l_header.byte_n_of_8 (7, 363))
			assert_equals ("byte_4", (107).to_integer_8, l_header.byte_n_of_8 (8, 363))
				-- 999 (3 x 256 + 231)
			assert_equals ("byte_1_999", (0).to_integer_8, l_header.byte_n_of_8 (5, 999))
			assert_equals ("byte_2_999", (0).to_integer_8, l_header.byte_n_of_8 (6, 999))
			assert_equals ("byte_3_999", (3).to_integer_8, l_header.byte_n_of_8 (7, 999))
			assert_equals ("byte_4_999", (231).to_integer_8, l_header.byte_n_of_8 (8, 999))
				-- 2049 (8 x 256 + 1)
			assert_equals ("byte_1_2049", (0).to_integer_8, l_header.byte_n_of_8 (5, 2049))
			assert_equals ("byte_2_2049", (0).to_integer_8, l_header.byte_n_of_8 (6, 2049))
			assert_equals ("byte_3_2049", (8).to_integer_8, l_header.byte_n_of_8 (7, 2049))
			assert_equals ("byte_4_2049", (1).to_integer_8, l_header.byte_n_of_8 (8, 2049))
				-- 3149 (12 x 256 + 77)
			assert_equals ("byte_1_3149", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (5, 3149))
			assert_equals ("byte_2_3149", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (6, 3149))
			assert_equals ("byte_3_3149", ('%/0x0C/').code.to_integer_8, l_header.byte_n_of_8 (7, 3149))
			assert_equals ("byte_4_3149", ('%/0x4D/').code.to_integer_8, l_header.byte_n_of_8 (8, 3149))
			-- All permutations of 0,0,0,1
			assert_equals ("byte_1_1", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (5, 1))
			assert_equals ("byte_2_1", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (6, 1))
			assert_equals ("byte_3_1", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (7, 1))
			assert_equals ("byte_4_1", ('%/0x01/').code.to_integer_8, l_header.byte_n_of_8 (8, 1))
			--	| 0,0,0,255
			assert_equals ("byte_1_255", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (5, 255))
			assert_equals ("byte_2_255", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (6, 255))
			assert_equals ("byte_3_255", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (7, 255))
			assert_equals ("byte_4_255", ('%/0xFF/').code.to_integer_8, l_header.byte_n_of_8 (8, 255))
			--	| 1,1,1,255 = 16777216 + 65536 + 256 + 255 = 16843263
			assert_equals ("byte_1_16843263", ('%/0x01/').code.to_integer_8, l_header.byte_n_of_8 (5, 16843263))
			assert_equals ("byte_2_16843263", ('%/0x01/').code.to_integer_8, l_header.byte_n_of_8 (6, 16843263))
			assert_equals ("byte_3_16843263", ('%/0x01/').code.to_integer_8, l_header.byte_n_of_8 (7, 16843263))
			assert_equals ("byte_4_16843263", ('%/0xFF/').code.to_integer_8, l_header.byte_n_of_8 (8, 16843263))
			--	| 0, 0, 0, 100
			assert_equals ("byte_1_100", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (5, 100))
			assert_equals ("byte_2_100", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (6, 100))
			assert_equals ("byte_3_100", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (7, 100))
			assert_equals ("byte_4_100", ('%/0x64/').code.to_integer_8, l_header.byte_n_of_8 (8, 100))
			--	| 5, 5, 5, 100 = (16777216 * 5 = 83886080) + (65536 * 5 = 327680) + (256 * 5 = 1280) + 100 = 84215140)
			assert_equals ("84215140", (16777216 * 5) + (65536 * 5) + (256 * 5) + 100, 84215140)
				-- INTEGER_64
			assert_equals ("byte_5_84215140", ('%/0x05/').code.to_integer_8, l_header.byte_n_of_8 (5, 84215140))
			assert_equals ("byte_6_84215140", ('%/0x05/').code.to_integer_8, l_header.byte_n_of_8 (6, 84215140))
			assert_equals ("byte_7_84215140", ('%/0x05/').code.to_integer_8, l_header.byte_n_of_8 (7, 84215140))
			assert_equals ("byte_8_84215140", ('%/0x64/').code.to_integer_8, l_header.byte_n_of_8 (8, 84215140))
			-- plus
			--	zero and
			assert_equals ("byte_1_84215140", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (5, 0))
			assert_equals ("byte_2_84215140", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (6, 0))
			assert_equals ("byte_3_84215140", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (7, 0))
			assert_equals ("byte_4_84215140", ('%/0x00/').code.to_integer_8, l_header.byte_n_of_8 (8, 0))

			-- Remaining tests to code ...
			--	2147483647
			-- 	1 and
			--	2147483646
			--	2 and
			--	2147483645
		end

feature {NONE} -- Implementation: Constants

--																								   1         1         1         1         1         1         1         1         1         1         2
--       1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
--34567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	test_header_string: STRING = "[
30-0E-0C-13-00-00-00-00-28-01-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-0D-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
]"

--																								   1         1         1         1         1         1         1         1         1         1         2
--       1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
--34567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
--Byte
-- 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 64 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 64 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 64 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 64 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00
-- Field sub-record																				00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 64 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 64 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 64 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 64 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00
	test_header_with_subrecord: STRING = "[
30-0E-0C-13-00-00-00-00-48-01-0B-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-46-4C-44-5F-43-48-41-52-00-00-00-43-01-00-00-00-0A-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-0D-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
]"

feature {NONE} -- Implementation: Headers

	test_header: FP_HEADER
			-- Test header
		do
			create Result
			Result.set_file_type_vfp -- set_file_type_foxpro_2x
			Result.set_record_count (0)
			Result.set_data_record_length (11)
		end

	generate_dbf (a_name: STRING; a_header: FP_HEADER)
		local
			l_file: RAW_FILE
		do
			create l_file.make_create_read_write (a_name)
			l_file.put_string (a_header.header_string (create {DATE}.make (2015, 1, 1)))
			l_file.close
		end

	calculate_from_msb (a_tuple: TUPLE [msb, msb2, msb3, msb4, msb5, msb6, msb7, lsb: NATURAL_8]): INTEGER_64
			-- Calculate the value of the named tuple bytes as an {INTEGER_64}
		do
			Result := ((a_tuple.msb).to_integer_64 	* (72_057_594_037_927_936).to_integer_64) +
						((a_tuple.msb2).to_integer_64 	* (281_474_976_710_656).to_integer_64) +
						((a_tuple.msb3).to_integer_64 	* (1_099_511_627_776).to_integer_64) +
						((a_tuple.msb4).to_integer_64	* (4_294_967_296).to_integer_64) +
						((a_tuple.msb5).to_integer_64 	* (16_777_216).to_integer_64) +
						((a_tuple.msb6).to_integer_64 	* (65_536).to_integer_64) +
						((a_tuple.msb7).to_integer_64 	* (256).to_integer_64) +
						((a_tuple.lsb).to_integer_64 	* (1).to_integer_64)
		end

end


