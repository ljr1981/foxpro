note
	description: "[
		FoxPro DBF Header-Subrecord Field Specification
		]"
	specification: "[
		Header Specification
		====================
		32 – n: Field subrecords The number of fields determines the 
		number of field subrecords. One field subrecord exists for each 
		field in the table.

		Subrecord Specification
		=======================

		Byte offset		Description
		-----------		------------
		0 – 10			Field name with a maximum of 10 characters. If less than 
						10, it is padded with null characters (0x00).
						
		11				Field type:
						W   -   Blob
						C   –   Character
						C   –   Character (binary)
						Y   –   Currency
						B   –   Double
						D   –   Date
						T   –   DateTime
						F   –   Float
						G   –   General
						I   –   Integer
						L   –   Logical
						M   –   Memo
						M   –   Memo (binary)
						N   –   Numeric
						P   –   Picture
						Q   -   Varbinary
						V   -   Varchar
						V   -   Varchar (binary)
					Note
					For each Varchar and Varbinary field, one bit, or 
						"varlength" bit, is allocated in the last system 
						field, which is a hidden field and stores the null 
						status for all fields that can be null. If the 
						Varchar or Varbinary field can be null, the null 
						bit follows the "varlength" bit. If the "varlength" 
						bit is set to 1, the length of the actual field 
						value length is stored in the last byte of the 
						field. Otherwise, if the bit is set to 0, length 
						of the value is equal to the field size.
						
		12 – 15		Displacement of field in record
		
		16			Length of field (in bytes)
		
		17			Number of decimal places
		
		18			Field flags: 
					0x01   System Column (not visible to user) 
					0x02   Column can store null values 
					0x04   Binary column (for CHAR and MEMO only) 
					0x06   (0x02+0x04) When a field is NULL and binary (Integer, Currency, and Character/Memo fields) 
					0x0C   Column is autoincrementing.
		
		19 - 22		Value of autoincrement Next value (LSB-MSB)
		
		23			Value of autoincrement Step value
		
		24 – 31		Reserved
		
		For information about limitations on characters per record, 
		maximum fields, and so on, see Visual FoxPro System Capacities.
		]"
	EIS: "name=table_file_structure", "protocol=URI", "tag=external",
			"src=http://msdn.microsoft.com/en-us/library/st4a0s68(VS.80).aspx"
	date: "$Date: 2015-01-16 08:59:42 -0500 (Fri, 16 Jan 2015) $"
	revision: "$Revision: 10596 $"

class
	FP_FIELD_SUBRECORD [G -> ANY]

inherit
	FP_SPEC
		rename
			specification_now as subrecord_string_now,
			specification_on_date as subrecord_string
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
			field_type := field_types [integer_specification]
		end

