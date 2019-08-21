import glob, os, sys
from distutils.core import setup, Extension

setup(
        name='ROOT',
        packages=['ROOT'],
        package_dir={'' : 'python'},

        ext_modules=[Extension('libROOTPython',
            sources=glob.glob(os.path.join('src', '*.cxx')),
            include_dirs=['src', 'inc'],
            libraries=['Core', 'Tree', 'cppyy', 'cppyy_backend'])],
        )
