note
	description: "[
		Generic Specification
		]"
	synopsis: "[
		A FoxPro table structure specification has two primary parts:
		
			(1) DBF Table Header Specification {FP_HEADER}
			(2) DBF-subrecord Field Specification {FP_FIELD_SUBRECORD}
			
		Current enclosed features and operations common to both of
		the above. While it would normally be too early to note this
		relationship of descendent classes, the VFP DBF table structure
		specification is stable enough to allow this note documentation
		to appear here. It is here to orient you to the ultimate goal
		of this class.
		
		Moreover, there are essentially three ways to get the specifcation
		from Current:
		
		(1) `out'					Where {ANY}.out is redefined and hooked 
									up to `specification_now'.
		(2) `specification_now'		Where any date-sensitive content of the
									header is based on {DATE}.make_now
		(3) `specification_on_date'	Where any date-sensitive content of the
									header is based on CCYYMMDD from client.
		
		Finally, the notion of specification is that of a structure as
		represented by features and a specification {STRING} output, where
		the output is precisely as needed by Visual FoxPro to open and
		utilize a file resulting from Current as a DBF (i.e. this
		specification is used to produce a DBF file).
		]"
	date: "$Date: 2015-01-16 08:59:42 -0500 (Fri, 16 Jan 2015) $"
	revision: "$Revision: 10596 $"

deferred class
	FP_SPEC

inherit
	ANY
		redefine
			out
		end

feature -- Access

	out: like {ANY}.out
			-- <Precursor>
			-- Repurposed to output the `specification_now'.
		do
			Result := specification_now
		end

	specification_now: like {ANY}.out
			-- Specification of Current based on moment of call.
		deferred
		end

	specification_on_date (a_date: DATE): STRING
			-- Specification based on `a_date'.
		deferred
		end

end
