note
	description: "[
		Tests of the {FP_FIELD_SUBRECORD} specification.
	]"
	testing: "[
		(1) The testing of {FP_FIELD_SUBRECORD} follows a similar pattern
			as the {FP_HEADER} class tests, except for the {FP_BYTE_HELPER}
			tests. The specification generated here for testing is reused
			in the header as a single field on the file.
		]"
	EIS: "name=foxpro_field_specification", "protocol=URI", "tag=external",
			"src=http://devzone.advantagedatabase.com/dz/webhelp/advantage9.0/server1/dbf_field_types_and_specifications.htm"
	EIS: "name=binary_hex_dex_converter", "protocol=URI", "tag=external",
			"src=http://www.binaryhexconverter.com/hex-to-decimal-converter"
	date: "$Date: 2015-01-12 10:56:39 -0500 (Mon, 12 Jan 2015) $"
	revision: "$Revision: 10541 $"
	testing: "type/manual"

class
	FP_FIELD_SUBRECORD_TEST_SET

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

	subrecord_test
			-- Test {FP_FIELD_SUBRECORD}
		local
			l_sub: FP_FIELD_SUBRECORD [STRING]
		do
			create l_sub
			l_sub.set_field_name ("FLD_CHAR")
			l_sub.set_field_type ('C')
			l_sub.set_displacement (1)
			l_sub.set_field_length_in_bytes (10)
			l_sub.set_number_of_decimal_places (0)
			assert_strings_equal ("field_subrecord_string_same", test_field, header_string_now_as_hex (l_sub))
		end

	date_test
			-- Testing dates for VFP
		note
			synopsis: "[
				In Visual FoxPro/Foxbase+/dBase-III, the Date-time or Timestamp spec is:

				@	Timestamp	8 bytes - two longs, first for date, second for time.  
				The date is the number of days since  01/01/4713 BC. Please see the EIS
				links below for "Julian Day" and the proleptic calendars, which explain
				the basis for the 4713 BC Julian date anchor in FoxPro. 
				
				Julian-to-Gregorian Difference
				==============================
				
				There is precisely 327 days difference between the Julian and the
				Gregorian, which is where the 327 comes from in the tests that follow.
				Moreover, note that the 327 and 328 values are based on differences
				from 1 AD + and 1 BC - (e.g. 0-year and back).
				
				The 327 (AD) or 328 (BC) day difference is based on Jan 1 to Nov 24.
				]"
			EIS: "name=hex_to_dec_conversion", "protocol=URI", "tag=external",
					"src=http://www.binaryhexconverter.com/hex-to-decimal-converter"
			EIS: "name=dbf_reader_csharp_dot_net", "protocol=URI", "tag=external",
					"src=https://gist.github.com/sleimanzublidi/27acd30b5d4b452d5ec6"
			EIS: "name=julian_day", "protocol=URI", "tag=external",
					"src=http://en.wikipedia.org/wiki/Julian_day"
			EIS: "name=proleptic_gregorian", "protocol=URI", "tag=external",
					"src=http://en.wikipedia.org/wiki/Proleptic_Gregorian_calendar"
			EIS: "name=proleptic_julian", "protocol=URI", "tag=external",
					"src=http://en.wikipedia.org/wiki/Proleptic_Julian_calendar"
		local
			l_date: DT_DATE
		do
				-- 1/1/1600 Eiffel {DATE} origin
			create l_date.make (1600, 1, 1)
			l_date.add_days (-2_305_448 - anno_domini_proleptic_difference) -- 1/1/1600 --> 23-2D-A8 --> 2_305_448
			assert_strings_equal ("1600_01_01", "-4713/01/01", l_date.out)

				-- 1/1/1000
			create l_date.make (1000, 1, 1)
			l_date.add_days (-2_086_303 - anno_domini_proleptic_difference) -- 1/1/1000 --> 1F-D5-9F --> 2_086_303
			assert_strings_equal ("1000_01_01", "-4713/01/01", l_date.out)

				-- What is special about Year 0000?
			create l_date.make (0, 3, 1)
			l_date.add_days (-1_721_120 - before_christ_proleptic_difference) -- 3/1/0000 --> 1A-43-20 --> 1_721_120
			assert_strings_equal ("0000_03_01", "-4713/01/01", l_date.out)
			create l_date.make (0, 3, 2)
			l_date.add_days (-1_721_121 - before_christ_proleptic_difference) -- 3/2/0000 --> 1A-43-21 --> 1_721_121
			assert_strings_equal ("0000_03_02", "-4713/01/01", l_date.out)
			create l_date.make (0, 4, 1)
			l_date.add_days (-1_721_151 - before_christ_proleptic_difference) -- 4/1/0000 --> 00-1A-43-3F --> 1_721_151
			assert_strings_equal ("0000_04_01", "-4713/01/01", l_date.out)
			create l_date.make (0, 12, 31)
				-- Year 0000 Barrier is where we change from 328 to 327
			l_date.add_days (-1_721_425 - before_christ_proleptic_difference) -- 12/31/0000 --> 00-1A-44-51 --> 1_721_425
			assert_strings_equal ("0000_12_31", "-4713/01/01", l_date.out)
			create l_date.make (1, 1, 1)
			l_date.add_days (-1_721_426 - anno_domini_proleptic_difference) -- 1/1/0001 --> 00-1A-44-52 --> 1_721_426
			assert_strings_equal ("0001_01_01", "-4713/01/01", l_date.out)

				-- Big future
			create l_date.make (4567, 12, 30)
			l_date.add_days (-3_389_486 - anno_domini_proleptic_difference)
			assert_strings_equal ("4567_12_30", "-4713/01/01", l_date.out)
		end

