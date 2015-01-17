note
	description: "[
		DBF Reader
		]"
	synopsis: "[
		Given a FoxPro 2.x or Visual FoxPro DBF file, call `read_dbf'. When complete,
		access `last_data_content' for the results of what data was read from the file.
		Use the other "Access: Extracted" features to derive information about the read
		DBF (e.g. field count, record count, sizes, and so on).

		See EIS link below for more information.
		]"
	EIS: "name=readme", "protocol=PDF", "tag=readme",
			"src=$JINNY_TRUNK\jinny_foxpro\readme.pdf"

	date: "$Date: 2015-01-16 10:27:47 -0500 (Fri, 16 Jan 2015) $"
	revision: "$Revision: 10604 $"

class
	FP_DBF_READER

inherit
	ANY
		redefine
			default_create
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		do
			reset
		end

feature -- Access: Last

	last_header: detachable like compute_header
			-- Last `compute_header'

	attached_last_header: like compute_header
			-- Attached version of `last_header'.
		do
			check attached last_header as al_header then Result := al_header end
		end

	last_field_count: INTEGER_32
			-- `last_field_count'

	last_data_content: ARRAYED_LIST [attached like record_anchor]
			-- `last_data_content' read from file.
		attribute
			create Result.make (0)
		end

feature -- Access: Extracted

		-- Raw extracted header strings
	file_type_0,
	last_update_1_3,
	number_of_records_4_7,
	position_of_first_data_record_8_9,
	length_of_one_data_record_10_11,
	reserved_12_27,
	table_flag_28,
	code_page_mark_29,
	reserved_30_31: STRING
		note
			synopsis: "[
				The features above represent data that is extracted
				from a DBF file as a stream of character bytes (e.g. STRING).
				The data contained in the string is a mix of printable and
				non-printable data, which must be further intpreted for a
				value computed from the string to a usable Eiffel type.
				]"
		attribute
			create Result.make_empty
		end

		-- Header values
	file_type_0_value: INTEGER_32
	last_update_1_3_year,
	last_update_1_3_month,
	last_update_1_3_day: INTEGER
	last_update_1_3_value: detachable DATE
	number_of_records_4_7_value,
	position_of_first_data_record_8_9_value,
	length_of_one_data_record_10_11_value: INTEGER_32
	reserved_12_27_value: STRING
	table_flag_28_value: INTEGER_32
	code_page_mark_29_value: INTEGER_32
	reserved_30_31_value: STRING
		note
			synopsis: "[
				The features above represent data that has been computed from
				the raw {STRING} values (e.g. see feature set above). The
				numbers in the feature names represent the now frozen DBF byte
				numbers (columns) from which the data is taken. For example:
				The `number_of_records_4_7_value' represents data taken from
				bytes 4, 5, 6, and 7 of a DBF header stream of characters, starting
				at byte 0 (.e.g byte #4 is really byte 5 starting from 1).
				]"
		attribute
			create Result.make_empty
		end

	attached_last_update_date: DATE
			-- Attached version of `last_update_1_3_value'.
		do
			check attached last_update_1_3_value as al_date then Result := al_date end
		end

