# -*- coding: utf-8 -*-
import os
from feature import feature_trans
from feature import feature_trans2
import numpy as np
import pandas as pd
from sklearn import ensemble
from sklearn.metrics import mean_squared_error
from sklearn.externals import joblib

var_list_orig = ['wnac_wspd_instmag_f','wgen_spd_instmag_i', 'wrot_rotspd_instmag_1_i', 'wyaw_pos', 'wtur_yaw_speed']
var_list_ang_orig = ['wnac_wdir_instmag_f', 'wrot_ptangval_bl1']
target = 'wnac_wspd_instmag_f_avg'
var_list = [ 'wgen_spd_instmag_i_avg', 'wgen_spd_instmag_i_min', 'wgen_spd_instmag_i_max', 'wgen_spd_instmag_i_freq_0', 'wgen_spd_instmag_i_freq_1', 'wgen_spd_instmag_i_freq_2', 'wgen_spd_instmag_i_freq_3', 'wrot_rotspd_instmag_1_i_avg', 'wrot_rotspd_instmag_1_i_min', 'wrot_rotspd_instmag_1_i_max', 'wrot_rotspd_instmag_1_i_freq_0', 'wrot_rotspd_instmag_1_i_freq_1', 'wrot_rotspd_instmag_1_i_freq_2', 'wrot_rotspd_instmag_1_i_freq_3', 'wyaw_pos_avg', 'wyaw_pos_min', 'wyaw_pos_max', 'wyaw_pos_freq_0', 'wyaw_pos_freq_1', 'wyaw_pos_freq_2', 'wyaw_pos_freq_3', 'wtur_yaw_speed_avg', 'wtur_yaw_speed_min', 'wtur_yaw_speed_max', 'wtur_yaw_speed_freq_0', 'wtur_yaw_speed_freq_1', 'wtur_yaw_speed_freq_2', 'wtur_yaw_speed_freq_3', 'wnac_wdir_instmag_f_avg_sin', 'wnac_wdir_instmag_f_min_sin', 'wnac_wdir_instmag_f_max_sin', 'wnac_wdir_instmag_f_avg_cos', 'wnac_wdir_instmag_f_min_cos', 'wnac_wdir_instmag_f_max_cos', 'wnac_wdir_instmag_f_avg_tan', 'wnac_wdir_instmag_f_min_tan', 'wnac_wdir_instmag_f_max_tan', 'wrot_ptangval_bl1_avg_sin', 'wrot_ptangval_bl1_min_sin', 'wrot_ptangval_bl1_max_sin', 'wrot_ptangval_bl1_avg_cos', 'wrot_ptangval_bl1_min_cos', 'wrot_ptangval_bl1_max_cos', 'wrot_ptangval_bl1_avg_tan', 'wrot_ptangval_bl1_min_tan', 'wrot_ptangval_bl1_max_tan']
 

def train_model(csv_file):
    df = feature_trans2(csv_file, var_list_orig, var_list_ang_orig)    
    params = {'n_estimators': 500, 'max_depth': 6, 'min_samples_split': 1,
          'learning_rate': 0.01, 'loss': 'ls'}
    
    gbm = ensemble.GradientBoostingRegressor(**params)
    gbm.fit(df[var_list].values, df[target].values)
    return gbm

def test_model(model, csv_file):
     df = feature_trans2(csv_file, var_list_orig, var_list_ang_orig)    
     pred = model.predict(df[var_list])
     mse = mean_squared_error(df[target], pred)
     residual = df[target] - pred
     # FIXME which std to use, the training std?
     std = np.std(residual)
     anomaly_count = np.sum(np.abs(residual) > 2 * std)
     anomaly_rate = anomaly_count/df.shape[0]
     
     
     return (anomaly_count, df.shape[0], anomaly_rate)

def test_model2(model, csv_file):
    df = pd.read_csv(csv_file, skipinitialspace=True)
    pred = model.predict(df[var_list])
    mse = mean_squared_error(df[target], pred)
    residual = df[target] - pred
    std = np.std(residual)
    anomaly_count = np.sum(np.abs(residual) > 2 * std)
    anomaly_rate = anomaly_count/df.shape[0]
    timestamp = df.wman_tm[0]
    wtur_flt_main = max(df.wtur_flt_main)
    return (timestamp, anomaly_count, df.shape[0], anomaly_rate, mse, std, wtur_flt_main)

def test_models(gbm, indir):
    df = pd.DataFrame(columns = ["timestamp","anomaly_count", "count", "anomaly_rate", "mse", "std", "wtur_flt_main" ])
    i = 0
    for subdir, dirs, files in os.walk(indir):
        for file in files:
            if file.find(".csv") > 0:
                out = test_model2(gbm, subdir + '/' + file)
                df.loc[i] = out
                i = i + 1
    return df
                

    
if __name__ == '__main__':
    #train_file = "C:/Temp/ts_gw150044_normal_140901_1001.csv"
    #gbm = train_model(train_file)
    gbm = joblib.load("gbm.pkl")
    #out = test_model2(gbm, "/home/grid/data/wind/GW15002220141206_trans.csv")
    #df = pd.DataFrame(columns = ["timestamp","anomaly_count", "count", "anomaly_rate", "mse", "std", "wtur_flt_main" ])
    #df.loc[0] = out
    #print(df.timestamp[0])
    df = test_models(gbm, "/home/grid/data/wind/")
    df.to_csv("/home/grid/data/wind2/out.csv")

    
    
    
