addpath('../functions/InLocCIIRC_utils/rotationMatrix');
addpath('../functions/InLocCIIRC_utils/mkdirIfNonExistent');
addpath('../functions/InLocCIIRC_utils/P_to_str');
addpath('../functions/InLocCIIRC_utils/params');
addpath('../functions/InLocCIIRC_utils/R_to_numpy_array');
addpath('../functions/InLocCIIRC_utils/projectPointCloud');
addpath('../functions/InLocCIIRC_utils/projectMesh');
addpath('../functions/InLocCIIRC_utils/environment');
addpath('../functions/closest_value');
[ params ] = setupParams('holoLens1');

justEvaluateOnMatches = false; % TODO: this currently throws when used with holoLens1Params
useProjectMeshInsteadOfProjectPC = false;

if strcmp(params.mode, 's10eParams')
    queryTable = false;
    measurementTable = false;
    rawPosesTable = readtable(params.rawPoses.path);
else
    [measurementTable, queryTable, ~] = initiMeasurementAndQueryTables(params);
    rawPosesTable = false;
end

if justEvaluateOnMatches
    close all
    queryInd = 1:size(params.interestingQueries,2);
    %queryInd = [3];
    evaluateMatches(queryInd, params, queryTable, measurementTable, rawPosesTable);
    return;
end

rawPosesTable = readtable(params.rawPoses.path); % at this point we must work with the rawPoses.csv data

mkdirIfNonExistent(params.projectedPoses.dir);
mkdirIfNonExistent(params.poses.dir);

createDescriptionsFile = true;
if exist(params.queryDescriptions.path, 'file') == 2
    createDescriptionsFile = false;
    [~,name,ext] = fileparts(params.queryDescriptions.path);
    descriptionsFilename = [name, ext];
    prompt = sprintf('Overwrite %s file?\n', descriptionsFilename);
    answer = input(prompt, 's');
    if strcmp(answer, 'yes') || strcmp(answer, '1')
        createDescriptionsFile = true;
    end
end

if createDescriptionsFile
    descriptionsFile = fopen(params.queryDescriptions.path, 'w');
    fprintf(descriptionsFile, 'id space inMap\n');
end

cutoutDescriptions = buildCutoutDescriptions(params);

mkdirIfNonExistent(params.closest.cutout.dir);

for i=1:size(rawPosesTable,1)

    id = rawPosesTable{i, 'id'};
    x = rawPosesTable{i, 'x'};
    y = rawPosesTable{i, 'y'};
    z = rawPosesTable{i, 'z'};
    alpha = rawPosesTable{i, 'alpha'};
    beta = rawPosesTable{i, 'beta'};
    gamma = rawPosesTable{i, 'gamma'};
    space = rawPosesTable{i, 'space'}{1,1};
    
    rawPosition = [x; y; z];
    rawRotation = [alpha beta gamma]; % in radians

    [R, t] = rawPoseToPose(rawPosition, rawRotation, params);

    P = eye(4);
    P(1:3,1:3) = R;
    P(1:3,4) = R * -t;

    poseFile = fopen(fullfile(params.poses.dir, sprintf('%d.txt', id)), 'w');
    P_str = P_to_str(P);
    fprintf(poseFile, '%s', P_str);
    fclose(poseFile);

    if useProjectMeshInsteadOfProjectPC
        f = params.camera.fl;
        sensorSize = params.camera.sensor.size; % height, width
        sensorSize = [sensorSize(2), sensorSize(1)]; % width, height
        headless = ~strcmp(environment(), 'laptop');
        rFix = [180.0, 0.0, 0.0];
        Rfix = rotationMatrix(deg2rad(rFix), 'XYZ');
        actualR = inv(R)*Rfix;
        [projectedPose, ~, ~] = projectMesh(params.mesh.path, f, actualR, t, sensorSize, false, -1, params.input.projectMesh_py_path, headless);
    else
        pointSize = 8.0;
        f = params.camera.fl; % in pixels
        sensorSize = params.camera.sensor.size; % height, width
        outputSize = sensorSize;
        projectedPose = projectPointCloud(params.pointCloud.path, f, R, ...
                                            t, sensorSize, outputSize, pointSize, ...
                                            params.projectPointCloudPy.path);
    end

    imshow(projectedPose);
    queryFilename = sprintf('%d.jpg', id);
    outProjectedFilename = sprintf('%d-projected.jpg', id);
    outQueryFilename = sprintf('%d-query.jpg', id);

    outProjectedPath = fullfile(params.projectedPoses.dir, outProjectedFilename);
    imwrite(projectedPose, outProjectedPath);

    queryImg = imread(fullfile(params.dataset.query.dir, queryFilename));
    outQueryPath = fullfile(params.projectedPoses.dir, outQueryFilename);
    imwrite(queryImg, outQueryPath);
    
    [inMap, closestCutout] = isQueryInMap(P, params.spaceName, cutoutDescriptions, params);
    if params.renderClosestCutouts
        cutoutImg = imresize(closestCutout.img, [size(queryImg,1), size(queryImg,2)]);
        imshowpair(queryImg, cutoutImg, 'montage');
        caption = 'Left: query. Right: closest cutout';
        if inMap
            inMapDesc = 'InMap';
        else
            inMapDesc = 'OffMap';
        end
        tDiff = closestCutout.tDiff;
        rotDist = closestCutout.rotDist;
        title(sprintf('Query %d: %s. tDiff: %0.2f, rotDist: %0.2f. %s - %s, %s.', ...
            id, inMapDesc, tDiff, rotDist, caption, closestCutout.name, closestCutout.space), ...
            'Interpreter', 'none');
        closestCutoutPath = fullfile(params.closest.cutout.dir, queryFilename);
        saveas(gcf, closestCutoutPath);
    end
    
    if createDescriptionsFile
        fprintf(descriptionsFile, '%d %s %d\n', id, space, inMap);
    end
end

if createDescriptionsFile
    fclose(descriptionsFile);
end