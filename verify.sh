#! /bin/bash
# Gabriel Serme
# quick extraction and verification of 2d-doc with openssl
# please check https://nunix.fr/index.php/news/61-2d-doc-using-numeric-to-protect-physical-documents
# or http://www.2d-doc.com

ssize=64
DEBUG=false

debug(){
out=$1
}

usage(){
    echo "Usage: $0 <2ddoc picture>"
    exit 0
}

tmpf(){
    tmp=$(tempfile -s "2ddoc")
    trap "rm -f '$tmp'" exit
    echo $tmp
}

sizeof(){
    file=$1
    stat -c "%s" $file
}

if [ $# -ne 1 ]; then
    usage
fi

file=$1
if [ ! -e $file ]; then
    usage
fi

tmp=$(tmpf)
dmtxread $file > $tmp
fsize=$(sizeof $tmp)
echo "Extract information from figure $file ($fsize bytes)"

#split the info in two distinct files:
# sizeof(file) - 64 is datafile
# last 64 bytes are the signature
let "dsize=$fsize-ssize"
let "ssize1=$ssize/2"
let "ssize2=$ssize/2"
let "skipd=$dsize+$ssize1"
datafile=$(tmpf)
sigfile=$(tmpf)
info=$(dd if=$tmp of=$datafile bs=1 count=$dsize 2>&1)
debug $info

 
#encapsulate the signature in asn1 for openssl manipulation
echo -ne "\x30\x44\x02\x20" >> $sigfile
info=$(dd if=$tmp of=$sigfile bs=1 skip=$dsize seek=$(sizeof $sigfile) count=$ssize1 2>&1)
debug $info
echo -ne "\x02\x20" >> $sigfile
info=$(dd if=$tmp of=$sigfile bs=1 skip=$skipd seek=$(sizeof $sigfile) count=$ssize2 2>&1)
debug $info

info=$(xxd $datafile 2>&1)
debug $info
info=$(xxd $sigfile 2>&1)
debug $info


result=$(openssl dgst -sha256 -verify pubkey.pem -signature $sigfile $datafile)
#it returns 1 if a error occured
#it returns 0 if the signature is valid
echo $?


