#!/usr/bin/env python
"""Count the occurrences of .Fortran, .C, and .Call calls per R
package in a given directory.

"""

import tarfile
import glob
import os
import re
import sys

"""Regular expression matching files in R packages stored in */R/* in
tar files

"""
R_FILES_RE = re.compile('[\w\d]+/R/.*\.R$')


"""Regular expression catching calls to .Fortran, .C, and .Call calls

"""
R_CALLS = re.compile('\.(Fortran|C|Call|External)\s*\(')


"""Return a list of .tar.gz files in base.

Keyword arguments:
base -- base path

"""
def get_tar_files(base):
    return glob.glob(os.path.join(base,'*.tar.gz'))


"""
Generator returning only member names matching R_FILES_RE.

Keyword arguments:
members -- list of TarInfo objects.
"""
def R_files(members):
    for tarinfo in members:
        if R_FILES_RE.match(tarinfo.name) and tarinfo.isreg():
            yield tarinfo

        
"""Extract a given member from tar, and analyzes it line by line. The
result of found .Fortran, .C, and .Call calls is stored in stats in
their respective keys, i.e. 'Fortran', 'C', and 'Call'.

Keyword arguments:
tar -- TarFile object where member has to be extracted from
member -- TarInfo object of member to extract
stats -- dictionary where number of function call occurrences are incremented

"""
def peek_into_member(tar, member, stats):
    fileobj = tar.extractfile(member)
    for line in fileobj:
        match = R_CALLS.search(line)
        if match:
            stats[match.group(1)]+=1

    fileobj.close()


"""Given a full path to a tarfile, it returns the name only, i.e. it
removes the leading path name and .tar.gz sufffix.

"""
def name_from_tar_file(tarfile):
    return os.path.basename(tarfile).replace('.tar.gz','')
    

"""Given a TarFile object, it iterates over the members in '*/R/*'
and counts the number of calls to '.Fortran', '.C', and '.Call'. The
result is printed to stdout using following format:

 <packagename>,<fortran_calls>,<c_calls>,<call_calls>,<external_calls>

"""
def iterate_over_tar_content(tar):
    tarname = name_from_tar_file(tar.name)
    stats={ 'Fortran': 0, 'C': 0, 'Call': 0, 'External': 0,  'Name': tarname }
    for member in R_files(tar):
        peek_into_member(tar, member, stats)

    print("{Name},{Fortran},{C},{Call},{External}".format(**stats))


"""Given a base directory name, it iterates over all .tar.gz files
contained therein non-recursively. For each .tar.gz it calls
iterate_over_tar_content().

When done, it prints the number of processed files to stdout.

"""
def iterate_over_tar(base):
    tar_files = get_tar_files(base)
    counter = 0
    for tar_file in tar_files:
        with tarfile.open(tar_file) as tar:
            iterate_over_tar_content(tar)
            counter += 1

#    print("Processed %d file(s)" % (counter,))


"""Do the magic

"""
if __name__ == "__main__":
    print("Name,Fortran,C,Call,External")
    iterate_over_tar(sys.argv[1])
