note
	description: "[
		Testing of the Jinny FoxPro library
		]"
	synopsis: "[
		Testing primarily consists of testing specification classes
		(like {FP_HEADER} and {FP_FIELD_SUBRECORD}). It also tests
		various "helper" classes.
		]"
	todo: "[
		(1) Ensure testing for all use-cases. Several are not yet written.
		]"
	date: "$Date: 2014-12-24 14:54:28 -0500 (Wed, 24 Dec 2014) $"
	revision: "$Revision: 10455 $"

deferred class
	DOC_CLUSTER_TESTS

feature -- Testing Classes

	header_tests: detachable FP_HEADER_TEST_SET
			-- Tests of the header specification.

	field_subrecord_tests: detachable FP_FIELD_SUBRECORD_TEST_SET
			-- Tests of the header sub-record specification.

feature -- Test Support

	hex_helper: detachable FP_HEX_HELPER
			-- Class providing test-support for hex-related operations.

end