feature {NONE} -- Implementation
--																								   1
--       1         2         3         4         5         6         7         8         9         0
--34567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	test_field: STRING = "[
46-4C-44-5F-43-48-41-52-00-00-00-43-01-00-00-00-0A-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
]"

	anno_domini_proleptic_difference: INTEGER = 327

	before_christ_proleptic_difference: INTEGER = 328

note
	specifications: "[
DBF Field Types and Specifications
==================================

Standard DBF Table Data Types
-----------------------------

The following are standard field data types available in DBF tables. The length 
indicates the amount of data stored in the record image. For fields that include 
memo file storage, see the description for the amount of data that can be stored.

Type			Length		Decimals		Description
==============	===========	==============	============================================================================================
(1) Character	1 to 65534	N/A				Fixed-length character field that is stored entirely in the table. Note that if you
											want the table to be compatible with Visual FoxPro, you should limit the field
											length to 254 or less.

(2) Numeric		1 to 32		0 to Length-2	Fixed-length (exact ASCII representation) numeric.

(3) Date		8			N/A				8-byte date field in the form of CCYYMMDD.

(4) Logical		1			N/A				1-byte logical (boolean) field. Recognized values for True are ‘1’, ‘T’, ‘t’, ‘Y’, and ‘y’.

(5) Memo		10 or 4		N/A				Variable-length memo field. The size of each field is limited to 4 GB.

											Visual FoxPro memo fields require 4 bytes in the record image, while standard DBF
											memo fields require 10 bytes.

											The memo data is actually stored in a separate file, called a memo file, to reduce
											table bloat.

Extended DBF Table Data Types
-----------------------------

The following are extended field data types available in DBF tables. The extended 
data types are non-standard DBF extensions. Non-Advantage applications that read 
DBF tables may not be able to open and read tables that have extended data types. 
Visual FoxPro will recognize double, integer, general, and picture fields.

