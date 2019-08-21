import glob, os
from distutils.core import setup, Extension

setup(
        name='cppyy_backend',
        packages=['cppyy_backend'],
        package_dir={'' : 'cling/python'},

        ext_modules=[Extension('libcppyy_backend',
            sources=glob.glob(os.path.join('clingwrapper', 'src', '*.cxx')),
            include_dirs=['clingwrapper/src'],
            libraries=['Core', 'dl'])],
        )
