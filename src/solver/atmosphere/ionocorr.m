function [dIons, rhos_corr, drhos_corr, ps_corr, vs_corr, dts_corr, cnrs_corr, uobs] = ...
    ionocorr(ps, vs, dts, rhos, drhos, cnrs, obs, uobs, upvt, opt, eph_dict)
% Calculate ionospheric delay
% args  :   3xM double  ps      [m], satellite ECEF position [x, y, z]
%           3XM double  vs      [m/s], satellite ECEF velocity [x, y, z]
%           1xM double  dts     [s], satellite clock fix
%           1xM double  rhos    [m], satellite pseodoranges
%           1xM double  drhos   [], satellite pseodorange rates
%           1xM double  cnrs    [dB·Hz], satellite Carrier-Noise-Ratios
%           4x1 double  alpha   ionospheric parameters in broadcast ephemeris
%           4x1 double  beta    ionospheric parameters in broadcast ephemeris
%           1x2M struct obs     satellites dual frequency observation
%           1xM struct  uobs    satellites observation used in PVT calculation
%           1x1 struct  upvt    previous receiver PVT observation
%               char    opt     Ionospheric correction model,
%                               'N' for None;'K' for Klobuchar model;
%                               'IF' for dual frequency model;
%           dictionary  eph_dict ephemeris data struct

% return:   1xM double  dIons       [s], ionospheric delay
%           1xM double  rhos_corr   [m], satellite pseodoranges
%           1xM double  drhos_corr  [], satellite pseodorange rates
%           3xM double  ps_corr     [m], satellite ECEF position [x, y, z]
%           3XM double  vs_corr     [m/s], satellite ECEF velocity [x, y, z]
%           1xM double  dts_corr    [s], satellite clock fix%           
%           1xM double  cnrs_corr   [dB·Hz], satellite Carrier-Noise-Ratios
%           1xM struct  uobs_out    satellites observation used in PVT calculation
    
    c = 2.99792458e8;
    obs_indice = 1:length(uobs);
    M = length(uobs);
    dIons = zeros(1, M);
    rhos_corr = zeros(1, M);
    
    switch opt
        case 'K'
            upvt_LLA0 = upvt.PosLLA;
            [rhos_corr, dIons] = Klobuchar(rhos, uobs, upvt_LLA0, [uobs.Az], [uobs.El], eph_dict);
        case 'IF'
            [rhos_corr, dIons, obs_indice] = dualfreq(obs, uobs, eph_dict);
        case 'N'
            for k = 1:M
                key = sprintf("%c%02d", uobs(k).Sys, uobs(k).PRN);
                if(eph_dict.isKey(key) && ~isempty(eph_dict(key).TGD))
                    TGD = eph_dict(key).TGD;
                    rhos_corr(k) = rhos(k) - c*TGD(1);
                else
                    rhos_corr(k) = rhos(k);
                end
            end
        otherwise
            for k = 1:M
                key = sprintf("%c%02d", uobs(k).Sys, uobs(k).PRN);
                if(eph_dict.isKey(key) && ~isempty(eph_dict(key).TGD))
                    TGD = eph_dict(key).TGD;
                    rhos_corr(k) = rhos(k) - c*TGD(1);
                else
                    rhos_corr(k) = rhos(k);
                end
            end

    end
    drhos_corr = drhos(obs_indice>0);
    ps_corr = ps(:, obs_indice>0);
    vs_corr = vs(:, obs_indice>0);
    dts_corr = dts(obs_indice>0);
    cnrs_corr = cnrs(obs_indice>0); 
    uobs = uobs(obs_indice>0);
end