feature -- Access

	out: STRING
			-- <Precursor>
			-- See `header_string'
		do
			Result := subrecord_string_now
		end

	subrecord_string (a_date: DATE): STRING
			-- <Precursor>
		note
			warning: "[
				For Field Subrecord's, there is no date-sensitive
				parts. Moreover, the `subrecord_string_now' also
				has no date-sensitive parts. Thus, the naming
				is merely a convenience based on the ancestor
				notions.
				]"
			todo: "[
				(1) Consider rename of `subrecord_string_now' and
				`subrecord_string' to remove notions of any date
				sensitivity. However, this might be difficult due
				to the arguments on `subrecord_string'.
				]"
		do
			Result := subrecord_string_now
		end

	subrecord_string_now: STRING
			-- Current as a string
		note
			todo: "[
				(1) Take special note of the "from-loop". This loop
					is here to satisfy the ensure-contract, which
					wants to hold the {STRING} Result to precisely
					32-characters (count). It may well be that this
					NULL value post-pending will have more data
					contained given future work to be done with this
					library, whereby the need for the loop might be
					handled another way or the count of NULLs added
					might be reduced.
				]"
		local
			l_bytes_32: like all_bytes_tuple_32
			i: INTEGER
		do
			create Result.make_empty
				-- Field name
			Result.append_string (calculated_field_name)
				-- Field type
			Result.append_character (field_type)
				-- Displacement
			l_bytes_32 := all_bytes_tuple_32 (displacement)
			Result.append_code (l_bytes_32.lsb)
			Result.append_code (l_bytes_32.msb3)
			Result.append_code (l_bytes_32.msb2)
			Result.append_code (l_bytes_32.msb)
				-- Length of field
			Result.append_code (lsb_32 (field_length_in_bytes))
				-- Decimal places
			Result.append_code (lsb_32 (number_of_decimal_places))
				-- Field flags
			Result.append_code (lsb_32 (field_flags))

				-- See "todo" note in feature notes.
			from until Result.count = 32 loop Result.append_character ('%/0x00/') end
		ensure then
			thirty_two_characters: Result.count = 32
		end

feature -- Access: Subrecord Fields

	field_name: STRING
			-- Bytes #0 – 10	Field name with a maximum of 10 characters.
		note
			warning: "[
				Presently, this feature has a compiler warning complaint
				that the feature is never called and the attribute keyword
				is not needed. However, it is needed if one wants to have
				an ensure or a note.
				]"
		attribute
			create Result.make_empty
		ensure
			Result.count <= max_field_name_size
		end

	calculated_field_name: like field_name
			-- Calculated version of `field_name', held to specifications.
		note
			specification: "[
				Bytes #0 – 10	Field name with a maximum of `max_field_name_size' characters.
				If less than 10, it is padded with null characters (0x00).
				]"
		do
			Result := field_name
			from
			until field_name.count >= max_field_name_size
			loop
				Result.append_character ('%U') -- NULL
			end
		end

	field_type: CHARACTER_8
			-- FoxPro data-type of field.
			-- Defaulting to "I" for integer.
		note
			specification: "[
				11		Field type:
							W   -   Blob
							C   –   Character
							C   –   Character (binary)
							Y   –   Currency
							B   –   Double
							D   –   Date
							T   –   DateTime
							F   –   Float
							G   –   General
							I   –   Integer
							L   –   Logical
							M   –   Memo
							M   –   Memo (binary)
							N   –   Numeric
							P   –   Picture
							Q   -   Varbinary
							V   -   Varchar
							V   -   Varchar (binary)
						Note
						For each Varchar and Varbinary field, one bit, or 
							"varlength" bit, is allocated in the last system 
							field, which is a hidden field and stores the null 
							status for all fields that can be null. 
								If 
									the Varchar or Varbinary field can be null, 
									then
										the null bit follows the "varlength" bit. 
								elseIf 
									the "varlength" bit is set to 1, 
									then
										the length of the actual field value length is stored 
										in the last byte of the field. 
								else
									Otherwise, if the bit is set to 0, length of the 
									value is equal to the field size.
								end
				]"
			warning: "[
				Presently, this feature has a compiler warning complaint
				that the feature is never called and the attribute keyword
				is not needed. However, it is needed if one wants to have
				an ensure or a note.
				]"
		attribute
			Result := field_types [integer_specification]
		end

	displacement: INTEGER_32
			-- Bytes #12 – 15 Displacement of field in record.

	field_length_in_bytes: INTEGER_32
			-- Byte #16 Length of field in bytes.

	number_of_decimal_places: INTEGER_32
			-- Byte #17 Number of decimal places.

	field_flags: INTEGER_32
			-- Byte #18 Field flags.
		note
			synopsis: "[
				18		Field flags: 
							0x01   System Column (not visible to user) 
							0x02   Column can store null values 
							0x04   Binary column (for CHAR and MEMO only) 
							0x06   (0x02+0x04) When a field is NULL and binary (Integer, Currency, and Character/Memo fields) 
							0x0C   Column is autoincrementing.
				]"
			warning: "[
				Presently, this feature has a compiler warning complaint
				that the feature is never called and the attribute keyword
				is not needed. However, it is needed if one wants to have
				an ensure or a note.
				]"
		attribute
			Result := 0
		end

feature -- Settings: Field Flags

	set_system_column
			-- Set system column onto `field_flags'.
			-- 0x01   System Column (not visible to user)
		do
			field_flags := field_flags.set_bit (set, sytem_column_bit)
		end

	reset_system_column
			-- reset system column onto `field_flags'.
			-- 0x01   System Column (not visible to user)
		do
			field_flags := field_flags.set_bit (reset, sytem_column_bit)
		end

	set_nullable
			-- Set nullable onto `field_flags'.
			-- 0x02   Column can store null values
		do
			field_flags := field_flags.set_bit (set, nullable_bit)
		end

	reset_nullable
			-- reset nullable onto `field_flags'.
			-- 0x02   Column can store null values
		do
			field_flags := field_flags.set_bit (reset, nullable_bit)
		end

	set_binary
			-- Set binary onto `field_flags'.
			-- 0x04   Binary column (for CHAR and MEMO only)
		do
			field_flags := field_flags.set_bit (set, binary_bit)
		end

	reset_binary
			-- reset binary onto `field_flags'.
			-- 0x04   Binary column (for CHAR and MEMO only)
		do
			field_flags := field_flags.set_bit (reset, binary_bit)
		end

