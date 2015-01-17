note
	description: "[
		FoxPro DBF Writer
		]"
	synopsis: "[
		Given a collection of Eiffel data that one wants to place in an external
		DBF, use Current to construct the DBF header, subrecord (field)
		specifications, and then write those, plus any data content to the
		external DBF.
		
		Steps:
		======
		(1) Create an instance of this class as an object.
		(2) Set the header specifications.
		(3) Set the field specifications.
		(4) Add data TUPLEs (records) using `add_row'
		
		See EIS link below for more information.
		]"
	EIS: "name=readme", "protocol=PDF", "tag=readme",
			"src=$JINNY_TRUNK\jinny_foxpro\readme.pdf"
	EIS: "name=video", "protocol=URI", "tag=video",
			"src=https://www.youtube.com/watch?v=vHD2_O808YE&feature=youtu.be&hd=1"

	date: "$Date: 2015-01-16 10:27:47 -0500 (Fri, 16 Jan 2015) $"
	revision: "$Revision: 10604 $"

class
	FP_DBF_WRITER

inherit
	ANY
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		do
			create header
			create data.make (0)
			create name.make_from_string ({FP_CONSTANTS}.default_file_name)
		end

feature -- Access

	dbf_name: STRING
			-- DBF file `name' of Current.
		do
			Result := name
			if not name.has ('.') then
				Result.append_string ({FP_CONSTANTS}.dbf_file_extension)
			end
		end

	name: STRING
			-- Name of Current.

	header: FP_HEADER
			-- Table header specification of Current.

feature -- Settings

	set_name (a_name: like name)
			-- Sets `name' with `a_name'.
		do
			name := a_name
		ensure
			name_set: name = a_name
		end

