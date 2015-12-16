# -*- coding: utf-8 -*-

#%matplotlib inline
#import datetime
import numpy as np

import pandas as pd

#from scipy import stats
#import matplotlib.pyplot as plt

#import statsmodels.api as sm
from scipy import ndimage
#from statsmodels.graphics.api import qqplot


def enframe(df, frame_len=64):
    #frame_len = 64 # 64 * 7 seconds
    n_frames = int(df.shape[0]/frame_len)
    index1 = np.asarray(range(0, n_frames)) * frame_len
    index2 = index1 + frame_len
    index = [range(x,y) for (x,y) in zip(index1, index2)]
    timestamp = df.wman_tm.values[index1]
    return (index, timestamp, n_frames) 


def ft_feature(frame, nfft=64):
    sigfft = np.fft.rfft(frame, nfft)
    mag = np.absolute(sigfft)
    n = int(nfft/2)
    m = 4
    g = int(n/m)
    E = 1. / nfft * np.square(mag)
    groups = np.arange(m).repeat(g)  
    return ndimage.sum(E[0: -1], groups, range(m))
    
def create_frame_feature(values, index, frame_len=64):
    frames = values[index]
    avg = np.array([np.average(x) for x in frames])
    minimum = np.array([np.min(x) for x in frames])
    maximum = np.array([np.max(x) for x in frames])
    #energy  = np.array([np.sum(ft_feature(x, frame_len)) for x in frames])
    energy  = np.array([ft_feature(x, frame_len) for x in frames])
    return (avg, minimum, maximum, energy)
    
def create_radius_vars(values, index, frame_len=64):
    sin_frames = np.sin(values/180*np.pi)[index]
    cos_frames = np.cos(values/180*np.pi)[index]
    tan_frames = np.tan(values/180*np.pi)[index]
    avg_sin = np.array([np.average(x) for x in sin_frames])
    avg_cos = np.array([np.average(x) for x in cos_frames])
    avg_tan = np.array([np.average(x) for x in tan_frames])
    min_sin = np.array([np.min(x) for x in sin_frames])
    min_cos = np.array([np.min(x) for x in cos_frames])
    min_tan = np.array([np.min(x) for x in tan_frames])
    max_sin = np.array([np.max(x) for x in sin_frames])
    max_cos = np.array([np.max(x) for x in cos_frames])
    max_tan = np.array([np.max(x) for x in tan_frames])
    
    return (avg_sin, min_sin, max_sin, avg_cos, min_cos, max_cos, avg_tan, min_tan, max_tan)

def read_csv(csv_file):
    df = pd.read_csv(csv_file, sep = "\t",  skipinitialspace=True)
    #df = df.sort_values(by='wman_tm', ascending=True)
    #df.index = pd.Index(range(df.shape[0]))
    return df

def create_short_time_features(df, var_list, index, frame_len=64):
    out_df = pd.DataFrame()
    for var in var_list:
        output = create_frame_feature(df[var].values, index, frame_len)
        out_df[var+'_avg'] = output[0]
        out_df[var+'_min'] = output[1]
        out_df[var+'_max'] = output[2]
        out_df[var+'_freq_0'] = output[3][:,0]
        out_df[var+'_freq_1'] = output[3][:,1]
        out_df[var+'_freq_2'] = output[3][:,2]
        out_df[var+'_freq_3'] = output[3][:,3] 
    return out_df


        
        
def create_short_time_radius_features(df, var_list, index, frame_len=64):
    out_df = pd.DataFrame()
    for var in var_list:
        output = create_radius_vars(df[var].values, index, frame_len)
        out_df[var+'_avg_sin'] = output[0]
        out_df[var+'_min_sin'] = output[1]
        out_df[var+'_max_sin'] = output[2]
        out_df[var+'_avg_cos'] = output[3]
        out_df[var+'_min_cos'] = output[4]
        out_df[var+'_max_cos'] = output[5]
        out_df[var+'_avg_tan'] = output[6]
        out_df[var+'_min_tan'] = output[7]
        out_df[var+'_max_tan'] = output[8]  
    return out_df
        
 
def feature_trans(csv_file, var_list, var_list_ang, out_csv,frame_len = 64 ):       
    df = read_csv(csv_file)    
    index, timestamp, n_frames = enframe(df, frame_len=frame_len)    
    out_df1 = create_short_time_features(df, var_list, index, frame_len)
    out_df2 = create_short_time_radius_features(df, var_list_ang, index, frame_len)
    out_df = pd.concat([out_df1, out_df2], axis=1)
    out_df['wman_tm'] = timestamp
    out_df['wtur_flt_main'] =  np.array([np.max(x) for x in df['wtur_flt_main'].values[index]])
    out_df.to_csv(out_csv)

def feature_trans2(csv_file, var_list, var_list_ang,frame_len = 64 ):       
    df = read_csv(csv_file)    
    index, timestamp, n_frames = enframe(df, frame_len=frame_len)    
    out_df1 = create_short_time_features(df, var_list, index, frame_len)
    out_df2 = create_short_time_radius_features(df, var_list_ang, index, frame_len)
    out_df = pd.concat([out_df1, out_df2], axis=1)
    out_df['wman_tm'] = timestamp
    out_df['wtur_flt_main'] =  np.array([np.max(x) for x in df['wtur_flt_main'].values[index]])
    del df
    del out_df1
    del out_df2
    del index    
    return out_df


    
if __name__ == '__main__':
    csv_file = "c:/Temp/ts_gw150044_14_11_22_30.csv"
    var_list = ['wnac_wspd_instmag_f','wgen_spd_instmag_i', 'wrot_rotspd_instmag_1_i', 'wyaw_pos', 'wtur_yaw_speed']
    var_list_ang = ['wnac_wdir_instmag_f', 'wrot_ptangval_bl1']
    feature_trans(csv_file, var_list, var_list_ang, "c:/temp/ts_gw150044_14_11_22_30_trans3.csv")
#pd.concat([a, c], axis=1    
    
    
