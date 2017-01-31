#!/usr/bin/python
# TODO:
#   NOK fs-081023.gz
#   NOK fs-130327-060-1364312713337-2.gz
#   NOK fs-150519-093.gz (Could be manually extracted, however)
#   NOK fs-150519-094.gz

from   ftplib import FTP
import zlib
import sys
import time
import re
import os
import os.path

path_to_archive = sys.argv[1]

#  Make sure path_to_archive ends with a slash:
if path_to_archive[-1:] not in ('/', '\\'):
   path_to_archive += '/'

def get_gz(ftp, ftp_filename, local_filename):

    sys.stdout.write('get_gz ' + ftp_filename + ' to ' + local_filename)

    decomp = zlib.decompressobj(16+zlib.MAX_WBITS)

    try:
      unzip = open (local_filename, 'wb')
    except IOError:
      print "could not open " + local_filename
      return

    def next_packet(data):
        sys.stdout.write('.')
        unzip.write(decomp.decompress(data))

    try:
      ftp.retrbinary('RETR ' + ftp_filename, next_packet)

      decompressed = decomp.flush()
      unzip.write(decompressed)
    except zlib.error:
      print "\nzlib.error: could not decompress " + ftp_filename
      
    unzip.close()

    print ''

def get_firmen_und_bezeichnung(ftp):

    ftp.cwd('/hrdata')

    for ftp_file_name in ftp_zefix.nlst():
        if   re.match('fb.*\.gz$', ftp_file_name):
             get_gz(ftp_zefix, ftp_file_name, path_to_archive + 'firmen_bezeichnung')
             
        if   re.match('fi.*\.gz$', ftp_file_name):
             get_gz(ftp_zefix, ftp_file_name, path_to_archive + 'firmen')


def get_new_files(ftp, ftp_path):

    ftp_zefix.cwd(ftp_path)
    print ftp_zefix.pwd()
    

    for ftp_file_name in ftp_zefix.nlst():

        local_file_name = None
        
        match = re.search(r'^fs(\d\d)(\d\d\d)\.gz$', ftp_file_name);
        if match:
           local_file_name = match.group(1) + '-' + match.group(2)
        else:
           match = re.search(r'^fs-(\d\d)(\d\d)(\d\d)-(\d\d\d)\.gz$', ftp_file_name)

           if match:
              local_file_name = match.group(1) + '-' + match.group(4)
              

        if local_file_name:


           if os.path.isfile(path_to_archive + local_file_name):
           #  File already fetched and archived
              pass
           else:
           #  fetch the file
              get_gz(ftp_zefix, ftp_file_name, path_to_archive + local_file_name)
           #  time.sleep(10)
           


ftp_zefix = FTP('ftp.zefix.ch')
ftp_zefix.login()

get_firmen_und_bezeichnung(ftp_zefix)


get_new_files(ftp_zefix, '/hrdata/vortag/fs-archiv/')
get_new_files(ftp_zefix, '/hrdata/vortag/fs-archiv/2001')
get_new_files(ftp_zefix, '/hrdata/vortag/fs-archiv/2002')
get_new_files(ftp_zefix, '/hrdata/vortag/fs-archiv/2003/2003_format_alt_1-76')
get_new_files(ftp_zefix, '/hrdata/vortag/fs-archiv/2003/2003_format_neu_1-251')
get_new_files(ftp_zefix, '/hrdata/vortag/fs-archiv/2004')
