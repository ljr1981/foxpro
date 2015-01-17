note
	description: "[
		FoxPro Header Specification
		]"
	specification: "[
		Byte offset		Description
		-----------		---------------------------------------
		#0				File type: 0x01
						FoxBASE: 0x02
						FoxBASE+/Dbase III plus, no memo: 0x2F
						Visual FoxPro: 0x30
						Visual FoxPro, autoincrement enabled: 0x31
						Visual FoxPro, Varchar, Varbinary, or Blob-enabled: 0x42
						dBASE IV SQL table files, no memo: 0x62
						dBASE IV SQL system files, no memo: 0x82
						FoxBASE+/dBASE III PLUS, with memo: 0x8A
						dBASE IV with memo: 0xCA
						dBASE IV SQL table files, with memo: 0xF4
						FoxPro 2.x (or earlier) with memo: 0xFA
						
		1 - 3			Last update (YYMMDD)
		
		4 – 7			Number of records in file
		
		8 – 9			Position of first data record
		
		10 – 11			Length of one data record, including delete flag
		
		12 – 27			Reserved

		28				Table flags: 
						0x01   file has a structural .cdx 
						0x02   file has a Memo field 
						0x04   file is a database (.dbc) This byte can contain the sum of 
								any of the above values. For example, the value 
						0x03 indicates the table has a structural .cdx and a Memo field.
		
		29				Code page mark
		
		30 – 31			Reserved, contains 0x00
		
		32 – n			Field subrecords The number of fields determines 
						the number of field subrecords. One field subrecord 
						exists for each field in the table.

		n+1				Header record terminator (0x0D)
		
		n+2 to n+264	A 263-byte range that contains the backlink, 
						which is the relative path of an associated 
						database (.dbc) file, information. If the first 
						byte is 0x00, the file is not associated with a 
						database. Therefore, database files always contain 
						0x00.
		]"
	EIS: "name=foxpro_header_specification", "protocol=URI", "tag=external",
			"src=http://msdn.microsoft.com/en-us/library/st4a0s68(VS.80).aspx"
	date: "$Date: 2015-01-16 08:59:42 -0500 (Fri, 16 Jan 2015) $"
	revision: "$Revision: 10596 $"
class
	FP_HEADER

inherit
	FP_SPEC
		rename
			specification_now as header_string_now,
			specification_on_date as header_string
		redefine
			default_create,
			out
		end

	FP_BYTE_HELPER
		redefine
			default_create,
			out
		end

feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		do
			create field_subrecords.make (0)
			first_data_record_start_byte := {FP_CONSTANTS}.starting_first_data_record_position
		end