feature -- Basic Operations

	read_dbf (a_file_name: STRING)
			-- The `read_dbf' of `a_file' in a list like `last_data_content'.
		note
			synopsis: "[
				Read a DBF file found at (drive-path-file-name) `a_file_name', leaving
				the results of the reading in the `last_data_content' feature as an
				array of tuples. See `record_anchor' for tuple type. You can also redefine
				the record anchor in descendents to more appropriately define precise
				record structures.
				
				Reading of a DBF file is a three-step process:
				(1) Open the file, reading the header.
				(2) Parse the field specifications in prep for data loading.
				(3) Load the data per the header and field specifications.
				]"
			warning: "[
				The	Client caller of this routine is responsible to ensure the file
				exists and is a valid DBF file before-hand. Currently, there is no
				library code that validates the DBF prior to utilization by this
				feature.
				]"
		require
			non_empty_name: not a_file_name.is_empty
		local
			l_file: RAW_FILE
		do
			create l_file.make_open_read (a_file_name)
			check exists: l_file.exists end
			check at_start: l_file.position = 0 end
			read_file_for_header (l_file)
			check ready_for_subrecords: l_file.position = {FP_CONSTANTS}.header_block_size end
			read_file_for_field_specs (l_file)
			check ready_for_data: l_file.position = (last_field_count * {FP_CONSTANTS}.subrecord_size + {FP_CONSTANTS}.header_block_size) end
			l_file.read_character -- 0x0Dh
			check zero_dee: l_file.last_character.is_equal ('%/0x0D/') end
			read_file_for_all_data (l_file)
			l_file.close
		ensure
			at_least_one_field: last_field_count >= 1
			has_header: attached last_header
			updated_file: last_update_1_3_year >= 0
		end

	reset
			-- Reset Current.
		note
			synopsis: "[
				The intent of this feature is to reset the reader between
				DBF file specifications. When a new DBF file is loaded
				these values will reflect the new DBF file specifications.
				]"
		do
			last_data_content.wipe_out
			create file_type_0.make_empty
			create last_update_1_3.make_empty
			create number_of_records_4_7.make_empty
			create position_of_first_data_record_8_9.make_empty
			create length_of_one_data_record_10_11.make_empty
			create reserved_12_27.make_empty
			create reserved_12_27_value.make_empty
			create table_flag_28.make_empty
			create code_page_mark_29.make_empty
			create reserved_30_31.make_empty
			create reserved_30_31_value.make_empty
			last_field_count := 0
		ensure
			no_content: last_data_content.is_empty
			no_field_count: last_field_count = 0
		end

	compute_header: FP_HEADER
			-- `compute_header' available from Current.
		note
			synopsis: "[
				A new header can be computed from the header specifications
				loaded from the DBF file. The header specification makes for
				a simpler handling of incoming DBF files.
				]"
		do
			create Result
			Result.set_data_record_length (length_of_one_data_record_10_11_value)
			if file_type_0_value = 3 then
				Result.set_file_type_foxbase_plus_dbase_iii
			else
				Result.set_file_type_vfp
			end
			Result.set_first_data_record_start_byte (position_of_first_data_record_8_9_value)
			Result.set_record_count (number_of_records_4_7_value)
		end

feature {NONE} -- Implementation

	read_file_for_header (a_file: RAW_FILE)
			-- Read `a_file', parsing it to header information.
		note
			synopsis: "[
				Handles the first step in reading a DBF file from disk and parsing
				it into Eiffel data. The routine scans the header byte-by-byte, 
				extracting and building parsed header information as it goes.
				]"
		require
			exists: a_file.exists
		local
			i: INTEGER_32
			l_hex: STRING
		do
			across 1 |..| {FP_CONSTANTS}.header_block_size as ic loop
				a_file.read_character
				l_hex := a_file.last_character.code.to_hex_string
				l_hex.remove_head ({FP_CONSTANTS}.hex_head_reduction_value)
				l_hex.append_character ('-')
				i := ic.item - 1
				inspect i
				when 0 then
					file_type_0.append_string (l_hex)
					file_type_0_value := a_file.last_character.code
				when 1 then
					last_update_1_3.append_string (l_hex)
					last_update_1_3_year := a_file.last_character.code + {FP_CONSTANTS}.year_2000
				when 2 then
					last_update_1_3.append_string (l_hex)
					last_update_1_3_month := a_file.last_character.code
				when 3 then
					last_update_1_3.append_string (l_hex)
					last_update_1_3_day := a_file.last_character.code
					create last_update_1_3_value.make (last_update_1_3_year, last_update_1_3_month, last_update_1_3_day)
				when 4 then
					number_of_records_4_7.append_string (l_hex)
					number_of_records_4_7_value := a_file.last_character.code
				when 5 then
					number_of_records_4_7.append_string (l_hex)
					number_of_records_4_7_value := number_of_records_4_7_value + (a_file.last_character.code * 256)
				when 6 then
					number_of_records_4_7.append_string (l_hex)
					number_of_records_4_7_value := number_of_records_4_7_value + (a_file.last_character.code * 65_536)
				when 7 then
					number_of_records_4_7.append_string (l_hex)
					number_of_records_4_7_value := number_of_records_4_7_value + (a_file.last_character.code * 16_777_216)
				when 8 then
					position_of_first_data_record_8_9.append_string (l_hex)
					position_of_first_data_record_8_9_value := a_file.last_character.code
				when 9 then
					position_of_first_data_record_8_9.append_string (l_hex)
					position_of_first_data_record_8_9_value := position_of_first_data_record_8_9_value + (a_file.last_character.code * 256)
				when 10 then
					length_of_one_data_record_10_11.append_string (l_hex)
					length_of_one_data_record_10_11_value := a_file.last_character.code
				when 11 then
					length_of_one_data_record_10_11.append_string (l_hex)
					length_of_one_data_record_10_11_value := length_of_one_data_record_10_11_value + (a_file.last_character.code * 256)
				when 12 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 13 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 14 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 15 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 16 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 17 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 18 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 19 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 20 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 21 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 22 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 23 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 24 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 25 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 26 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 27 then
					reserved_12_27.append_string (l_hex)
					reserved_12_27_value.append_character (a_file.last_character)
				when 28 then
					table_flag_28.append_string (l_hex)
					table_flag_28_value := a_file.last_character.code
				when 29 then
					code_page_mark_29.append_string (l_hex)
					code_page_mark_29_value := a_file.last_character.code
				when 30 then
					reserved_30_31.append_string (l_hex)
					reserved_30_31_value.append_character (a_file.last_character)
				when 31 then
					reserved_30_31.append_string (l_hex)
					reserved_30_31_value.append_character (a_file.last_character)
				else
					do_nothing
				end
			end
		end

	read_file_for_field_specs (a_file: RAW_FILE)
			-- Read `a_file', parsing out subfield specifications.
		note
			warning: "[
				Some field specification information has been deliberately left
				out, such as: displacement, flags, and auto-increment. These use-cases
				are not relevant to our needs, so they have been excluded from the code.
				However, the commented code can be removed and re-implemented as needed.
				]"
		require
			exists: a_file.exists
		local
			i: INTEGER_32
			l_field_name,
			l_block: STRING
			l_field_type: CHARACTER_8
