2ddoc
=====

This project verifies the validity of a 2d-doc signature contained in a picture. The public key is for the moment pubkey.pem located in the same path than the execution context. 

Usage example
------------- 

> $ ./verify.sh
> Usage: ./verify.sh <2ddoc picture>
> $ ./verify.sh facture.jpg
> Extract information from figure facture.jpg (147 bytes)
> 0

The program displays 0 witch is the openssl latest execution status. It means signature has been correctly verified regarding the available pubkey.pem.

This project uses external programs:
* dmtxread to read information stored in data matrix barcodes. 
* openssl to perform cryptographic verifications
* uses xxd for debug information


