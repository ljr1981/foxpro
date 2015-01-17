note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date: 2015-01-16 10:27:47 -0500 (Fri, 16 Jan 2015) $"
	revision: "$Revision: 10604 $"
	testing: "type/manual"

class
	FP_DBF_WRITER_TEST_SET

inherit
	TEST_SET_HELPER

	FP_HEX_HELPER
		undefine
			default_create
		end

feature -- Test routines

	string_to_hex_test
			-- Test {FP_TABLE}.set_to_hex_string.
		do
			-- assert_strings_equal ("empty_string", "", string_to_hex_string (""))
			assert_strings_equal ("ABC", "41-42-43", string_to_hex_string ("ABC"))
			assert_strings_equal ("XYZ", "58-59-5A", string_to_hex_string ("XYZ"))
		end

	table_test
			-- Test of {FP_TABLE}
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("generated_2")
			l_table.header.set_file_type_vfp
			l_table.header.add_character_field ("FLD_CHAR", 10)
			l_table.add_row (["ABCDEFGHI1"])
			l_table.add_row (["ABCDEFGHI2"])
			l_table.add_row (["ABCDEFGHI3"])
			l_table.add_row (["ABCDEFGHI4"])
			l_table.add_row (["ABCDEFGHI5"])
			l_table.add_row (["ABCDEFGHI6"])
			l_table.add_row (["ABCDEFGHI7"])
			l_table.add_row (["ABCDEFGHI8"])
			l_table.add_row (["ABCDEFGHI9"])
			l_table.generate_dbf
		end

	table_test_two_string_fields
			-- Test of {FP_TABLE}
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("generated_two_string_fields")
			l_table.header.set_file_type_vfp
			l_table.header.set_record_count (0)
			l_table.header.add_character_field ("FLD_CHAR1", 10)
			l_table.header.add_character_field ("FLD_CHAR2", 10)
			l_table.add_row (["ABCDEFGHI1", "BLAH"])
			l_table.add_row (["ABCDEFGHI2", "BLAH"])
			l_table.add_row (["ABCDEFGHI3", "BLAH"])
			l_table.add_row (["ABCDEFGHI4", "BLAH"])
			l_table.add_row (["ABCDEFGHI5", "BLAH"])
			l_table.add_row (["ABCDEFGHI6", "BLAH"])
			l_table.add_row (["ABCDEFGHI7", "BLAH"])
			l_table.add_row (["ABCDEFGHI8", "BLAH"])
			l_table.add_row (["ABCDEFGHI9", "BLAHBLAHBLAH"])
			l_table.generate_dbf
		end

	table_test_two_string_fields_and_boolean
			-- Test of {FP_TABLE}
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("generated_two_string_fields_with_boolean")
			l_table.header.set_file_type_vfp
			l_table.header.set_record_count (0)
			l_table.header.add_character_field ("FLD_CHAR1", 10)
			l_table.header.add_character_field ("FLD_CHAR2", 10)
			l_table.header.add_logical_field ("FLD_BOOL")
			l_table.add_row (["ABCDEFGHI1", "BLAH", True])
			l_table.add_row (["ABCDEFGHI2", "BLAH", False])
			l_table.add_row (["ABCDEFGHI3", "BLAH", True])
			l_table.add_row (["ABCDEFGHI4", "BLAH", False])
			l_table.add_row (["ABCDEFGHI5", "BLAH", True])
			l_table.add_row (["ABCDEFGHI6", "BLAH", False])
			l_table.add_row (["ABCDEFGHI7", "BLAH", True])
			l_table.add_row (["ABCDEFGHI8", "BLAH", False])
			l_table.add_row (["ABCDEFGHI9", "BLAHBLAHBLAH", True])
			l_table.generate_dbf
		end

	table_test_two_string_fields_and_date
			-- Test of {FP_TABLE}
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("generated_two_string_fields_with_date")
			l_table.header.set_file_type_vfp
			l_table.header.set_record_count (0)
			l_table.header.add_character_field ("FLD_CHAR1", 10)
			l_table.header.add_character_field ("FLD_CHAR2", 10)
			l_table.header.add_date_field ("FLD_DATE")
			l_table.add_row (["ABCDEFGHI1", "BLAH", create {DATE}.make (2015, 12, 01)])
			l_table.add_row (["ABCDEFGHI2", "BLAH", create {DATE}.make (2015, 11, 02)])
			l_table.add_row (["ABCDEFGHI3", "BLAH", create {DATE}.make (2015, 10, 03)])
			l_table.add_row (["ABCDEFGHI4", "BLAH", create {DATE}.make (2015, 09, 04)])
			l_table.add_row (["ABCDEFGHI5", "BLAH", create {DATE}.make (2015, 08, 05)])
			l_table.add_row (["ABCDEFGHI6", "BLAH", create {DATE}.make (2015, 07, 06)])
			l_table.add_row (["ABCDEFGHI7", "BLAH", create {DATE}.make (2015, 06, 07)])
			l_table.add_row (["ABCDEFGHI8", "BLAH", create {DATE}.make (2015, 05, 08)])
			l_table.add_row (["ABCDEFGHI9", "BLAHBLAHBLAH", create {DATE}.make (2015, 04, 09)])
			l_table.generate_dbf
		end

	generated_date_comparison
			-- Test of {FP_TABLE}
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("generated_date_comparison")
			l_table.header.set_file_type_vfp
			l_table.header.set_record_count (0)
			l_table.header.add_datetime_field ("FLD_DATETM")
			l_table.header.add_character_field ("FLD_CHDATE", 8)
			l_table.add_row ([create {DATE_TIME}.make (2015, 12, 01, 11, 12, 13), "20151201"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 11, 02, 0, 0, 0), "20151102"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 10, 03, 0, 0, 0), "20151003"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 09, 04, 0, 0, 0), "20150904"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 08, 05, 0, 0, 0), "20150805"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 07, 06, 0, 0, 0), "20150706"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 06, 07, 0, 0, 0), "20150607"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 05, 08, 0, 0, 0), "20150508"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 04, 09, 0, 0, 0), "20150409"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 03, 10, 0, 0, 0), "20150310"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 02, 11, 0, 0, 0), "20150211"])
			l_table.add_row ([create {DATE_TIME}.make (2015, 01, 12, 0, 0, 0), "20150112"])
			l_table.generate_dbf
		end

	table_test_two_string_fields_and_integer
			-- Test of {FP_TABLE}
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("generated_two_string_fields_with_integer")
			l_table.header.set_file_type_vfp
			l_table.header.set_record_count (0)
			l_table.header.add_character_field ("FLD_CHAR1", 10)
			l_table.header.add_character_field ("FLD_CHAR2", 10)
			l_table.header.add_integer_field ("FLD_INT")
			l_table.add_row (["ABCDEFGHI1", "BLAH", 111])
			l_table.add_row (["ABCDEFGHI2", "BLAH", 222])
			l_table.add_row (["ABCDEFGHI3", "BLAH", 333])
			l_table.add_row (["ABCDEFGHI4", "BLAH", 444])
			l_table.add_row (["ABCDEFGHI5", "BLAH", 555])
			l_table.add_row (["ABCDEFGHI6", "BLAH", 666])
			l_table.add_row (["ABCDEFGHI7", "BLAH", 777])
			l_table.add_row (["ABCDEFGHI8", "BLAH", 888])
			l_table.add_row (["ABCDEFGHI9", "BLAHBLAHBLAH", 999])
			l_table.generate_dbf
		end

	table_test_two_string_fields_and_floats
			-- Test of {FP_TABLE}
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("generated_two_string_fields_with_floats")
			l_table.header.set_file_type_vfp
			l_table.header.set_record_count (0)
			l_table.header.add_character_field ("FLD_CHAR1", 10)
			l_table.header.add_character_field ("FLD_CHAR2", 10)
			l_table.header.add_float_field ("LAST_COST", 10, 5)
			l_table.header.add_float_field ("CASE_COST", 15, 5) -- 65.04 N15,5
			l_table.add_row (["ABCDEFGHI1", "BLAH", 5.42, 65.04])
			l_table.generate_dbf
		end

	table_test_purchase_order
			-- Test creation of PO1 table structure.
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("21400100_test")
			l_table.header.set_file_type_vfp
			l_table.header.set_record_count (0)
			l_table.header.add_character_field ("PO_NO", 10)
			l_table.header.add_character_field ("ITEM_NO", 10)
			l_table.header.add_character_field ("DESCRIPT", 30)
			l_table.header.add_character_field ("SIZE", 5)
			l_table.header.add_float_field ("LAST_COST", 10, 5)
			l_table.header.add_float_field ("CS_COST", 15, 5)
			l_table.header.add_float_field ("QTY_ORDR", 7, 1)
			l_table.header.add_float_field ("QTY_RECV", 7, 1)
			l_table.header.add_float_field ("CS_ORDR", 11, 2)
			l_table.header.add_float_field ("CS_RECV", 11, 2)
			l_table.add_row (["214010902", "CTU07000", "CANTU SBUTT NAT CURL ACT CREAM", "12 OZ", 4.15, 16.6, 24.0, 24.0, 6.0, 6.0])
			l_table.add_row (["214010902", "SS189", "CFC #1 REARRANGER (MAXIMUM)", "16 OZ", 5.42, 65.04, 72.0, 72.0, 6.0, 6.0])
			l_table.generate_dbf
		end

	table_test_purchase_order_foxbase_plus
			-- Test creation of PO1 table structure.
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("21400100_test_foxbase_plus")
			l_table.header.set_file_type_foxbase_plus_dbase_iii
			l_table.header.set_record_count (0)
			l_table.header.add_character_field ("PO_NO", 10)
			l_table.header.add_character_field ("ITEM_NO", 10)
			l_table.header.add_character_field ("DESCRIPT", 30)
			l_table.header.add_character_field ("SIZE", 5)
			l_table.header.add_float_field ("LAST_COST", 10, 5)
			l_table.header.add_float_field ("CS_COST", 15, 5)
			l_table.header.add_float_field ("QTY_ORDR", 7, 1)
			l_table.header.add_float_field ("QTY_RECV", 7, 1)
			l_table.header.add_float_field ("CS_ORDR", 11, 2)
			l_table.header.add_float_field ("CS_RECV", 11, 2)
			l_table.add_row (["214010902", "CTU07000", "CANTU SBUTT NAT CURL ACT CREAM", "12 OZ", 4.15, 16.6, 24.0, 24.0, 6.0, 6.0])
			l_table.add_row (["214010902", "SS189", "CFC #1 REARRANGER (MAXIMUM)", "16 OZ", 5.42, 65.04, 72.0, 72.0, 6.0, 6.0])
			l_table.generate_dbf
		end

	table_test_purchase_order_foxbase_plus_numeric
			-- Test creation of PO1 table structure.
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("21400100_test_foxbase_plus_numeric")
			l_table.header.set_file_type_foxbase_plus_dbase_iii
			l_table.header.set_record_count (0)
			l_table.header.add_character_field ("PO_NO", 10)
			l_table.header.add_character_field ("ITEM_NO", 10)
			l_table.header.add_character_field ("DESCRIPT", 30)
			l_table.header.add_character_field ("SIZE", 5)
			l_table.header.add_numeric_field ("LAST_COST", 10, 5)
			l_table.header.add_numeric_field ("CS_COST", 15, 5)
			l_table.header.add_numeric_field ("QTY_ORDR", 7, 1)
			l_table.header.add_numeric_field ("QTY_RECV", 7, 1)
			l_table.header.add_numeric_field ("CS_ORDR", 11, 2)
			l_table.header.add_numeric_field ("CS_RECV", 11, 2)
			l_table.add_row (["214010902", "CTU07000", "CANTU SBUTT NAT CURL ACT CREAM", "12 OZ", 4.15, 16.6, 24.0, 24.0, 6.0, 6.0])
			l_table.add_row (["214010902", "SS189", "CFC #1 REARRANGER (MAXIMUM)", "16 OZ", 5.42, 65.04, 72.0, 72.0, 6.0, 6.0])
			l_table.generate_dbf
			l_table.set_name ("eiffel.po1")
			l_table.generate_dbf
		end

	table_test_two_string_fields_and_decimal
			-- Test of {FP_TABLE}
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.set_name ("generated_two_string_fields_with_decimal")
			l_table.header.set_file_type_vfp
			l_table.header.set_record_count (0)
			l_table.header.add_character_field ("FLD_CHAR1", 10)
			l_table.header.add_character_field ("FLD_CHAR2", 10)
			l_table.header.add_currency_field ("FLD_CURR")
			l_table.add_row (["ABCDEFGHI1", "BLAH", create {DECIMAL}.make_from_string ("999.1110")])
			l_table.add_row (["ABCDEFGHI2", "BLAH", create {DECIMAL}.make_from_string ("999.2220")])
			l_table.add_row (["ABCDEFGHI3", "BLAH", create {DECIMAL}.make_from_string ("999.3330")])
			l_table.add_row (["ABCDEFGHI4", "BLAH", create {DECIMAL}.make_from_string ("999.4440")])
			l_table.add_row (["ABCDEFGHI5", "BLAH", create {DECIMAL}.make_from_string ("999.5550")])
			l_table.add_row (["ABCDEFGHI6", "BLAH", create {DECIMAL}.make_from_string ("999.6660")])
			l_table.add_row (["ABCDEFGHI7", "BLAH", create {DECIMAL}.make_from_string ("999.7770")])
			l_table.add_row (["ABCDEFGHI8", "BLAH", create {DECIMAL}.make_from_string ("999.8880")])
			l_table.add_row (["ABCDEFGHI9", "BLAHBLAHBLAH", create {DECIMAL}.make_from_string ("999.9990")])
			l_table.generate_dbf
		end

	string_data_test
			-- Test of {FP_TABLE}.string_data
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.header.add_character_field ("FLD_CURR", 10)
			assert_strings_equal ("string_test_1", "41-42-43-20-20-20-20-20-20-20", string_to_hex_string (l_table.string_data ("ABC", l_table.header.field_subrecords [1])))
		end

	decimal_data_test
			-- Test of {FP_TABLE}.decimal_data
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.header.add_currency_field ("FLD_CURR")
			assert_strings_equal ("decimal_test_1", "C6-73-98-00-00-00-00-00", string_to_hex_string (l_table.decimal_data (create {DECIMAL}.make_from_string ("999.1110"), l_table.header.field_subrecords [1])))
		end

	integer_data_test
			-- Test of {FP_TABLE}.integer_data
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.header.add_integer_field ("FLD_INT")
			assert_strings_equal ("integer_test_1", "B1-68-DE-3A", string_to_hex_string (l_table.integer_data (987654321, l_table.header.field_subrecords [1])))
		end

	boolean_data_test
			-- Test of {FP_TABLE}.boolean_data
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.header.add_logical_field ("FLD_BOOL")
			assert_strings_equal ("boolean_test_true", "54", string_to_hex_string (l_table.boolean_data (True, l_table.header.field_subrecords [1])))
			assert_strings_equal ("boolean_test_false", "20", string_to_hex_string (l_table.boolean_data (False, l_table.header.field_subrecords [1])))
		end

	date_data_test
			-- Test of {FP_TABLE}.date_data
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.header.add_date_field ("FLD_DATE")
			assert_strings_equal ("integer_test_1", "32-30-31-35-30-32-30-31", string_to_hex_string (l_table.date_data (create {DATE}.make (2015, 02, 01), l_table.header.field_subrecords [1])))
		end

	datetime_data_test
			-- Test of {FP_TABLE}.datetime_data
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
			create l_table
			l_table.header.add_datetime_field ("FLD_DATETM")
			assert_strings_equal ("integer_test_1", "0E-7F-25-00-00-00-00-00", string_to_hex_string (l_table.datetime_data (create {DATE_TIME}.make (2015, 12, 01, 0, 0 , 0), l_table.header.field_subrecords [1])))
		end

	float_data_test
			-- Test of {FP_DBF_WRITER}.float_data
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
				-- 5.42 N10,5
			create l_table
			l_table.header.add_float_field ("FLD_FLT", 10, 5)
			assert_strings_equal ("float_last_cost", "20-20-20-35-2E-34-32-30-30-30", string_to_hex_string (l_table.float_data ((5.42).truncated_to_real, l_table.header.field_subrecords [1])))

				-- 65.04 N15,5
			create l_table
			l_table.header.add_float_field ("FLD_FLT", 15, 5)
			assert_strings_equal ("float_case_cost", "20-20-20-20-20-20-20-36-35-2E-30-34-30-30-30", string_to_hex_string (l_table.float_data ((65.04).truncated_to_real, l_table.header.field_subrecords [1])))

				-- 72.0 N7,1
			create l_table
			l_table.header.add_float_field ("FLD_FLT", 7, 1)
			assert_strings_equal ("float_quantity_ordered", "20-20-20-37-32-2E-30", string_to_hex_string (l_table.float_data ((72.0).truncated_to_real, l_table.header.field_subrecords [1])))

				-- 6.0 N11,2
			create l_table
			l_table.header.add_float_field ("FLD_FLT", 11, 2)
			assert_strings_equal ("float_case_ordered", "20-20-20-20-20-20-20-36-2E-30-30", string_to_hex_string (l_table.float_data ((6.0).truncated_to_real, l_table.header.field_subrecords [1])))
		end

	numeric_data_test
			-- Test of {FP_DBF_WRITER}.numeric_data
		note
			testing:  "execution/serial"
		local
			l_table: FP_DBF_WRITER
		do
				-- 5.42 N10,5
			create l_table
			l_table.header.add_numeric_field ("FLD_NUM", 10, 5)
			assert_strings_equal ("float_last_cost", "20-20-20-35-2E-34-32-30-30-30", string_to_hex_string (l_table.float_data ((5.42).truncated_to_real, l_table.header.field_subrecords [1])))
		end
end


