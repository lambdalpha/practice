# -*- coding: utf-8 -*-

from feature import feature_trans
import os

var_list_orig = ['wnac_wspd_instmag_f','wgen_spd_instmag_i', 'wrot_rotspd_instmag_1_i',
                 'wyaw_pos', 'wtur_yaw_speed', 'wtur_pwrat_instmag_f', 'wcnv_pwrreact_instmag_f']
var_list_ang_orig = ['wnac_wdir_instmag_f', 'wrot_ptangval_bl1']

def gen_feature(indir, outdir):
    for subdir, dirs, files in os.walk(indir):
        for file in files:
            if file.find(".txt") > 0:
                feature_trans(subdir + '/' + file, var_list_orig, var_list_ang_orig, \
                outdir+'/'+file[0:-4] + "_trans.csv")

if __name__ == '__main__':
    gen_feature("/home/grid/GoldWind/HPData/HPData", "/home/grid/data/wind2" )
