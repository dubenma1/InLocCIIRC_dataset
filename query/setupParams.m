function [ params ] = setupParams

params = struct();

params.dataset.dir = '/Volumes/GoogleDrive/Můj disk/ARTwin/InLocCIIRC_dataset';
params.spaceName = 'B-315';
params.pointCloud.path = fullfile(params.dataset.dir, 'models', params.spaceName, 'cloud - rotated.ply');
params.projectPointCloudPy.path = '../functions/local/projectPointCloud/projectPointCloud.py';
params.query.dir = fullfile(params.dataset.dir, 'query');
params.projectedPointCloud.dir = fullfile(params.query.dir, 'projectedPointCloud');
params.poses.dir = fullfile(params.query.dir, 'poses');
params.queryDescriptions.path = fullfile(params.query.dir, 'descriptions.csv');
params.rawPoses.path = fullfile(params.query.dir, 'rawPoses.csv');
params.cutouts.dir = fullfile(params.dataset.dir, 'cutouts');
params.inMap.tDiffMax = 1.3;
params.inMap.rotDistMax = 10; % in degrees
params.renderClosestCutouts = true;
params.closest.cutout.dir = fullfile(params.query.dir, 'closestCutout');

end