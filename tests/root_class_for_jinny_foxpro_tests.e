note
	description: "[
		Root class for testing.
		]"
	date: "$Date: 2014-12-29 17:30:48 -0500 (Mon, 29 Dec 2014) $"
	revision: "$Revision: 10468 $"

class
	ROOT_CLASS_FOR_JINNY_FOXPRO_TESTS

inherit
	ANY

create
	default_create

feature -- Access

	documentation: detachable DOC_LIBRARY_A_JINNY_FOXPRO
			-- Documentation for library.

	test_1: detachable FP_HEADER_TEST_SET

	test_2: detachable FP_FIELD_SUBRECORD_TEST_SET

end
