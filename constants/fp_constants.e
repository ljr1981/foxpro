note
	description: "[
		Constants are needed by a FoxPro DBF Header (e.g. {FOXPRO_HEADER}).
		]"
	synopsis: "[
		Reading from and writing to DBF files involves a number of constants.
		Some of these are shared and this class represents these constants.
		The feature groups represent the major areas of constants (e.g. File Types).
		]"
	EIS: "name=table_file_structure", "protocol=URI", "tag=external",
			"src=http://msdn.microsoft.com/en-us/library/st4a0s68(VS.80).aspx"

	date: "$Date: 2015-01-15 16:49:21 -0500 (Thu, 15 Jan 2015) $"
	revision: "$Revision: 10591 $"

class
	FP_CONSTANTS

feature -- Constants: File Types

	file_type_foxbase: CHARACTER 						= '%/0x02/'   -- FoxBASE								 n/a
	file_type_foxbase_plus_dbase_iii: CHARACTER 		= '%/0x03/'   -- FoxBASE+/Dbase III plus, 				W/O memo
	file_type_vfp: CHARACTER 							= '%/0x30/'   -- Visual FoxPro							 n/a
	file_type_vfp_auto_incr: CHARACTER 					= '%/0x31/'   -- Visual FoxPro, autoincrement enabled	 n/a
	file_type_dbase_iv_table: CHARACTER 				= '%/0x43/'   -- dBASE IV SQL table files, 				W/O memo
	file_type_dbase_iv_system: CHARACTER 				= '%/0x63/'   -- dBASE IV SQL system files,				W/O memo
	file_type_foxbase_plus_dbase_iii_plus: CHARACTER 	= '%/0x83/'   -- FoxBASE+/dBASE III PLUS, 				WITH memo
	file_type_dbase_iv_memo: CHARACTER 					= '%/0x8B/'   -- dBASE IV with memo						 n/a
	file_type_dbase_iv_table_memo: CHARACTER 			= '%/0xCB/'   -- dBASE IV SQL table files,		 		WITH memo
	file_type_foxpro_2x: CHARACTER 						= '%/0xF5/'   -- FoxPro 2.x (or earlier) 				WITH memo
	file_type_foxbase_2: CHARACTER 						= '%/0xFB/'   -- FoxBASE								 n/a

feature -- Field Types

	field_type_Blob: CHARACTER = 'W'
	field_type_Character: CHARACTER = 'C'
	field_type_Characterbinary: CHARACTER = 'C'
	field_type_Currency: CHARACTER = 'Y'
	field_type_Double: CHARACTER = 'B'
	field_type_Date: CHARACTER = 'D'
	field_type_DateTime: CHARACTER = 'T'
	field_type_Float: CHARACTER = 'F'
	field_type_General: CHARACTER = 'G'
	field_type_Integer: CHARACTER = 'I'
	field_type_Logical: CHARACTER = 'L'
	field_type_Memo: CHARACTER = 'M'
	field_type_Memobinary: CHARACTER = 'M'
	field_type_Numeric: CHARACTER = 'N'
	field_type_Picture: CHARACTER = 'P'
	field_type_Varbinary: CHARACTER = 'Q'
	field_type_Varchar: CHARACTER = 'V'
	field_type_Varcharbinary: CHARACTER = 'V'

feature -- Constants

	backlink_area_size: INTEGER = 263
			-- Used in Visual FoxPro (but not FoxPro 2.x or Foxbase+)
			-- to hold references from a DBF to a DBC (database container)
			-- file.

	backlink_area_size_foxbase: INTEGER = 0
			-- Like `backlink_area_size', this constant denotes the size
			-- of the backlink area, but for Foxbase+/FoxPro 2.x only.

	header_block_size: INTEGER = 32
			-- All DBF headers are 32 bytes in length.

	subrecord_size: INTEGER = 32
			-- All subrecord specifications are 32 bytes in length.
			-- There is one subrecord specification for each field
			-- in a DBF.

feature -- Constants: Byte-manipulation

	msb7_multiplier_256: INTEGER_32 = 256
	msb6_multiplier_65_536: INTEGER_32 = 65_536
	msb5_multiplier_16_777_216: INTEGER_32 = 16_777_216
	msb4_multiplier_4_294_967_296: INTEGER_64 = 4_294_967_296
	msb3_multiplier_1_099_511_627_776: INTEGER_64 = 1_099_511_627_776
	msb2_multiplier_281_474_976_710_656: INTEGER_64 = 281_474_976_710_656
	msb_multiplier_72_057_594_037_927_936: INTEGER_64 = 72_057_594_037_927_936
			-- {INTEGER_64} consists of 8 bytes. In FoxPro, some data-types
			--	are stored in reverse order (MSB->LSB gets stored LSB->MSB).
			--	Therefore, {INTEGER_8} byte values must be translated to their
			--	proper numeric value when replaced into an {INTEGER_64}.

	starting_first_data_record_position: INTEGER_32 = 296
			-- Start of `first_data_record_start_byte'.

	true_mark: CHARACTER = 'T'
			-- When a DBF record is "Marked-for-deletion", the {CHARACTER} used
			--	is 'T' for True.

	not_deleted_delete_mark: CHARACTER = '%/0x20/'
			-- Character used as the "delete-mark", when a record in a
			--	DBF is NOT-deleted.

	space: CHARACTER = '%/0x20/'
			-- Character used in {STRING} (e.g. "character") fields to
			--	right-pad string contents less than the length of the field.

	end_of_file_marker: CHARACTER_8 = '%/0x1A/'
			-- Every DBF file has a special character used to mark EOF.

	decimal_point: CHARACTER_8 = '.'
			-- Decimal point character used in "float" data-types.

	valid_float_content: STRING = " .0123456789"
			-- Valid float content characters.

	dbf_file_extension: STRING = ".dbf"
			-- Valid extension for DBF files.

	default_file_name: STRING = "untitled"
			-- Name to use by default when creating new DBF files.

	hex_head_reduction_value: INTEGER = 6
			-- Value to reduce {CHARACTER}.to_hex_string {STRING} by to be left with a 2-digit Hex value.

	year_2000: INTEGER = 2000

	Days_from_4713_to_1600: INTEGER_32 = 2_305_448
			-- Precise number of days betwen 1-1-4713 BC and 1-1-1600 AD.

	Anno_domini_proleptic_difference: INTEGER_32 = 327

	Before_christ_proleptic_difference: INTEGER_32 = 328

end