feature -- Access

	out: STRING
			-- <Precursor>
			-- See `header_string_now'
		do
			Result := header_string_now
		end

	header_string_now: STRING
			-- Header as a STRING for {DATE}.make_now
		do
			Result := header_string (create {DATE}.make_now)
		end

	header_string (a_date: DATE): STRING
			-- <Precursor>
		note
			warning: "[
				DBF files have a 3-byte representation of when the file
				was last modified. It is interesting to note that the
				"year" portion of this date is not Y2K compliant (and
				never was). Thus, if one wants to say that the last time
				the file was modified was in 1999, both the Eiffel and
				VFP systems will see this as 2099 (if you're reading
				this and still in the 21st century).
				]"
		local
			l_bytes_32: like all_bytes_tuple_32
			l_bytes_16: like all_bytes_tuple_16
			l_year,
			l_month,
			l_day: INTEGER_32
		do
			l_year := a_date.year
			l_month := a_date.month
			l_day := a_date.day
			create Result.make_empty
				-- Byte 0 File Type
			Result.append_character (file_type)
				-- Bytes 1-3 Header YYMMDD
			if l_year > 100 then
				Result.append_code ((l_year - 2000).to_natural_32)
			else
				Result.append_code (l_year.to_natural_32)
			end
			Result.append_code (l_month.to_natural_32)
			Result.append_code (l_day.to_natural_32)
				-- Record count
			l_bytes_32 := all_bytes_tuple_32 (record_count)
			Result.append_code (l_bytes_32.lsb)
			Result.append_code (l_bytes_32.msb3)
			Result.append_code (l_bytes_32.msb2)
			Result.append_code (l_bytes_32.msb)
				-- Position first data record
			if file_type.is_equal ({FP_CONSTANTS}.file_type_vfp) then
				l_bytes_16 := all_bytes_tuple_16 (first_data_record_start_byte)
			else
				l_bytes_16 := all_bytes_tuple_16 (first_data_record_start_byte - 263)
			end
			Result.append_code (l_bytes_16.lsb)
			Result.append_code (l_bytes_16.msb)
				-- Record length. Add 1 for delete mark (when fields are defined)
			if data_record_length > 0 then
				l_bytes_16 := all_bytes_tuple_16 (data_record_length + 1)
			else
				l_bytes_16 := all_bytes_tuple_16 (data_record_length)
			end
			Result.append_code (l_bytes_16.lsb)
			Result.append_code (l_bytes_16.msb)
				-- Reserved 12-27
			Result.append_string (reserved_12_27)
				-- Table Flags
			Result.append_character (Table_flags)
				-- Code Page Mark
			Result.append_character (Code_page_mark)
				-- Reserved 30-31
			Result.append_string (reserved_30_31)
				-- Subrecords
			across field_subrecords as ic_subrecords loop
				Result.append_string (ic_subrecords.item.subrecord_string_now)
			end
				-- Header record terminator (Skynet Lives!)
			Result.append_character (Header_record_terminator)
				-- n+2 to n+264	A 263-byte range that contains the backlink ... (see note)
			if file_type.is_equal ({FP_CONSTANTS}.file_type_vfp) then
				across 1 |..| 263 as ic loop Result.append_character ('%/0x00/') end
			end
		end

feature -- Access: Header Fields

	file_type: CHARACTER
			-- File type character of Current.

	header_yymmdd: STRING
			-- File header YYMMDD
		do
			create Result.make_empty
		end

	record_count: INTEGER_32
			-- Bytes #4 – 7 Number of records in file

	first_data_record_start_byte: INTEGER_32
			-- Bytes #8 – 9 Position of first data record

	data_record_length: INTEGER_32
			-- Bytes #10 – 11 Length of one data record, including delete flag

	reserved_12_27: STRING
			-- Bytes #12 – 27 Reserved (per Microsoft VFP specification)
		once
			create Result.make_empty
			Result.append_character ('%/0x00/') -- 12
			Result.append_character ('%/0x00/') -- 13
			Result.append_character ('%/0x00/') -- 14
			Result.append_character ('%/0x00/') -- 15
			Result.append_character ('%/0x00/') -- 16
			Result.append_character ('%/0x00/') -- 17
			Result.append_character ('%/0x00/') -- 18
			Result.append_character ('%/0x00/') -- 19
			Result.append_character ('%/0x00/') -- 20
			Result.append_character ('%/0x00/') -- 21
			Result.append_character ('%/0x00/') -- 22
			Result.append_character ('%/0x00/') -- 23
			Result.append_character ('%/0x00/') -- 24
			Result.append_character ('%/0x00/') -- 25
			Result.append_character ('%/0x00/') -- 26
			Result.append_character ('%/0x00/') -- 27
		end

	table_flags: CHARACTER_8 = '%/0x00/'
			-- Byte #28 Table flags: 0x01   file has a structural .cdx
			--	0x02   file has a Memo field 0x04   file is a database
			--	(.dbc) This byte can contain the sum of any of the above
			--	values. For example, the value 0x03 indicates the table
			--	has a structural .cdx and a Memo field.

	code_page_mark: CHARACTER_8 = '%/0x00/' --'%/0x03/'
			-- Byte #29 Code Page Mark (default to 0h).
			--| Note that the default 0h Code Page is for
			--	sharing files between Fox 2.x and VFP.
			--	The older Fox 2.x specification does not
			--	support or require CP definition. However,
			--	VFP does require it due to early VFP being
			--	cross-platform compatible (e.g. Win, Linux, Mac).
			--	Therefore, if the file is opened in Fox 2.x
			--	it will open without issue. One can also
			--	change the structure and Fox 2.x will not
			--	make CP changes. However, in VFP, if one
			--	wants to open ("use") EXCLUSIVE, then VFP
			--	will see the default 0h CP and refuse to
			--	open the file until the CP is set or the
			--	open-request is Cancelled. In the current
			--	case of this constant, we opt for the 0h
			--	default, making generated DBF's compatible
			--	with both Fox 2.x and VFP. Note that 3h
			--	is Windows compatible CP.

	reserved_30_31: STRING
			-- Bytes #30 - 31 Reserved
		once
			create Result.make_empty
			Result.append_character ('%/0x00/') -- 30
			Result.append_character ('%/0x00/') -- 31
		end

	field_subrecords: ARRAYED_LIST [FP_FIELD_SUBRECORD [ANY]]
			-- Bytes #32 – n Field subrecords The number of fields

	header_record_terminator: CHARACTER_8 = '%/0x0D/'
			-- Byte #n+1 Header record terminator (0x0D)

feature -- Settings

	set_record_count (a_record_count: like record_count)
			-- Sets `record_count' with `a_record_count'.
		do
			record_count := a_record_count
		ensure
			record_count_set: record_count = a_record_count
		end

	set_first_data_record_start_byte (a_first_data_record_start_byte: like first_data_record_start_byte)
			-- Sets `first_data_record_start_byte' with `a_first_data_record_start_byte'.
		do
			first_data_record_start_byte := a_first_data_record_start_byte
		ensure
			first_data_record_start_byte_set: first_data_record_start_byte = a_first_data_record_start_byte
		end

	set_data_record_length (a_data_record_length: like data_record_length)
			-- Sets `data_record_length' with `a_data_record_length'.
		do
			data_record_length := a_data_record_length
		ensure
			data_record_length_set: data_record_length = a_data_record_length
		end

