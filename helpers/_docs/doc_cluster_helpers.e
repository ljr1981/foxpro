note
	description: "[
		Cluster Documentation of Helper classes
		]"
	synopsis: "[
		Any number of "helper" classes are needed by the primary
		specification classes in this library. For example: There
		is a need for parsing {INTEGER_32} objects, consisting of
		4 8-bit bytes into individual bytes for storage in the
		DBF byte-stream in LSB->MSB order (see {FP_BYTE_HELPER}
		for definitions of LSB and MSB).
		]"
	date: "$Date: 2014-12-24 14:54:28 -0500 (Wed, 24 Dec 2014) $"
	revision: "$Revision: 10455 $"

deferred class
	DOC_CLUSTER_HELPERS

feature -- Primary

	byte_helper: detachable FP_BYTE_HELPER
			-- Byte helper class.

end