--			l_displacement: INTEGER_32
			l_field_length: INTEGER_32
			l_field_decimals: INTEGER_32
--			l_field_flags: INTEGER_32
--			l_field_auto: INTEGER_32
--			l_field_auto_step: INTEGER_32
			l_header: FP_HEADER
		do
			l_header := compute_header
			if l_header.file_type.is_equal ({FP_CONSTANTS}.file_type_foxbase_plus_dbase_iii) then
				last_field_count := position_of_first_data_record_8_9_value - {FP_CONSTANTS}.subrecord_size - 1
			else
				last_field_count := position_of_first_data_record_8_9_value - {FP_CONSTANTS}.subrecord_size - {FP_CONSTANTS}.backlink_area_size - 1
			end
			check correct_count: (last_field_count \\ {FP_CONSTANTS}.subrecord_size) = 0 end
			last_field_count := (last_field_count / {FP_CONSTANTS}.subrecord_size).truncated_to_integer
			across 1 |..| last_field_count as ic_field loop
				a_file.readstream ({FP_CONSTANTS}.subrecord_size)
				l_block := a_file.last_string
				check block_32: l_block.count = {FP_CONSTANTS}.subrecord_size end
				l_field_name 		:= l_block.substring (1, 10)
				l_field_type 		:= l_block [12]
--				l_displacement 		:= l_block [13].code
--				l_displacement 		:= l_displacement + (l_block [14].code * {FP_CONSTANTS}.msb7_multiplier_256)
--				l_displacement 		:= l_displacement + (l_block [15].code * {FP_CONSTANTS}.msb6_multiplier_65_536)
--				l_displacement 		:= l_displacement + (l_block [16].code * {FP_CONSTANTS}.msb5_multiplier_16_777_216)
				l_field_length 		:= l_block [17].code
				l_field_decimals 	:= l_block [18].code
