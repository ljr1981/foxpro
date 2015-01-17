note
	description: "[
		Hexidecimal Helpers
		]"
	synopsis: "[
		There is a need to see strings of non-printable characters
		as a stream of Hex values or digits. This feature is NOT
		required for the building of FoxPro DBF files, but is
		convenient for testing DBF-producing code to ensure the
		proper output is being generated. Thus, this class will be
		primarily inherited from in *_TEST_SET classes.
		
		As such, this class and its feature ought only be available
		to testing classes.
		]"
	date: "$Date: 2015-01-08 00:48:24 -0500 (Thu, 08 Jan 2015) $"
	revision: "$Revision: 10522 $"

class
	FP_HEX_HELPER

feature -- Basic Operations

	string_to_hex_string (a_value: STRING): STRING
			-- Convert an arbitrary STRING value to a sequence of hyphen-delimited hex values.
		note
			synopsis: "[
				`a_value' such as "ABC" will yield the Result: "41-42-43"
				`a_value' such as "XYZ" will yield the Result: "58-59-5A"
				]"
		require
			non_empty_value: not a_value.is_empty
		local
			l_item: STRING
		do
			create Result.make_empty
			across
				a_value as ic_item
			invariant
				last_is_delimiter: not Result.is_empty implies Result [Result.count] = Delimiter
				by_threes_only: not Result.is_empty implies (Result.count \\ 3) = 0
			loop
				l_item := ic_item.item.code.to_hex_string
				check eight_characters: l_item.count = 8 end
				l_item.remove_head (6)
				check two_characters: l_item.count = 2 end
				Result.append_string (l_item)
				Result.append_character (Delimiter)
			end
			if Result.count > 2 then
				Result.remove_tail (1)
			end
		ensure
			value_implies_result: not a_value.is_empty implies not Result.is_empty
			result_sizing: Result.count = (a_value.count * 3 - 1)
		end

	delimiter: CHARACTER = '-'

	header_string_now_as_hex (a_specification: FP_SPEC): STRING
		local
			l_date: DATE
		do
			create l_date.make_now
			Result := header_string_as_hex (a_specification, l_date.year, l_date.month, l_date.day)
		end

	header_string_as_hex (a_specification: FP_SPEC; a_year, a_month, a_day: INTEGER): STRING
			-- `header_string' as HEX.
		do
			Result := string_to_hex_string (a_specification.specification_on_date (create {DATE}.make (a_year, a_month, a_day)))
		end

end
