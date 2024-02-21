#!/bin/bash
#
# outside.osgav.run post-build steps
#

# clean up git-submodule-related files
rm public/subtest-abc/.git*
rm public/subtest-abc/*/.git*
rm public/subtest-abc/*/*/.git*