--				l_field_flags 		:= l_block [19].code
--				l_field_auto 		:= l_block [20].code
--				l_field_auto 		:= l_field_auto + (l_block [21].code * {FP_CONSTANTS}.msb7_multiplier_256)
--				l_field_auto 		:= l_field_auto + (l_block [22].code * {FP_CONSTANTS}.msb6_multiplier_65_536)
--				l_field_auto 		:= l_field_auto + (l_block [23].code * {FP_CONSTANTS}.msb5_multiplier_16_777_216)
--				l_field_auto_step 	:= l_block [24].code
				inspect l_field_type
				when {FP_CONSTANTS}.field_type_blob then
					do_nothing
				when {FP_CONSTANTS}.field_type_character then
					l_header.add_character_field (l_field_name, l_field_length)
				when {FP_CONSTANTS}.field_type_currency then
					l_header.add_currency_field (l_field_name)
				when {FP_CONSTANTS}.field_type_date then
					l_header.add_date_field (l_field_name)
				when {FP_CONSTANTS}.field_type_datetime then
					l_header.add_datetime_field (l_field_name)
				when {FP_CONSTANTS}.field_type_double then
					l_header.add_double_field (l_field_name, l_field_length, l_field_decimals)
				when {FP_CONSTANTS}.field_type_float then
					l_header.add_float_field (l_field_name, l_field_length, l_field_decimals)
				when {FP_CONSTANTS}.field_type_general then
					do_nothing
				when {FP_CONSTANTS}.field_type_integer then
					l_header.add_integer_field (l_field_name)
				when {FP_CONSTANTS}.field_type_logical then
					l_header.add_logical_field (l_field_name)
				when {FP_CONSTANTS}.field_type_memo then
					do_nothing
				when {FP_CONSTANTS}.field_type_numeric then
					l_header.add_numeric_field (l_field_name, l_field_length, l_field_decimals)
				when {FP_CONSTANTS}.field_type_picture then
					do_nothing
				when {FP_CONSTANTS}.field_type_varbinary then
					do_nothing
				when {FP_CONSTANTS}.field_type_varchar then
					do_nothing
				else
					check unknown_field_type: False end
				end
			end
			last_header := l_header
		ensure
			has_header: attached last_header
			has_field_specs: attached_last_header.field_subrecords.count = last_field_count
			at_least_one_field: last_field_count >= 1
		end

	read_file_for_all_data (a_file: RAW_FILE)
			-- Read `a_file', parsing out data based on `attached_last_header' and subrecord specifications in it.
		note
			synopsis: "[
				Calling this routine reads all data from the DBF, regardless of size.
				There is no paging or seeking of data.
				]"
			warning: "[
				NOT ALL data-types are implemented. See the code below for precisely
				which ones are not implemented and (possibly) why.
				]"
			todo: "[
				(1) Create routines that know how to read data in blocks or as independent records.
				]"
		require
			ready_for_data: a_file.position = (last_field_count * {FP_CONSTANTS}.subrecord_size + {FP_CONSTANTS}.header_block_size) + 1
		local
			l_record: attached like record_anchor
			l_string_field_content: STRING
			i,
			l_integer: INTEGER
			l_float: REAL_32
			l_field_data: detachable ANY
			l_date: DT_DATE
			l_date_number,
			l_time_number,
			l_total_seconds,
			l_hours,
			l_minutes,
			l_seconds: INTEGER_32
		do
			if not (a_file.position = position_of_first_data_record_8_9_value) then
				a_file.readstream (position_of_first_data_record_8_9_value - a_file.position)
			end
			across 1 |..| attached_last_header.record_count as ic_records loop
				a_file.read_stream (length_of_one_data_record_10_11_value)
				check at_deletion_mark: a_file.last_string [1].is_equal ({FP_CONSTANTS}.not_deleted_delete_mark) or a_file.last_string [1].is_equal ('T') end
				create l_record
				if a_file.last_string [1].is_equal ({FP_CONSTANTS}.not_deleted_delete_mark) then
					l_record.put (False, 1)
				else
					l_record.put (True, 1)
				end
				i := 2
				across attached_last_header.field_subrecords as ic_fields loop
					create l_string_field_content.make (ic_fields.item.field_length_in_bytes)
					l_string_field_content.append_string (a_file.last_string.substring (i, i + ic_fields.item.field_length_in_bytes - 1))
					inspect
						ic_fields.item.field_type
					when {FP_CONSTANTS}.field_type_character then
						l_field_data := l_string_field_content
					when {FP_CONSTANTS}.field_type_logical then
						if l_string_field_content.same_string ({FP_CONSTANTS}.true_mark.out) then
							l_field_data := True
						else
							l_field_data := False
						end
					when {FP_CONSTANTS}.field_type_numeric then
						l_field_data := parse_to_decimal (a_file.last_string, i, ic_fields.item)
					when {FP_CONSTANTS}.field_type_float then
						l_field_data := parse_to_decimal (a_file.last_string, i, ic_fields.item)
					when {FP_CONSTANTS}.field_type_currency then
						l_field_data := parse_to_decimal (a_file.last_string, i, ic_fields.item)
					when {FP_CONSTANTS}.field_type_date then
						l_field_data := create {DATE}.make (l_string_field_content.substring (1, 4).to_integer, l_string_field_content.substring (5, 6).to_integer, l_string_field_content.substring (7, 8).to_integer)
					when {FP_CONSTANTS}.field_type_datetime then
						check has_eight: l_string_field_content.count = 8 end
						l_date_number := stream_left_to_integer_32 (l_string_field_content)
						l_date_number := l_date_number - {FP_CONSTANTS}.Days_from_4713_to_1600
						create l_date.make (1600, 1, 1)
						l_date.add_days (l_date_number)
						l_time_number := stream_right_to_integer_32 (l_string_field_content)
						l_total_seconds := (l_time_number * 0.001).truncated_to_integer
						l_hours := (l_total_seconds / l_date.seconds_in_hour).truncated_to_integer
						l_minutes := ((l_total_seconds - (l_hours * l_date.seconds_in_hour)) / l_date.seconds_in_minute).truncated_to_integer
						l_seconds := l_total_seconds - (l_hours * l_date.seconds_in_hour) - (l_minutes * l_date.seconds_in_minute)
						l_field_data := create {DATE_TIME}.make (l_date.year, l_date.month, l_date.day, l_hours, l_minutes, l_seconds)
					when {FP_CONSTANTS}.field_type_integer then
						l_integer := stream_left_to_integer_32 (l_string_field_content)
						l_field_data := l_integer

						--| TODO: Implement INTEGER_32!!!
					when {FP_CONSTANTS}.field_type_double then
						check not_implemented: False end
						l_field_data := Void

						--| May never implement (only when we have a use-case)
					when {FP_CONSTANTS}.field_type_general then
						check not_implemented: False end
						l_field_data := Void
					when {FP_CONSTANTS}.field_type_blob then
						check not_implemented: False end
						l_field_data := Void
					when {FP_CONSTANTS}.field_type_memo then
						check not_implemented: False end
						l_field_data := Void
					when {FP_CONSTANTS}.field_type_picture then
						check not_implemented: False end
						l_field_data := Void
					when {FP_CONSTANTS}.field_type_varbinary then
						check not_implemented: False end
						l_field_data := Void
					when {FP_CONSTANTS}.field_type_varchar then
						check not_implemented: False end
						l_field_data := Void
					else
						check unknown_data_type: False end
					end
					l_record.put (l_field_data, ic_fields.cursor_index + 1)
					i := i + ic_fields.item.field_length_in_bytes
				end -- Across Fields
				last_data_content.force (l_record)
			end -- Across Records
		ensure
			correct_data_count: attached last_data_content as al_data and then al_data.count = number_of_records_4_7_value
		end

	parse_to_decimal (a_stream: STRING; i: INTEGER; a_spec: FP_FIELD_SUBRECORD [ANY]): DECIMAL
			-- Parse `a_stream' of data starting at the `i'th position for the length from `a_spec'.
		local
			l_string_field_content: STRING
		do
			create l_string_field_content.make (a_spec.field_length_in_bytes)
			l_string_field_content.append_string (a_stream.substring (i, i + a_spec.field_length_in_bytes - 1))
			l_string_field_content.left_adjust
			l_string_field_content.right_adjust
			create Result.make_from_string (l_string_field_content)
		end

	reversed_data_to_integer_32 (a_dbf_stream: STRING): INTEGER_32
			-- `a_dbf_stream' has reverse-ordered bytes (LSB->MSB) to reorder and return to {INTEGER_32}.
		require
			precisely_4: a_dbf_stream.count = 4
		do
			Result := a_dbf_stream [4].code
			Result := Result + a_dbf_stream [3].code * {FP_CONSTANTS}.msb7_multiplier_256
			Result := Result + a_dbf_stream [2].code * {FP_CONSTANTS}.msb6_multiplier_65_536
			Result := Result + a_dbf_stream [1].code * {FP_CONSTANTS}.msb5_multiplier_16_777_216
		end

	stream_left_to_integer_32 (a_dbf_stream: STRING): INTEGER_32
			-- Convert the left 4-bytes of `a_dbf_stream' to an {INTEGER_32}.
		do
			Result := stream_to_integer_32 (a_dbf_stream, 1)
		end

	stream_right_to_integer_32 (a_dbf_stream: STRING): INTEGER_32
			-- Convert the right 4-bytes of `a_dbf_stream' to an {INTEGER_32}.
		do
			Result := stream_to_integer_32 (a_dbf_stream, 5)
		end

	stream_to_integer_32 (a_dbf_stream: STRING; a_start: INTEGER): INTEGER_32
			-- `a_dbf_stream' has reverse-ordered bytes (LSB->MSB) to reorder and return to {INTEGER_32}.
		require
			one_or_five: (a_start = 1) or (a_start = 5)
			has_eight: (a_start = 5) implies a_dbf_stream.count = 8
		do
			Result := a_dbf_stream [a_start].code
			Result := Result + a_dbf_stream [a_start + 1].code * {FP_CONSTANTS}.msb7_multiplier_256
			Result := Result + a_dbf_stream [a_start + 2].code * {FP_CONSTANTS}.msb6_multiplier_65_536
			Result := Result + a_dbf_stream [a_start + 3].code * {FP_CONSTANTS}.msb5_multiplier_16_777_216
		end

	record_anchor: detachable TUPLE [detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, detachable ANY, ANY]
			-- Record TUPLE type anchor.

end