feature -- Settings: File Type

	set_file_type_vfp
			-- Set file type to VFP.
		do
			file_type := {FP_CONSTANTS}.file_type_vfp
		end

	set_file_type_foxpro_2x
			-- Set file type to foxpro 2x
		do
			file_type := {FP_CONSTANTS}.file_type_foxpro_2x
		end

	set_file_type_foxbase_plus_dbase_iii
			-- Set file type to Foxbase+/dBase III
		do
			file_type := {FP_CONSTANTS}.file_type_foxbase_plus_dbase_iii
		end

feature -- Basic Operations: Fields

	add_field_specification (a_name: STRING; a_field_type_code: CHARACTER_8; a_length, a_decimal_places: INTEGER)
			-- Add a new field of `a_field_code' type to `field_subrecords' list.
		require
			valid_name: a_name.count >= 1 and a_name.count <= 10
			valid_field_code: {FP_FIELD_SUBRECORD [ANY]}.field_types.has (a_field_type_code)
		local
			l_field: FP_FIELD_SUBRECORD [ANY]
			l_displacement: INTEGER_32
		do
			inspect
				a_field_type_code
			when 'C' then
				create {FP_FIELD_SUBRECORD [STRING]} l_field
			when 'Y' then
				create {FP_FIELD_SUBRECORD [DECIMAL]} l_field
			when 'B' then
				create {FP_FIELD_SUBRECORD [DOUBLE]} l_field
			when 'D' then
				create {FP_FIELD_SUBRECORD [DATE]} l_field
			when 'T' then
				create {FP_FIELD_SUBRECORD [DATE_TIME]} l_field
			when 'F' then
				create {FP_FIELD_SUBRECORD [REAL]} l_field
			when 'I' then
				create {FP_FIELD_SUBRECORD [INTEGER]} l_field
			when 'L' then
				create {FP_FIELD_SUBRECORD [BOOLEAN]} l_field
			when 'N' then
				create {FP_FIELD_SUBRECORD [NUMERIC]} l_field
			else
				create {FP_FIELD_SUBRECORD [ANY]} l_field
				check unknown_field_type: False end
			end
			l_field.set_field_name (a_name)
			l_field.set_field_type (a_field_type_code)
			l_field.set_field_length_in_bytes (a_length)
			l_field.set_number_of_decimal_places (a_decimal_places)
				-- Start displacement at 1, increasing by previously calculated
				--	displacements, and adding length only on the last one, which
				--	is the last known field plus the length of the field being
				--	added.
			set_data_record_length (data_record_length + a_length) -- + 1)
			l_displacement := 1
			across field_subrecords as ic_subrecords loop
				l_displacement := l_displacement + ic_subrecords.item.displacement
				if ic_subrecords.is_last then
					l_displacement := l_displacement + a_length
				end
			end
			l_field.set_displacement (l_displacement)
			field_subrecords.force (l_field)
			first_data_record_start_byte := first_data_record_start_byte + {FP_CONSTANTS}.subrecord_size
		ensure
			field_added: old field_subrecords.count = field_subrecords.count - 1
			same_name: attached field_subrecords [field_subrecords.count] as al_field implies al_field.field_name.same_string (a_name)
			same_type: attached field_subrecords [field_subrecords.count] as al_field implies al_field.field_type ~ a_field_type_code
			same_length: attached field_subrecords [field_subrecords.count] as al_field implies al_field.field_length_in_bytes = a_length
			same_decimal: attached field_subrecords [field_subrecords.count] as al_field implies al_field.number_of_decimal_places = a_decimal_places
		end

