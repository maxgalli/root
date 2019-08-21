import glob, os
from distutils.core import setup, Extension

setup(
        name='CPyCppyy',

        ext_modules=[Extension('libcppyy',
            sources=glob.glob(os.path.join('src', '*.cxx')),
            include_dirs=['src', 'inc'],
            libraries=['cppyy_backend'])],
        )
