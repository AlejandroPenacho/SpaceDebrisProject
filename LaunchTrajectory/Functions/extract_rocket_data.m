function [RocketData] = extract_rocket_data(rocketFilename)
    % The information regarding a given rocket is extracted from the file
    % names "rocketFilename". A template of the format of this file can be
    % found in Files/TestFiles/rocketExample.txt
    %
    % INPUT:
    %   - "rocketFilename" : name of the file with the information of the
    %                        rocket
    % OUTPUT:
    %   - "RocketData"  : structure containing all the information of the
    %                     rocket. It includes initial mass, number of
    %                     stages and, for each stage, its initial mass,
    %                     maximum thrust, specific impulse, payload and
    %                     structural ratios, cross sectional surface and
    %                     coefficient of drag

    % First, the file containing the information is opened
    fID = fopen(rocketFilename);

    % The output structure is initialized
    RocketData = struct("initialMass", 0, "nStages", 0);

    % The lines that contain text are skipped with fgetl, since they are
    % only used for making the text file more readable. Same occurs with
    % empty lines. The initial mass and the number of stages are obtained
    % here.

    fgetl(fID);
    RocketData.initialMass = str2double(fgetl(fID));
    fgetl(fID);
    fgetl(fID);
    RocketData.nStages = str2double(fgetl(fID));
    fgetl(fID);
    fgetl(fID);
    fgetl(fID);
    

    %The information regarding each stage is stored in a line of a table. A
    %loop has been created so the information for each stage is obtained.

    for iStage = 1: RocketData.nStages

        % The structure of the stage is initialized
        StageData = struct( "initialMass",          0, ...
                            "maxThrust",            0, ...
                            "Isp",                  0, ...
                            "payloadRatio",         0, ...
                            "structuralRatio",      0, ...
                            "surface",              0, ...
                            "C_D", struct(  "type",     "", ...
                                            "mach",     0, ... 
                                            "value",    0));

        % The first number is the stage. Only used for making the file more
        % readable, skipped in the function.

        fscanf(fID, "%d", 1);

        % The following numbers in the line correspond to several
        % parameters of the stage. They are read and stored using fscanf

        StageData.maxThrust = fscanf(fID, "%f", 1);
        StageData.Isp = fscanf(fID, "%f", 1);
        StageData.payloadRatio = fscanf(fID, "%f", 1);
        StageData.structuralRatio = fscanf(fID, "%f", 1);
        StageData.surface = fscanf(fID, "%f", 1);
        dragValue = fscanf(fID, "%f", 1);
        
        if isempty(dragValue)
            dragFile = fscanf(fID, "%s", 1);
            StageData.C_D.type = "table";
            StageData.C_D.mach = readmatrix(dragFile, 'Range','A3:A58');
            StageData.C_D.value = readmatrix(dragFile, 'Range','B3:B58');
        else
            StageData.C_D.type = "constant";
            StageData.C_D.mach = 0;
            StageData.C_D.value = dragValue;
        end

        % The initial mass is not included in the file, since it is
        % redundant. Instead, it is calculated from the inital mass for the
        % first stage, and from the mass and payload ratio of the previous
        % stage.

        if iStage == 1
            StageData.initialMass = RocketData.initialMass;
        else
            StageData.initialMass = RocketData.Stage(iStage-1).initialMass * ...
                                    RocketData.Stage(iStage-1).payloadRatio;
        end

        % The data of the stage is added to the ouput structure, and the
        % loop continues with the next stage

        RocketData.Stage(iStage) = StageData;
    end
    
    fclose(fID);
end

