export PYTHONPATH=/usr/local/lib/python2.7/site-packages/

ophis -l listfile.txt -m labelmap.txt -o MOUSE_ROM.bin MOS_main.asm 
#py65mon -m 65c02 -r ophis.bin 

