import os
from os import listdir
def concat_files(indir, outfile):
    of = open(outfile, mode='w')
    files = listdir(indir)
    files.sort()
    for f in files:
        path = indir + '/' + f
        fd = open(path)
        turno = f[2:8]
        # remove first line
        lines = fd.readlines()[1:]
        lines = [turno +"," + d.split(",", 1)[1] for d in lines]
        of.writelines(lines)
        fd.close()
    of.close()
    

if __name__ == "__main__":
    concat_files("/home/grid/data/wind", "/home/grid/data/wind2/gw_all_trans.csv")
