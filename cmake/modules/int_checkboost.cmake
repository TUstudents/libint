cmake_policy(PUSH)
cmake_policy(SET CMP0075 NEW)  # support CMAKE_REQUIRED_LIBRARIES

include(CMakePushCheckState)

cmake_push_check_state()
if (NOT TARGET Boost::headers)
    message(FATAL_ERROR "int_checkboost.cmake: can only invoke if Boost::headers is already available")
endif()
# can only link against system or IMPORTED target here
get_target_property(BOOST_HEADERS_IS_IMPORTED Boost::headers IMPORTED)
if (BOOST_HEADERS_IS_IMPORTED)
    list(APPEND CMAKE_REQUIRED_LIBRARIES Boost::headers)
else()  # if Boost::headers is not IMPORTED, it was built within this project, extract its properties
    # Collect include directories from Boost::headers and Boost::preprocessor (for modularized Boost)
    set(_boost_targets_to_check Boost::headers)
    if (TARGET Boost::preprocessor)
        list(APPEND _boost_targets_to_check Boost::preprocessor)
    endif()
    foreach(_boost_target IN LISTS _boost_targets_to_check)
        get_target_property(_interface_include_dirs ${_boost_target} INTERFACE_INCLUDE_DIRECTORIES)
        if (_interface_include_dirs)
            # Extract paths from $<BUILD_INTERFACE:...> generator expressions
            string(REGEX MATCHALL "\\$<BUILD_INTERFACE:([^>]+)>" _build_interface_matches "${_interface_include_dirs}")
            foreach(_match IN LISTS _build_interface_matches)
                string(REGEX REPLACE "\\$<BUILD_INTERFACE:([^>]+)>" "\\1" _include_dir "${_match}")
                list(APPEND CMAKE_REQUIRED_INCLUDES "${_include_dir}")
            endforeach()
        endif()
    endforeach()
endif()
#list(APPEND CMAKE_REQUIRED_FLAGS "-std=c++11")  # set CMAKE_CXX_STANDARD and 0067 NEW ?

check_cxx_source_compiles("
#include <boost/preprocessor.hpp>

int main(void) {  
#if not BOOST_PP_VARIADICS  // no variadic macros? your compiler is out of date! (should not be possible since variadic macros are part of C++11)
#  error \"your compiler does not provide variadic macros (but does support C++11), something is seriously broken, please create an issue at https://github.com/evaleev/libint/issues\"
#endif
    return 0;
}
"
    _boost_pp_variadics)

if (NOT _boost_pp_variadics)
    message(FATAL_ERROR "BOOST_PP_VARIADICS is oddly missing from detected installation")
endif()

cmake_pop_check_state()
cmake_policy(POP)
