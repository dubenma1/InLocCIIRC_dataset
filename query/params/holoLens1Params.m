function [ params ] = holoLens1Params(params)

    params.query.dir = fullfile(params.dataset.dir, 'query-HoloLens1');
    params.input.dir = '/Volumes/GoogleDrive/Můj disk/ARTwin/personal/lucivpav/HoloLens sequences';
    params.measurement.path = fullfile(params.input.dir, 'measurement1.txt');
    params.input.recording.dir = fullfile(params.input.dir, 'HoloLensRecording__2020_04_23__09_53_01');
    params.input.query.dir = fullfile(params.input.recording.dir, 'pv');
    params.input.poses.path = fullfile(params.input.recording.dir, 'pv_locationData.csv');
    params.HoloLensPoses.dir = fullfile(params.query.dir, 'HoloLensPoses');
    params.HoloLensProjectedPointCloud.dir = fullfile(params.query.dir, 'HoloLensProjectedPointCloud');
    params.HoloLensTranslationDelay = 5; % in frames, w.r.t. reference poses
    params.HoloLensOrientationDelay = 4; % in frames, w.r.t. reference poses

    % NOTE: some reference poses are wrong due to Vicon error, blacklist them
    params.blacklistedQueryInd = [103:109, 162, 179:188, 191:193, 286:288];

    %params.camera.rotation.wrt.marker = [-6.0 6.0 -4.0]; % this is optimal for query 1
    %params.camera.rotation.wrt.marker = [-5.0 6.0 -5.0]; % this is optimal for query 2
    %params.camera.rotation.wrt.marker = [-8.0 6.0 -3.0]; % this is optimal for query 3
    %params.camera.rotation.wrt.marker = [-8.0 6.0 -4.0]; % this is optimal for query 4
    params.camera.rotation.wrt.marker = [-8.0 6.0 -4.0]; % this aims to be generic
    params.camera.originConstant = 0.023;
    params.camera.origin.relative.wrt.marker = [2; 10; -4];
    params.camera.origin.wrt.marker = params.camera.originConstant * params.camera.origin.relative.wrt.marker;
    params.camera.sensor.size = [756, 1344]; % height, width
    params.camera.fl = 1015; % in pixels
    params.HoloLensViconSyncConstant = 10.7 * 1000; % [ms]
    
    %% interesting queries and corresponding matches %%
    params.interestingQueries = ["00132321090555753820.jpg", ... % aka query 1 (1.jpg)
                                    "00132321090868821963.jpg", ... % aka query 2 (94.jpg)
                                    "00132321091341754646.jpg", ... % aka query 3 (237.jpg)
                                    "00132321091488297196.jpg", ... % aka query 4
                                    "00132321091068652686.jpg", ... % aka query 5
                                    "00132321091211864676.jpg"]; % aka query 6 (198.jpg)
                                    % TODO: 00132321091305119025.jpg
    % interestingPointsQuery{i} are 2D projections of points in interestingPointsPC{i}.
    % i is the i-th query in params.interestingQueries
    params.interestingPointsPC{1} = [-3.5444, 2.6774, -3.2116; ...
                                        -11.2066, 2.3874, 1.0484; ...
                                        -2.7544, 3.5366, 1.5284; ...
                                        -5.5544, 3.5336, -1.2016]';
    params.interestingPointsQuery{1} = [1046, 432; ...
                                        398, 502; ...
                                        228, 151; ...
                                        671, 330]';

    params.interestingPointsPC{2} = [-6.6944, 0.7574, -2.3250; ...
                                        -8.2644, 0.6513, -2.4816; ...
                                        -5.0944, 2.4974, -3.3415]';
    params.interestingPointsQuery{2} = [271, 286; ...
                                        166, 138; ...
                                        1105, 361]';

    params.interestingPointsPC{3} = [7.3956, 2.6947, -3.2416; ...
                                        3.8756, 3.5295, -0.9016; ...
                                        3.9756, 0.7663, 2.5484; ...
                                        4.4656, 2.9874, -0.6228]';
    params.interestingPointsQuery{3} = [981, 269; ...
                                        758, 35; ...
                                        1098, 663; ...
                                        838, 133]';

    params.interestingPointsPC{4} = [-3.5344, 2.6774, -3.2205; ...
                                        -11.2077, 2.3874, 1.0384; ...
                                        -7.0966, 0.6574, 1.0484; ...
                                        -5.8644, 3.5374, -2.6916]';
    params.interestingPointsQuery{4} = [1113, 198; ...
                                        406, 250; ...
                                        375, 428; ...
                                        892, 113]';

    params.interestingPointsPC{5} = [-8.2444, 1.1374, 8.2766; ...
                                        -10.6837, 3.5356, 5.2184; ...
                                        -7.2519, 1.1474, 4.9484; ...
                                        -7.0244, 0.9659, 6.5084]';
    params.interestingPointsQuery{5} = [152, 515; ...
                                        956, 42; ...
                                        661, 630; ...
                                        175, 646]';

    params.interestingPointsPC{6} = [0.8956, 3.5306, 6.4184; ...
                                        10.2356, 2.5374, -3.3136; ...
                                        0.8456, 0.0060, 3.2784; ...
                                        16.8462, 2.0574, 6.6484]';
    params.interestingPointsQuery{6} = [1194, 64; ...
                                        309, 60; ...
                                        75, 429; ...
                                        894, 475]';
end