Type			Length		Decimals		Description
==============	===========	==============	============================================================================================
(6) Double		8			0-20			8-byte IEEE floating point value in the range 1.7E +/-308 (15 digits of precision).
											The decimal value affects NTX indexes and the use of the field in expressions.
											It does not affect the precision of the stored data. If the length is given, it
											will be ignored. For example, "salary, double, 10, 2" and "salary, double, 2"
											produce the same field.
											
											Example: 99,999,999 = F0-E8-A4-D4-E8-00-00-00 --> 240-232-164-212-232-0-0-0
											
												Byte	Signif	Multiplier
												----	------	----------
												(1) 	LSB		? x 1
												(2) 	MSB7	? x 256
												(3) 	MSB6	? x 65_536
												(4) 	MSB5	? x 16_777_216
												(5) 	MSB4	? x 4_294_967_296
												(6) 	MSB3	? x 1_099_511_627_776
												(7) 	MSB2	? x 281_474_976_710_656
												(8) 	MSB		? x 72_057_594_037_927_936
											
															   240 + (232 x 256) + (164 x 65_536) + (212 x 16_777_216) + (232 x 4_294_967_296) + (0 x 1_099_511_627_776) + (0 x 281_474_976_710_656) + (0 x 72_057_594_037_927_936)
												999999990000 = 240 + 	59392	  +		10747904  +     3556769792   +      996432412672 + 0 + 0 + 0

(7) Integer		4			N/A				4-byte long integer values from -2,147,483,648 to 2,147,483,647.

(8) ShortDate	3			N/A				3-byte date field. This type supports the same range of dates as a standard
											date field.

(9) Image		10			N/A				Variable-length memo field containing binary image data. The size of each
											field is limited to 4 GB. The binary image data is actually stored in a separate
											file, called a memo file, to reduce table bloat. If using the Advantage CA-Visual
											Objects RDDs, Advantage Client Engine APIs must be used to set and retrieve
											the image data. Most non-Advantage applications will interpret this data as
											a text memo field with a short text identifier.

(10) Binary		10			N/A				Variable-length memo field containing binary data. The size of each field is
											limited to 4 GB. The binary data is actually stored in a separate file,
											called a memo file, to reduce table bloat. If using the Advantage CA-Visual
											Objects RDDs, Advantage Client Engine APIs must be used to set and retrieve
											the binary data. Most non-Advantage applications will interpret this data
											as a text memo field with a short text identifier.

											Visual FoxPro DBF Table Data Types
											In addition to the standard DBF types, the following types can be used when 
											using the ADS_VFP table type (Visual FoxPro driver). These are fully 
											compatible with Visual FoxPro.

(11) Integer	4			N/A				4-byte long integer values from -2,147,483,648 to 2,147,483,647.

(12) Binary		4			N/A				Variable-length field containing binary (Blob) data. The size of each Blob
											is limited to 4 GB. The binary data is stored in the FPT memo file
											associated with the table.

(13) Money		8			4 implied		Currency data stored internally as a 64-bit integer, with 4 implied decimal
											digits from -922,337,203,685,477.5807 to +922,337,203,685,477.5807. The
											Money data type will not lose precision.