feature -- Basic Operations

	add_row (a_row: like row_specification_tuple)
			-- Add `a_row' to `data'.
		do
			data.force (a_row)
		end

	generate_dbf
			-- Generate a DBF file from `header' and `data'.
		note
			todo: "[
				(1) Right now, this routine is designed for a single
					STRING (character) field and works perfectly.
					However, it will not handle more (yet). That is
					the next task to handle.
				]"
		local
			l_file: RAW_FILE
		do
				-- Prepare the header with `data' metadata
			header.set_record_count (data.count)

				-- Create and prepare the DBF file
			create l_file.make_create_read_write (dbf_name)
			l_file.put_string (header.out)

				-- Add data to file
			if data.count > 0 then
				across data as ic_data loop -- Each data record
					across header.field_subrecords as ic_fields loop -- Each record field
							-- Always insert the delete mark as first character of each record.
							-- Space (i.e. '%/0x20/') is "not-deleted".
						if ic_fields.cursor_index = 1 then
							l_file.put_character ({FP_CONSTANTS}.not_deleted_delete_mark)
						end
							-- Now, process field for content
						if ic_fields.item.field_type = {FP_CONSTANTS}.field_type_character and attached {STRING} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (string_data (al_item, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_currency and attached {DECIMAL} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (decimal_data (al_item, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_float and attached {DECIMAL} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (float_data_decimal (al_item, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_numeric and attached {DECIMAL} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (float_data_decimal (al_item, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_integer and attached {INTEGER_32} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (integer_data (al_item, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_logical and attached {BOOLEAN} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (boolean_data (al_item, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_date and attached {DATE} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (date_data (al_item, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_datetime and attached {DATE_TIME} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (datetime_data (al_item, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_float and attached {REAL_32} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (float_data (al_item, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_float and attached {REAL_64} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (float_data (al_item.truncated_to_real, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_numeric and attached {REAL_32} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (float_data (al_item, ic_fields.item))
						elseif ic_fields.item.field_type = {FP_CONSTANTS}.field_type_numeric and attached {REAL_64} ic_data.item.at (ic_fields.cursor_index) as al_item then
							l_file.put_string (float_data (al_item.truncated_to_real, ic_fields.item))
						end
					end
				end
				if not header.file_type.is_equal ({FP_CONSTANTS}.file_type_foxbase_plus_dbase_iii) then
					l_file.put_character ({FP_CONSTANTS}.end_of_file_marker)
				end
			end

				-- Complete the DBF file
			l_file.close
		end

	numeric_data (a_numeric: REAL_32; a_spec: FP_FIELD_SUBRECORD [ANY]): STRING
			-- Takes `a_float' with `a_spec' and gives back a DBF formatted float (real) field entry.
		do
			Result := float_data (a_numeric, a_spec)
		end

	float_data_decimal (a_decimal: DECIMAL; a_spec: FP_FIELD_SUBRECORD [ANY]): STRING
		do
			Result := float_data (a_decimal.out.to_real, a_spec)
		end

	float_data (a_float: REAL_32; a_spec: FP_FIELD_SUBRECORD [ANY]): STRING
			-- Takes `a_float' with `a_spec' and gives back a DBF formatted float (real) field entry.
		note
			synopsis: "[
				Given 65.04 as N15,5 --> "20-20-20-20-20-20-20-36-35-2E-30-34-30-30-30"
					which is:			 " _  _  _  _  _  _  _  6  5  .  0  4  0  0  0"
				]"
		local
			l_out: STRING
			l_dec_count: INTEGER
			l_dec_flag: BOOLEAN
		do
			create Result.make (a_spec.field_length_in_bytes)
			l_out := a_float.out
			if not l_out.has ({FP_CONSTANTS}.decimal_point) and a_spec.number_of_decimal_places > 0 then
				l_out.append_character ({FP_CONSTANTS}.decimal_point)
				l_out.append_character ('0')
			end
			across l_out as ic_digits loop
				Result.append_character (ic_digits.item)
				check decimal_implies_not_flagged: ic_digits.item.is_equal ({FP_CONSTANTS}.decimal_point) implies not l_dec_flag end
				if l_dec_flag then l_dec_count := l_dec_count + 1 end
				if ic_digits.item.is_equal ({FP_CONSTANTS}.decimal_point) then l_dec_flag := True end
			end
			check flag_implies_has_count: l_dec_flag implies l_dec_count > 0 end
			from until l_dec_count = a_spec.number_of_decimal_places loop
				l_dec_count := l_dec_count + 1
				Result.append_character ('0')
			end
			check count_equals_decimal: l_dec_count = a_spec.number_of_decimal_places end
			if l_out.count < a_spec.field_length_in_bytes then
				from until Result.count = a_spec.field_length_in_bytes loop
					Result.prepend_character ({FP_CONSTANTS}.space)
				end
			end
		ensure
			correct_length: Result.count = a_spec.field_length_in_bytes
			correct_decimal_location: Result.has ({FP_CONSTANTS}.decimal_point) implies
								Result.at (Result.count - a_spec.number_of_decimal_places).is_equal ({FP_CONSTANTS}.decimal_point)
			correct_content: across Result as ic_content all
									({FP_CONSTANTS}.valid_float_content).has (ic_content.item)
								end
		end

	date_data (a_date: DATE; a_spec: FP_FIELD_SUBRECORD [ANY]): STRING
			-- Takes `a_date' with `a_spec' and gives back a DBF formatted date field entry.
		note
			synopsis: "[
				VFP/Fox 2x dates are stored on disk as CCYYMMDD as
				characters representing the digits.
				]"
		local
			l_out: STRING
		do
			create Result.make (8)
				-- Year
			l_out := a_date.year.out
			Result.append_character (l_out [1])
			Result.append_character (l_out [2])
			Result.append_character (l_out [3])
			Result.append_character (l_out [4])
				-- Month
			l_out := a_date.month.out
			if a_date.month < 10 then
				l_out.prepend_character ('0')
			end
			Result.append_character (l_out [1])
			Result.append_character (l_out [2])
				-- Day
			l_out := a_date.day.out
			if a_date.day < 10 then
				l_out.prepend_character ('0')
			end
			Result.append_character (l_out [1])
			Result.append_character (l_out [2])
		ensure
			correct_result: a_date.is_equal (create {DATE}.make (Result.substring (1, 4).to_integer, Result.substring (5, 6).to_integer, Result.substring (7, 8).to_integer))
		end

	datetime_data (a_datetime: DATE_TIME; a_spec: FP_FIELD_SUBRECORD [ANY]): STRING
		local
			l_days_since_4713,
			l_seconds: INTEGER_64
			l_date: DATE
			l_4713: DATE
			l_interval: INTERVAL [DATE]
			l_duration: DATE_DURATION
			l_tuple: TUPLE [msb, msb2, msb3, msb4, msb5, msb6, msb7, lsb: NATURAL_8]
		do
			create l_interval.make (origin_1600, a_datetime.date)
			if attached {DATE_DURATION} l_interval.duration as al_duration then
				al_duration.set_origin_date (origin_1600)
				l_days_since_4713 := al_duration.days_count + {FP_CONSTANTS}.days_from_4713_to_1600 + {FP_CONSTANTS}.Anno_domini_proleptic_difference
			end
			if a_datetime.year <= 0 then
				l_days_since_4713 := l_days_since_4713 - {FP_CONSTANTS}.Before_christ_proleptic_difference
			else
				l_days_since_4713 := l_days_since_4713 - {FP_CONSTANTS}.Anno_domini_proleptic_difference
			end

			create Result.make (8)

			l_tuple := header.all_bytes_tuple_64 (l_days_since_4713)

			Result.append_character (l_tuple.lsb.to_character_8)
			Result.append_character (l_tuple.msb7.to_character_8)
			Result.append_character (l_tuple.msb6.to_character_8)
			Result.append_character (l_tuple.msb5.to_character_8)

			l_seconds := (a_datetime.hour * a_datetime.seconds_in_hour) + (a_datetime.minute * a_datetime.seconds_in_minute) + a_datetime.second
			l_seconds := l_seconds * 1_000

			l_tuple := header.all_bytes_tuple_64 (l_seconds)

			Result.append_character (l_tuple.lsb.to_character_8)
			Result.append_character (l_tuple.msb7.to_character_8)
			Result.append_character (l_tuple.msb6.to_character_8)
			Result.append_character (l_tuple.msb5.to_character_8)
		end

	origin_1600: DATE
			-- Origin date
		once
			create Result.make (1600, 1, 1)
		end

	boolean_data (a_flag: BOOLEAN; a_spec: FP_FIELD_SUBRECORD [ANY]): STRING
			-- Takes `a_integer' with `a_spec' and gives back a DBF formatted integer_32 field entry.
		do
			create Result.make (1)
			if a_flag then
				Result.append_character ({FP_CONSTANTS}.true_mark)
			else
				Result.append_character ({FP_CONSTANTS}.space)
			end
		end

	integer_data (a_integer: INTEGER_64; a_spec: FP_FIELD_SUBRECORD [ANY]): STRING
			-- Takes `a_integer' with `a_spec' and gives back a DBF formatted integer_32 field entry.
		local
			l_tuple: TUPLE [msb, msb2, msb3, msb4, msb5, msb6, msb7, lsb: NATURAL_8]
		do
			l_tuple := header.all_bytes_tuple_64 (a_integer)
			create Result.make (4)
			Result.append_character (l_tuple.lsb.to_character_8)
			Result.append_character (l_tuple.msb7.to_character_8)
			Result.append_character (l_tuple.msb6.to_character_8)
			Result.append_character (l_tuple.msb5.to_character_8)
		end

	decimal_data (a_decimal: DECIMAL; a_spec: FP_FIELD_SUBRECORD [ANY]): STRING
			-- Takes `a_decimal' with `a_spec' and gives back a DBF formatted currency field entry.
		local
			l_list: LIST [STRING]
			l_tuple: TUPLE [msb, msb2, msb3, msb4, msb5, msb6, msb7, lsb: NATURAL_8]
		do
			l_list := a_decimal.out_tuple.split (',') -- [0,9991110,-4]
			check has_3: l_list.count = 3 end
			l_tuple := header.all_bytes_tuple_64 (l_list [2].to_integer_64)
			create Result.make (0)
			Result.append_character (l_tuple.lsb.to_character_8)
			Result.append_character (l_tuple.msb7.to_character_8)
			Result.append_character (l_tuple.msb6.to_character_8)
			Result.append_character (l_tuple.msb5.to_character_8)
			Result.append_character (l_tuple.msb4.to_character_8)
			Result.append_character (l_tuple.msb3.to_character_8)
			Result.append_character (l_tuple.msb2.to_character_8)
			Result.append_character (l_tuple.msb.to_character_8)
		end

	string_data (a_string: STRING; a_spec: FP_FIELD_SUBRECORD [ANY]): STRING
			-- Takes an Eiffel {STRING} and gives back a DBF formatted character field entry.
		note
			synopsis: "[
				FoxPro DBF "character" (e.g. {STRING}) fields either:
				(1) Right-pad with spaces if `a_string' < `a_length'.
				(2) Truncate to `a_length' when `a_string'.count > `a_length'.
				]"
		require
			some_length: a_spec.field_length_in_bytes > 0
		do
			create Result.make (a_spec.field_length_in_bytes)
			if a_string.count = a_spec.field_length_in_bytes then
				Result.append_string (a_string)
			elseif a_string.count > a_spec.field_length_in_bytes then
				Result.append_string (a_string.substring (1, a_spec.field_length_in_bytes))
			elseif a_string.count < a_spec.field_length_in_bytes then
				Result.append_string (a_string)
				from
				until Result.count = a_spec.field_length_in_bytes
				loop Result.append_character ({FP_CONSTANTS}.space)
				end
			end
		ensure
			correct_length: Result.count = a_spec.field_length_in_bytes
		end

feature -- Constants

feature {NONE} -- Implementation

	row_specification_tuple: TUPLE [ANY]
			-- Calculated field-type specification as TUPLE
		do
			create Result
			across header.field_subrecords as ic_subspecs loop
				inspect
					ic_subspecs.item.field_type
				when 'C' then
					Result.put (create {STRING_32}.make_empty, Result.count + 1)
				else
					check unknown_type: False end
				end
			end
		end

	data: ARRAYED_LIST [like row_specification_tuple]
			-- List of data records contained in Current as specified in `row_specification_tuple' from `header'.

end
