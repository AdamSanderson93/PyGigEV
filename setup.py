import numpy
from distutils.core import setup
from distutils.extension import Extension

USE_CYTHON = True

ext = '.pyx' if USE_CYTHON else '.c'

extensions = [Extension("pygigev", 
                             ["pygigev" + ext], 
                             language="c",
                             include_dirs=["/usr/dalsa/GigeV/include/", numpy.get_include()],
                             libraries=["GevApi"],
                             )]
if USE_CYTHON:    
    from Cython.Build import cythonize
    extensions = cythonize(extensions)

setup(
    ext_modules = extensions
    )

# from distutils.core import setup
# from distutils.extension import Extension

# USE_CYTHON = ...   # command line option, try-import, ...

# ext = '.pyx' if USE_CYTHON else '.c'

# extensions = [Extension("example", ["example"+ext])]

# if USE_CYTHON:
#     from Cython.Build import cythonize
#     extensions = cythonize(extensions)

# setup(
#     ext_modules = extensions
# )