feature -- Fields: Name and length-based

	add_character_field (a_name: STRING; a_length: INTEGER_32)
			-- Add a 'C' character field.
		do
			add_field_specification (a_name, {FP_FIELD_SUBRECORD [STRING]}.field_types [{FP_FIELD_SUBRECORD [STRING]}.field_type_character], a_length, 0)
		end

	add_character_binary_field (a_name: STRING; a_length: INTEGER_32)
			-- Add a 'C' character field.
		do
			add_field_specification (a_name, {FP_FIELD_SUBRECORD [STRING]}.field_types [{FP_FIELD_SUBRECORD [STRING]}.field_type_character], a_length, 0)
		end

feature -- Fields: Name, length, and decimal-size-based

	add_double_field (a_name: STRING; a_length, a_decimals: INTEGER_32)
			-- Add a 'B' double field.
		do
			add_field_specification (a_name, {FP_FIELD_SUBRECORD [ANY]}.field_types [{FP_FIELD_SUBRECORD [ANY]}.field_type_double], a_length, a_decimals)
		end

	add_float_field (a_name: STRING; a_length, a_decimals: INTEGER_32)
			-- Add a 'F' float field.
		do
			add_field_specification (a_name, {FP_FIELD_SUBRECORD [ANY]}.field_types [{FP_FIELD_SUBRECORD [ANY]}.field_type_float], a_length, a_decimals)
		end

	add_numeric_field (a_name: STRING; a_length, a_decimals: INTEGER_32)
			-- Add a 'N' numeruc field.
		do
			add_field_specification (a_name, {FP_FIELD_SUBRECORD [ANY]}.field_types [{FP_FIELD_SUBRECORD [ANY]}.field_type_numeric], a_length, a_decimals)
		end

feature -- Fields: Name-only

	add_currency_field (a_name: STRING)
			-- Add a 'Y' currency field.
		do
			add_field_specification (a_name, {FP_FIELD_SUBRECORD [ANY]}.field_types [{FP_FIELD_SUBRECORD [ANY]}.field_type_currency], 8, 0)
		end

	add_date_field (a_name: STRING)
			-- Add a 'D' date field.
		do
			add_field_specification (a_name, {FP_FIELD_SUBRECORD [ANY]}.field_types [{FP_FIELD_SUBRECORD [ANY]}.field_type_date], 8, 0)
		end

	add_datetime_field (a_name: STRING)
			-- Add a 'D' datetime field.
		do
			add_field_specification (a_name, {FP_FIELD_SUBRECORD [ANY]}.field_types [{FP_FIELD_SUBRECORD [ANY]}.field_type_datetime], 8, 0)
		end

	add_integer_field (a_name: STRING)
			-- Add a 'I' integer field.
		do
			add_field_specification (a_name, {FP_FIELD_SUBRECORD [ANY]}.field_types [{FP_FIELD_SUBRECORD [ANY]}.field_type_integer], 4, 0)
		end

	add_logical_field (a_name: STRING)
			-- Add a 'L' logical field.
		do
			add_field_specification (a_name, {FP_FIELD_SUBRECORD [ANY]}.field_types [{FP_FIELD_SUBRECORD [ANY]}.field_type_logical], 1, 0)
		end

end
