# This script is part of YMP
#
#This script replace turkish characters with ascii compatible
# ÇİĞÖŞÜ -> CIGOSU and çığöşü -> cigosu
#
# Usage: sed -i -f fix-turkish.sed /path/to/file.po
s/ç/c/g
s/ı/i/g
s/ğ/g/g
s/ö/o/g
s/ş/s/g
s/ü/u/g
s/Ç/C/g
s/İ/I/g
s/Ğ/G/g
s/Ö/O/g
s/Ş/S/g
s/Ü/U/g