(14) TimeStamp	8			N/A				DateTime value containing year, month, day, hour, minute, and second. Note
											that the timestamp value can contain milliseconds, but Visual FoxPro always
											rounds to the nearest second. Unlike ADI index keys, VFP TimesStamp index
											keys do not contain the millisecond portion of the value.
											
											12/30/4567 12:34:56 AM --> 	2E-B8-33-00-80-FB-1F-00		hex
																		46-184-51-0-128-251-31-00	dec
																		
																		2E-B8-33-00 --> 00-33-B8-2E = 3_389_486
																		80-FB-1F-00 --> 00-1F-FB-80 = 
																		
																		7F-FF-FF-FF-FF-FF-FF-FF
											01/09/2015 12:00:00 AM -->	C8-7D-25-00-00-00-00-00		hex
																		200-125-37-0-0 -0 -0 -0		dec
																		
																		C8-7D-25-00 --> 00-25-7D-C8 = 2_457_032 / 365 = 6731 years - 4713 = 2018 (roughly)
																		00-00-00-00 --> 00-00-00-00 = ???
																		
											@	Timestamp	8 bytes - two longs, first for date, second for time.  
											The date is the number of days since  01/01/4713 BC. 
											Time is hours * 3600000L + minutes * 60000L + Seconds * 1000L



												Byte	Signif	Multiplier
												----	------	----------
												(1) 	LSB		46 	x 1							= 000_000_000_000_000_046
												(2) 	MSB7	184	x 256						= 000_000_000_000_047_104
												(3) 	MSB6	51 	x 65_536					= 000_000_000_003_342_336
												(4) 	MSB5	0 	x 16_777_216				= 000_000_000_000_000_000
												(5) 	MSB4	128	x 4_294_967_296				= 000_000_549_755_813_888
												(6) 	MSB3	251	x 1_099_511_627_776			= 000_275_977_418_571_776
												(7) 	MSB2	31 	x 281_474_976_710_656		= 008_725_724_278_030_336
												(8) 	MSB		0 	x 72_057_594_037_927_936	= 000_000_000_000_000_000
																								  =======================
																								  009_002_251_455_805_486

											September 30th 2008
											
											1822392319 = 0x6c9f7fff
											0x6c = 108 = 2008 (based on 1900 start date)
											0x9 = 9 = September
											0xf7fff - take top 5 bits = 0x1e = 30
											
											
											October 1st 2008

											1822490623 = 0x6ca0ffff
											0x6c = 108 = 2008
											0xa = 10  = October
											0x0ffff  - take top 5 bits = 0x01 = 1
											It's anyone's guess what the remaining 15 one-bits are for, if anything.

											EDIT: by take top 5 bits I mean:

											day_of_month = (value >> 15) & 0x1f
											Similarly:

											year = (value >> 24) & 0xff + 1900
											month = (value >> 20) & 0x0f



(15) Character 	1 to 65534	N/A				Fixed-length character field that is stored entirely in the table. The
(NoCPTrans)									NoCPTrans (binary) option indicates that ANSI/OEM translations will not
											be performed on the data. Note that if you want the table to be compatible
											with Visual FoxPro, you should limit the field length to 254 or less.

(16) Autoinc	4			N/A				4-byte read-only positive integer value from 0 to 4,294,967,296 that is
											unique for each record in the table. A starting value and the increment
											value can be supplied when creating the table.

(17) Memo 		4			N/A				Variable-length memo field containing character data. The size of each
(NoCPTrans)									field is limited to 4 GB. The NoCPTrans (binary) option indicates that
											the ANSI/OEM translations will not be performed on the data.

(18) Varchar	1 to 254	N/A				This field type allows variable length character data to be stored up to
											the maximum field length, which is specified when the table is created.
											It is similar to a character field except that the exact same data will
											be returned when it is read without extra blank padding on the end.

(19) Varchar 	1 to 254	N/A				This is the same as a VarChar except that no ANSI/OEM translations will
(NoCPTrans)									be performed on the data.

(20) Varbinary	1 to 254	N/A				Variable length binary data. The maximum length of data that can be stored
											in the field is specified when the table is created.


Footnotes:
=========================================================================
(1) When creating Visual FoxPro (VFP) tables, you can specify that a specific
	field allows NULL values. To do this, include "NULL" in the table creation
	string. If it is for an Advantage Client Engine API such as AdsCreateTable,
	include it as an additional comma delimited item. The same can be done with
	the NoCPTrans option. For example, the table creation string "c,char,10,null,nocptrans; i,integer,null;"
	specifies a table with two fields that can hold NULL values and with no
	codepage translations performed on the character field. With SQL, the
	options are provided after the field type. The equivalent SQL field
	definition would be "(c char(10) null nocptrans, i integer null )".
]"
end


