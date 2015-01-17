note
	description: "[
		Library Documentation for Jinny FoxPro
		]"
	synopsis: "[
		The FoxPro library is designed to allow you (as an Eiffel programmer) to
		access (read and write) FoxPro DBF files, excluding indexes, memos,
		generals, and blobs, which are presently out-of-scope for current needs.
		
		See {FP_DBF_WRITER} for documentation on writing DBF files (below). For
		reading DBF files, see {FP_DBF_READER}. Examples of these classes being
		used can be found in the test target of this library.
		
		See the EIS link to readme.pdf below for more information.
		]"
	EIS: "name=readme", "protocol=PDF", "tag=readme",
			"src=$JINNY_TRUNK\jinny_foxpro\readme.pdf"
	EIS: "name=video", "protocol=URI", "tag=video",
			"src=https://www.youtube.com/watch?v=vHD2_O808YE&feature=youtu.be&hd=1"

	specifications: "[
		The EIS links below are to external documentation used in the creation
		of this library.
		]"
	EIS: "name=foxpro_header_specification", "protocol=URI", "tag=external",
			"src=http://msdn.microsoft.com/en-us/library/st4a0s68(VS.80).aspx"
	EIS: "name=foxpro_file_specification", "protocol=URI", "tag=external",
			"src=http://www.dbf2002.com/dbf-file-format.html"
	EIS: "name=dbf_field_types_and_specifications", "protocol=URI", "tag=external",
			"src=http://devzone.advantagedatabase.com/dz/webhelp/advantage9.0/server1/dbf_field_types_and_specifications.htm"
	date: "$Date: 2015-01-16 10:27:47 -0500 (Fri, 16 Jan 2015) $"
	revision: "$Revision: 10604 $"

deferred class
	DOC_LIBRARY_A_JINNY_FOXPRO

feature -- Primary Documentation

	reader: detachable FP_DBF_READER
			-- Class for reading DBFs.
			--| See: FP_DBF_READER_TEST_SET for examples of reading DBFs.

	writer: detachable FP_DBF_WRITER
			-- Class for writing DBFs.
			--| See: FP_DBF_WRITER_TEST_SET for examples of writing DBFs.

feature -- Other Documentation

	helpers: detachable DOC_CLUSTER_HELPERS
			-- Documentation on the "helpers".

end