feature -- Settings

	set_field_name (a_field_name: like field_name)
			-- Sets `field_name' with `a_field_name'.
		require
			ten_or_less: a_field_name.count <= max_field_name_size
		do
			field_name := a_field_name
		ensure
			field_name_set: field_name = a_field_name
			ten_or_less: field_name.count <= max_field_name_size
		end

	set_field_type (a_field_type: like field_type)
			-- Sets `field_type' with `a_field_type'.
		do
			field_type := a_field_type
		ensure
			field_type_set: field_type = a_field_type
		end

	set_displacement (a_displacement: like displacement)
			-- Sets `displacement' with `a_displacement'.
		do
			displacement := a_displacement
		ensure
			displacement_set: displacement = a_displacement
		end

	set_field_length_in_bytes (a_field_length_in_bytes: like field_length_in_bytes)
			-- Sets `field_length_in_bytes' with `a_field_length_in_bytes'.
		do
			field_length_in_bytes := a_field_length_in_bytes
		ensure
			field_length_in_bytes_set: field_length_in_bytes = a_field_length_in_bytes
		end

	set_number_of_decimal_places (a_number_of_decimal_places: like number_of_decimal_places)
			-- Sets `number_of_decimal_places' with `a_number_of_decimal_places'.
		do
			number_of_decimal_places := a_number_of_decimal_places
		ensure
			number_of_decimal_places_set: number_of_decimal_places = a_number_of_decimal_places
		end

feature -- Status Report

	eiffel_field_type: detachable G
			-- Field data type per Eiffel.

feature -- Constants

	max_field_name_size: INTEGER = 11

	field_types: STRING = "WCCYBDTFGILMMNPQVV"
			--1		W   -   Blob
			--2		C   –   Character
			--3		C   –   Character (binary)
			--4		Y   –   Currency
			--5		B   –   Double
			--6		D   –   Date
			--7		T   –   DateTime
			--8		F   –   Float
			--9		G   –   General
			--10	I   –   Integer
			--11	L   –   Logical
			--12	M   –   Memo
			--13	M   –   Memo (binary)
			--14	N   –   Numeric
			--15	P   –   Picture
			--16	Q   -   Varbinary
			--17	V   -   Varchar
			--18	V   -   Varchar (binary)

	field_type_blob: INTEGER = 1
	field_type_character: INTEGER = 2
	field_type_character_binary: INTEGER = 3
	field_type_currency: INTEGER = 4
	field_type_double: INTEGER = 5
	field_type_date: INTEGER = 6
	field_type_datetime: INTEGER = 7
	field_type_float: INTEGER = 8
	field_type_general: INTEGER = 9
	field_type_integer: INTEGER = 10
	field_type_logical: INTEGER = 11
	field_type_memo: INTEGER = 12
	field_type_memo_binary: INTEGER = 13
	field_type_numeric: INTEGER = 14
	field_type_picture: INTEGER = 15
	field_type_varbinary: INTEGER = 16
	field_type_varchar: INTEGER = 17
	field_type_varchar_binary: INTEGER = 18

	integer_specification: INTEGER = 10
			-- Refers to which `field_types' item is used to represent an Integer field type (e.g. #10)

	sytem_column_bit: INTEGER = 1
			-- The bit in `field_flags' to set/reset for system columns.

	nullable_bit: INTEGER = 2
			-- The bit in `field_flags' to set/reset for nullable columns.

	binary_bit: INTEGER = 3
			-- The bit in `field_flags' to set/reset for binary columns.

	set: BOOLEAN = True
			-- What `set' means to features need to `set'.

	reset: BOOLEAN = False
			-- What `reset' means to features need to `reset'.

invariant
	valid_type: attached field_types as al_field_types implies al_field_types.has (field_type)
	valid_int_specification: field_types [integer_specification] = 'I'

end
