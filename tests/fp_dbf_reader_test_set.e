note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	warnings: "[
		The call to `dbf_printer' is a part of the testing code and is test-only.
		What it does is take the contents of a DBF and spray it out to a file
		called "dbf_content.txt" If you open that file, you will see output that
		looks almost precisely like the output of the "hexedit.app" tool in VFP.
		We wrote this to help us quickly see whether an FP_DBF_WRITER was getting
		the output precisely the same as the one created by VFP.

		For example: You can run each of the write-tests individually, and then
		go examine the hex file content to see what it wrote in human readable
		terms.
		]"
	date: "$Date: 2015-01-16 14:16:39 -0500 (Fri, 16 Jan 2015) $"
	revision: "$Revision: 10605 $"
	testing: "type/manual"

class
	FP_DBF_READER_TEST_SET

inherit
	EQA_TEST_SET
		rename
			assert as assert_old
		end

	EQA_COMMONLY_USED_ASSERTIONS
		undefine
			default_create
		end

	FP_HEX_HELPER
		undefine
			default_create
		end

feature -- Test routines

	empty_table_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "empty_table.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
					-- Test header values from table.
				assert_strings_equal 	("1_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("1_file_type_value", 							48, 							l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("1_last_update_1_3", 							"0E-0C-18-", 					l_reader.last_update_1_3)
				assert_equal 			("1_last_update_year", 							2014, 							l_reader.last_update_1_3_year)
				assert_equal 			("1_last_update_month", 						12, 							l_reader.last_update_1_3_month)
				assert_equal 			("1_last_update_day", 							24, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("1_last_update_date", 							"12/24/2014", 					l_reader.attached_last_update_date.out)
				assert_equal 			("1_number_of_records_4_7_value", 				0, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("1_position_of_first_data_record_8_9_value", 	328, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("1_length_of_one_data_record_10_11_value", 	11, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("1_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("1_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("1_code_page_mark_29_value", 					3, 								l_reader.code_page_mark_29_value)
				assert_equal 			("1_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("1_field_count", 								1, 								l_reader.attached_last_header.field_subrecords.count)
		end

	PO1_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "21400100.PO1"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("2_file_type", 								"03-", 							l_reader.file_type_0)
				assert_equal 			("2_file_type_value", 							3, 								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("2_last_update_1_3", 							"0F-01-07-", 					l_reader.last_update_1_3)
				assert_equal 			("2_last_update_year", 							2015, 							l_reader.last_update_1_3_year)
				assert_equal 			("2_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("2_last_update_day", 							7, 								l_reader.last_update_1_3_day)
				assert_strings_equal 	("2_last_update_date", 							"01/07/2015", 					l_reader.attached_last_update_date.out)
				assert_equal 			("2_number_of_records_4_7_value", 				2, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("2_position_of_first_data_record_8_9_value", 	353, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("2_length_of_one_data_record_10_11_value", 	117, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("2_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("2_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("2_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("2_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("2_field_count", 								10, 							l_reader.attached_last_header.field_subrecords.count)
					-- Data
				check has_data: attached l_reader.last_data_content as al_data then
					assert_equal ("two_records", l_reader.number_of_records_4_7_value, al_data.count)
					check has_record_one: attached al_data [1] as al_tuple then
						check attached {STRING} al_tuple.item (2) as al_value then
							assert_strings_equal ("1_purchase_order_number", "214010902 ", al_value)
						end
						check attached {STRING} al_tuple.item (3) as al_value then
							assert_strings_equal ("1_product_number", "CTU07000  ", al_value)
						end
						check attached {STRING} al_tuple.item (4) as al_value then
							assert_strings_equal ("1_description", "CANTU SBUTT NAT CURL ACT CREAM", al_value)
						end
						check attached {STRING} al_tuple.item (5) as al_value then
							assert_strings_equal ("1_size", "12 OZ", al_value)
						end
						check attached {DECIMAL} al_tuple.item (6) as al_value then
							assert_strings_equal ("1_last_cost", "4.15000", al_value.out)
						end
						check attached {DECIMAL} al_tuple.item (7) as al_value then
							assert_strings_equal ("1_case_cost", "16.60000", al_value.out)
						end
						check attached {DECIMAL} al_tuple.item (8) as al_value then
							assert_strings_equal ("1_qty_ordr", "24.0", al_value.out)
						end
						check attached {DECIMAL} al_tuple.item (9) as al_value then
							assert_strings_equal ("1_qty_recv", "24.0", al_value.out)
						end
						check attached {DECIMAL} al_tuple.item (10) as al_value then
							assert_strings_equal ("1_case_ordr", "6.00", al_value.out)
						end
						check attached {DECIMAL} al_tuple.item (11) as al_value then
							assert_strings_equal ("1_case_recv", "6.00", al_value.out)
						end
					end
					check has_record_two: attached al_data [2] as al_tuple then
						check attached {STRING} al_tuple.item (2) as al_value then
							assert_strings_equal ("2_purchase_order_number", "214010902 ", al_value)
						end
						check attached {STRING} al_tuple.item (3) as al_value then
							assert_strings_equal ("2_product_number", "SS189     ", al_value)
						end
						check attached {STRING} al_tuple.item (4) as al_value then
							assert_strings_equal ("2_description", "CFC #1 REARRANGER [MAXIMUM]   ", al_value)
						end
						check attached {STRING} al_tuple.item (5) as al_value then
							assert_strings_equal ("2_size", "16 OZ", al_value)
						end
						check attached {DECIMAL} al_tuple.item (6) as al_value then
							assert_strings_equal ("2_last_cost", "5.42000", al_value.out)
						end
						check attached {DECIMAL} al_tuple.item (7) as al_value then
							assert_strings_equal ("2_case_cost", "65.04000", al_value.out)
						end
						check attached {DECIMAL} al_tuple.item (8) as al_value then
							assert_strings_equal ("2_qty_ordr", "72.0", al_value.out)
						end
						check attached {DECIMAL} al_tuple.item (9) as al_value then
							assert_strings_equal ("2_qty_recv", "72.0", al_value.out)
						end
						check attached {DECIMAL} al_tuple.item (10) as al_value then
							assert_strings_equal ("2_case_ordr", "6.00", al_value.out)
						end
						check attached {DECIMAL} al_tuple.item (11) as al_value then
							assert_strings_equal ("2_case_recv", "6.00", al_value.out)
						end
					end
				end
		end

	test_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "21400100_test.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("3_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("3_file_type_value", 							48, 							l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
--				assert_strings_equal 	("3_last_update_1_3", 							"0F-01-0C-", 					l_reader.last_update_1_3)
--				assert_equal 			("3_last_update_year", 							2015, 							l_reader.last_update_1_3_year)
--				assert_equal 			("3_last_update_month", 						1, 								l_reader.last_update_1_3_month)
--				assert_equal 			("3_last_update_day", 							12, 							l_reader.last_update_1_3_day)
--				assert_strings_equal 	("3_last_update_date", 							"01/12/2015", 					l_reader.attached_last_update_date.out)
				assert_equal 			("3_number_of_records_4_7_value", 				2, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("3_position_of_first_data_record_8_9_value", 	616, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("3_length_of_one_data_record_10_11_value", 	117, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("3_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("3_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("3_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("3_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("3_field_count", 								10, 							l_reader.attached_last_header.field_subrecords.count)
		end

	foxbase_plus_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "21400100_test_foxbase_plus.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("4_file_type", 								"03-", 							l_reader.file_type_0)
				assert_equal 			("4_file_type_value", 							3, 								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
--				assert_strings_equal 	("4_last_update_1_3", 							"0F-01-0C-", 					l_reader.last_update_1_3)
--				assert_equal 			("4_last_update_year", 							2015, 							l_reader.last_update_1_3_year)
--				assert_equal 			("4_last_update_month", 						1, 								l_reader.last_update_1_3_month)
--				assert_equal 			("4_last_update_day", 							12, 							l_reader.last_update_1_3_day)
--				assert_strings_equal 	("4_last_update_date", 							"01/12/2015", 					l_reader.attached_last_update_date.out)
				assert_equal 			("4_number_of_records_4_7_value", 				2, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("4_position_of_first_data_record_8_9_value", 	353, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("4_length_of_one_data_record_10_11_value", 	117, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("4_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("4_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("4_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("4_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("4_field_count", 								10, 								l_reader.attached_last_header.field_subrecords.count)
		end

	foxbase_plus_numeric_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "21400100_test_foxbase_plus_numeric.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("5_file_type", 								"03-", 							l_reader.file_type_0)
				assert_equal 			("5_file_type_value", 							3, 								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
--				assert_strings_equal 	("5_last_update_1_3", 							"0F-01-0C-", 					l_reader.last_update_1_3)
--				assert_equal 			("5_last_update_year", 							2015, 							l_reader.last_update_1_3_year)
--				assert_equal 			("5_last_update_month", 						1, 								l_reader.last_update_1_3_month)
--				assert_equal 			("5_last_update_day", 							12, 							l_reader.last_update_1_3_day)
--				assert_strings_equal 	("5_last_update_date", 							"01/12/2015", 					l_reader.attached_last_update_date.out)
				assert_equal 			("5_number_of_records_4_7_value", 				2, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("5_position_of_first_data_record_8_9_value", 	353, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("5_length_of_one_data_record_10_11_value", 	117, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("5_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("5_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("5_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("5_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("5_field_count", 								10,								l_reader.attached_last_header.field_subrecords.count)
		end

	empty_table_2_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "empty_table_2.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("6_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("6_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("6_last_update_1_3", 							"0E-0C-18-", 					l_reader.last_update_1_3)
				assert_equal 			("6_last_update_year", 							2014, 							l_reader.last_update_1_3_year)
				assert_equal 			("6_last_update_month", 						12, 							l_reader.last_update_1_3_month)
				assert_equal 			("6_last_update_day", 							24, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("6_last_update_date", 							"12/24/2014", 					l_reader.attached_last_update_date.out)
				assert_equal 			("6_number_of_records_4_7_value", 				0, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("6_position_of_first_data_record_8_9_value", 	360, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("6_length_of_one_data_record_10_11_value", 	21, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("6_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("6_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("6_code_page_mark_29_value", 					3, 								l_reader.code_page_mark_29_value)
				assert_equal 			("6_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("6_field_count", 								2, 								l_reader.attached_last_header.field_subrecords.count)
		end

	generated_2_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "generated_2.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("7_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("7_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("7_last_update_1_3", 							"0A-01-01-", 					l_reader.last_update_1_3)
				assert_equal 			("7_last_update_year", 							2010, 							l_reader.last_update_1_3_year)
				assert_equal 			("7_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("7_last_update_day", 							1, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("7_last_update_date", 							"01/01/2010", 					l_reader.attached_last_update_date.out)
				assert_equal 			("7_number_of_records_4_7_value", 				9, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("7_position_of_first_data_record_8_9_value", 	328, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("7_length_of_one_data_record_10_11_value", 	11, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("7_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("7_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("7_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("7_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("7_field_count", 								1, 								l_reader.attached_last_header.field_subrecords.count)
		end

	generated_date_only_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "generated_date_only.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("8_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("8_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("8_last_update_1_3", 							"0F-01-0C-", 					l_reader.last_update_1_3)
				assert_equal 			("8_last_update_year", 							2015, 							l_reader.last_update_1_3_year)
				assert_equal 			("8_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("8_last_update_day", 							12, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("8_last_update_date", 							"01/12/2015", 					l_reader.attached_last_update_date.out)
				assert_equal 			("8_number_of_records_4_7_value", 				1, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("8_position_of_first_data_record_8_9_value", 	328, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("8_length_of_one_data_record_10_11_value", 	9, 								l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("8_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("8_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("8_code_page_mark_29_value", 					3, 								l_reader.code_page_mark_29_value)
				assert_equal 			("8_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("8_field_count", 								1, 								l_reader.attached_last_header.field_subrecords.count)
		end

	generated_date_comparison_read_and_parse_test
			-- Read and parse and test data for generated table.
		note
			testing: "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "generated_date_comparison.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("8_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("8_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("7_last_update_1_3", 							"0A-01-01-", 					l_reader.last_update_1_3)
				assert_equal 			("7_last_update_year", 							2010, 							l_reader.last_update_1_3_year)
				assert_equal 			("7_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("7_last_update_day", 							1, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("7_last_update_date", 							"01/01/2010", 					l_reader.attached_last_update_date.out)
				assert_equal 			("8_number_of_records_4_7_value", 				12, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("8_position_of_first_data_record_8_9_value", 	360, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("8_length_of_one_data_record_10_11_value", 	17, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("8_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("8_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("8_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("8_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("8_field_count", 								2, 								l_reader.attached_last_header.field_subrecords.count)
				check has_data: attached l_reader.last_data_content as al_data then
					assert_equal ("two_records", l_reader.number_of_records_4_7_value, al_data.count)
					check has_record_one: attached al_data [1] as al_tuple then
						check attached {DATE_TIME} al_tuple.item (2) as al_value and then attached {STRING} al_tuple.item (3) as al_string_date then
							assert_strings_equal ("date_string", "20151201", al_string_date)
							assert_strings_equal ("date_time", "12/01/2015 11:12:13.000 AM", al_value.out) -- 12/01/2015 11:12:13 AM
							assert_strings_equal ("date_to_date", al_string_date, al_value.year.out + al_value.month.out + "0" + al_value.day.out)
						end
					end
					check has_record_two: attached al_data [2] as al_tuple then
						check attached {DATE_TIME} al_tuple.item (2) as al_value and then attached {STRING} al_tuple.item (3) as al_string_date then
							assert_strings_equal ("2_date_string", "20151102", al_string_date)
							assert_strings_equal ("2_date_time", "11/02/2015 12:00:00.000 AM", al_value.out)
							assert_strings_equal ("2_date_to_date", al_string_date, al_value.year.out + al_value.month.out + "0" + al_value.day.out)
						end
					end
					check has_record_three: attached al_data [3] as al_tuple then
						check attached {DATE_TIME} al_tuple.item (2) as al_value and then attached {STRING} al_tuple.item (3) as al_string_date then
							assert_strings_equal ("3_date_string", "20151003", al_string_date)
							assert_strings_equal ("3_date_time", "10/03/2015 12:00:00.000 AM", al_value.out)
							assert_strings_equal ("3_date_to_date", al_string_date, al_value.year.out + al_value.month.out + "0" + al_value.day.out)
						end
					end
				end
		end

	generated_two_string_fields_with_date_read_and_parse_test
			-- Actual read and parse test of DBF header and data.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "generated_two_string_fields_with_date.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("8_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("8_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("7_last_update_1_3", 							"0A-01-01-", 					l_reader.last_update_1_3)
				assert_equal 			("7_last_update_year", 							2010, 							l_reader.last_update_1_3_year)
				assert_equal 			("7_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("7_last_update_day", 							1, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("7_last_update_date", 							"01/01/2010", 					l_reader.attached_last_update_date.out)
				assert_equal 			("8_number_of_records_4_7_value", 				9, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("8_position_of_first_data_record_8_9_value", 	392, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("8_length_of_one_data_record_10_11_value", 	29, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("8_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("8_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("8_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("8_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("8_field_count", 								3, 								l_reader.attached_last_header.field_subrecords.count)
					-- Confirm dates read in ...
				check has_data: attached l_reader.last_data_content as al_data then
					assert_equal ("two_records", l_reader.number_of_records_4_7_value, al_data.count)
					check has_record_one: attached al_data [1] as al_tuple then
						check attached {STRING} al_tuple.item (2) as al_value then
							assert_strings_equal ("1_purchase_order_number", "ABCDEFGHI1", al_value)
						end
						check attached {STRING} al_tuple.item (3) as al_value then
							assert_strings_equal ("1_product_number", "BLAH      ", al_value)
						end
						check attached {DATE} al_tuple.item (4) as al_value then
							assert_strings_equal ("1_product_number", "12/01/2015", al_value.out)
						end
					end
					check has_record_one: attached al_data [2] as al_tuple then
						check attached {STRING} al_tuple.item (2) as al_value then
							assert_strings_equal ("1_purchase_order_number", "ABCDEFGHI2", al_value)
						end
						check attached {STRING} al_tuple.item (3) as al_value then
							assert_strings_equal ("1_product_number", "BLAH      ", al_value)
						end
						check attached {DATE} al_tuple.item (4) as al_value then
							assert_strings_equal ("1_product_number", "11/02/2015", al_value.out)
						end
					end
						-- ... to last record ...
					check has_record_one: attached al_data [l_reader.number_of_records_4_7_value] as al_tuple then
						check attached {STRING} al_tuple.item (2) as al_value then
							assert_strings_equal ("1_purchase_order_number", "ABCDEFGHI9", al_value)
						end
						check attached {STRING} al_tuple.item (3) as al_value then
							assert_strings_equal ("1_product_number", "BLAHBLAHBL", al_value)
						end
						check attached {DATE} al_tuple.item (4) as al_value then
							assert_strings_equal ("1_product_number", "04/09/2015", al_value.out)
						end
					end
				end
		end

	generated_multi_table_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "generated_multi_table.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("9_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("9_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("9_last_update_1_3", 							"0F-01-01-", 					l_reader.last_update_1_3)
				assert_equal 			("9_last_update_year", 							2015, 							l_reader.last_update_1_3_year)
				assert_equal 			("9_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("9_last_update_day", 							1, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("9_last_update_date", 							"01/01/2015", 					l_reader.attached_last_update_date.out)
				assert_equal 			("9_number_of_records_4_7_value", 				0, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("9_position_of_first_data_record_8_9_value", 	552, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("9_length_of_one_data_record_10_11_value", 	60, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("9_reserved_12_27_value", 						reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("9_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("9_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("9_reserved_30_31_value", 						reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("9_field_count", 								8, 								l_reader.attached_last_header.field_subrecords.count)
		end

	generated_table_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "generated_table.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("10_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("10_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("9_last_update_1_3", 							"0F-01-01-", 					l_reader.last_update_1_3)
				assert_equal 			("9_last_update_year", 							2015, 							l_reader.last_update_1_3_year)
				assert_equal 			("9_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("9_last_update_day", 							1, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("9_last_update_date", 							"01/01/2015", 					l_reader.attached_last_update_date.out)
				assert_equal 			("10_number_of_records_4_7_value", 				0, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("10_position_of_first_data_record_8_9_value", 	328, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("10_length_of_one_data_record_10_11_value", 	11, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("10_reserved_12_27_value", 					reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("10_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("10_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("10_reserved_30_31_value", 					reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("10_field_count", 								1, 								l_reader.attached_last_header.field_subrecords.count)
		end

	generated_table_2_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "generated_table_2.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("11_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("11_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("9_last_update_1_3", 							"0F-01-01-", 					l_reader.last_update_1_3)
				assert_equal 			("9_last_update_year", 							2015, 							l_reader.last_update_1_3_year)
				assert_equal 			("9_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("9_last_update_day", 							1, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("9_last_update_date", 							"01/01/2015", 					l_reader.attached_last_update_date.out)
				assert_equal 			("11_number_of_records_4_7_value", 				0, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("11_position_of_first_data_record_8_9_value", 	360, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("11_length_of_one_data_record_10_11_value", 	32, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("11_reserved_12_27_value", 					reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("11_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("11_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("11_reserved_30_31_value", 					reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("11_field_count", 								2, 								l_reader.attached_last_header.field_subrecords.count)
		end

	generated_table_3_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "generated_table_3.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("12_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("12_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("9_last_update_1_3", 							"0F-01-01-", 					l_reader.last_update_1_3)
				assert_equal 			("9_last_update_year", 							2015, 							l_reader.last_update_1_3_year)
				assert_equal 			("9_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("9_last_update_day", 							1, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("9_last_update_date", 							"01/01/2015", 					l_reader.attached_last_update_date.out)
				assert_equal 			("12_number_of_records_4_7_value", 				0, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("12_position_of_first_data_record_8_9_value", 	392, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("12_length_of_one_data_record_10_11_value", 	42, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("12_reserved_12_27_value", 					reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("12_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("12_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("12_reserved_30_31_value", 					reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("12_field_count", 								3, 								l_reader.attached_last_header.field_subrecords.count)
		end

	generated_two_string_fields_read_and_parse_test
			-- Actual read and parse test of DBF header.
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "generated_two_string_fields.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("13_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("13_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("7_last_update_1_3", 							"0A-01-01-", 					l_reader.last_update_1_3)
				assert_equal 			("7_last_update_year", 							2010, 							l_reader.last_update_1_3_year)
				assert_equal 			("7_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("7_last_update_day", 							1, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("7_last_update_date", 							"01/01/2010", 					l_reader.attached_last_update_date.out)
				assert_equal 			("13_number_of_records_4_7_value", 				9, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("13_position_of_first_data_record_8_9_value", 	360, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("13_length_of_one_data_record_10_11_value", 	21, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("13_reserved_12_27_value", 					reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("13_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("13_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("13_reserved_30_31_value", 					reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("13_field_count", 								2, 								l_reader.attached_last_header.field_subrecords.count)
		end

	generated_two_string_fields_with_integer_read_and_parse_test
			-- Integer reading
		note
			testing:  "execution/serial"
		local
			l_reader: FP_DBF_READER
			l_dbf_name: STRING
		do
			l_dbf_name := "generated_two_string_fields_with_integer.dbf"
			dbf_printer (l_dbf_name)
			create l_reader
			l_reader.read_dbf (l_dbf_name)
				assert_strings_equal 	("13_file_type", 								"30-", 							l_reader.file_type_0)
				assert_equal 			("13_file_type_value", 							48,								l_reader.file_type_0_value) -- 0x30h --> 3 x 16 = 48
				assert_strings_equal 	("7_last_update_1_3", 							"0A-01-01-", 					l_reader.last_update_1_3)
				assert_equal 			("7_last_update_year", 							2010, 							l_reader.last_update_1_3_year)
				assert_equal			("7_last_update_month", 						1, 								l_reader.last_update_1_3_month)
				assert_equal 			("7_last_update_day", 							1, 							l_reader.last_update_1_3_day)
				assert_strings_equal 	("7_last_update_date", 							"01/01/2010", 					l_reader.attached_last_update_date.out)
				assert_equal 			("13_number_of_records_4_7_value", 				9, 								l_reader.number_of_records_4_7_value)
				assert_equal 			("13_position_of_first_data_record_8_9_value", 	392, 							l_reader.position_of_first_data_record_8_9_value)
				assert_equal 			("13_length_of_one_data_record_10_11_value", 	25, 							l_reader.length_of_one_data_record_10_11_value)
				assert_strings_equal 	("13_reserved_12_27_value", 					reserved_12_27_test_result, 	l_reader.reserved_12_27_value)
				assert_equal 			("13_table_flag_28_value", 						0, 								l_reader.table_flag_28_value)
				assert_equal 			("13_code_page_mark_29_value", 					0, 								l_reader.code_page_mark_29_value)
				assert_equal 			("13_reserved_30_31_value", 					reserved_30_31_test_result, 	l_reader.reserved_30_31_value)
				assert_equal 			("13_field_count", 								3, 								l_reader.attached_last_header.field_subrecords.count)
					-- Confirm dates read in ...
				check has_data: attached l_reader.last_data_content as al_data then
					assert_equal ("two_records", l_reader.number_of_records_4_7_value, al_data.count)
					check has_record_one: attached al_data [1] as al_tuple then
						check attached {STRING} al_tuple.item (2) as al_value then
							assert_strings_equal ("1_purchase_order_number", "ABCDEFGHI1", al_value)
						end
						check attached {STRING} al_tuple.item (3) as al_value then
							assert_strings_equal ("1_product_number", "BLAH      ", al_value)
						end
						check attached {INTEGER} al_tuple.item (4) as al_value then
							assert_equal ("1_integer", 111, al_value)
						end
					end
				end
		end

feature {NONE} -- Implementation: Test Support

	reserved_12_27_test_result: STRING
			-- 12 to 27 as 0x00
		once
			create Result.make_empty
			across 12 |..| 27 as ic loop Result.append_character ('%/0x00/') end
		end

	reserved_30_31_test_result: STRING
			-- 30 to 31 as 0x00
		once
			create Result.make_empty
			across 1 |..| 2 as ic loop Result.append_character ('%/0x00/') end
		end


	dbf_printer (a_file_name: STRING)
			-- A test-support only feature
		note
			warnings: "[
				The call to `dbf_printer' is a part of the testing code and is test-only. 
				What it does is take the contents of a DBF and spray it out to a file 
				called "dbf_content.txt" If you open that file, you will see output that 
				looks almost precisely like the output of the "hexedit.app" tool in VFP. 
				We wrote this to help us quickly see whether an FP_DBF_WRITER was getting 
				the output precisely the same as the one created by VFP.
				
				For example: You can run each of the write-tests individually, and then 
				go examine the hex file content to see what it wrote in human readable 
				terms.
				]"
		local
			l_file: RAW_FILE
			l_hex: STRING_32
			l_text: STRING_32
			i: INTEGER
		do
			create out_file.make_create_read_write (out_file_name)
			create l_text.make_empty
			create l_file.make_open_read (a_file_name)
			line_out ("File-name: " + a_file_name + "%N")
			line_out ("======================================%N")
			line_out ("Legend:%N")
			line_out ("--------------------------------------%N")
			line_out ("»: Space-char%N")
			line_out ("======================================%N")
			-- 		00000020 46-4C-44-5F-43-48-41-52-00-00-00-43-01-00-00-00 FLD_CHAR
			line_out ("Hex-Addr=00-01-02-03-04-05-06-07-08-09-0A-0B-0C-0D-0E-0F       Text%N")
			line_out ("Dec-Addr=00-01-02-03-04-05-06-07-08-09-10-11-12-13-14-15 0123456789ABCDEF%N")
			line_out ("======== =============================================== ================%N")
			line_out ("00000000 ")
			across
				1 |..| l_file.count as ic
			loop
				l_file.read_character
				l_hex := l_file.last_character.code.to_hex_string
				l_hex.remove_head (6)
				line_out (l_hex)
				if (ic.item \\ 16) = 0 then
					line_out (" ")
					l_text.append_character (l_file.last_character)
					l_text.replace_substring_all ("%N", "»")
					line_out (l_text)
					create l_text.make_empty
					line_out ("(@" + i.out + ")%N")
					l_hex := ic.item.to_hex_string
					line_out (l_hex + " ")
				else
					line_out ("-")
					l_text.append_character (l_file.last_character)
				end
				l_hex := l_file.last_character.code.to_hex_string
				l_hex.remove_head (6)
				l_hex.append_character ('-')
				i := ic.item - 1
			end
			line_out ("«EOF»%N")
			l_file.close
			check attached out_file as al_out_file then al_out_file.close end
		end

	out_file: detachable PLAIN_TEXT_FILE
			-- DBF output file.
		attribute
			create Result.make_create_read_write (out_file_name)
		end

	out_file_name: STRING = "dbf_content.txt"

	line_out (a_line: STRING)
		do
			check attached out_file as al_out_file then al_out_file.put_string (a_line) end
			print (a_line)
		end

end


