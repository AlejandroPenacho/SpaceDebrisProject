function [RocketData] = create_rocket(baseRocketFilename, payloadMass, deltaVarray, printOutput)
%UNTITLED Summary of this function goes here


    % Get the base information of the rocket

    g = 9.81;
    
    [BaseRocketData] = extract_rocket_data(baseRocketFilename);
    nStages = BaseRocketData.nStages;
    
    if nargin < 4
        printOutput = false;
        if nargin < 3
            deltaVarray = -1 * ones(nStages, 1);
        end
    end
    
    if length(deltaVarray) == 1
        deltaVarray = deltaVarray * ones(nStages,1);
    end
    
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

	RocketData = struct("intialMass", 0, ...
                        "propellantRatios", zeros(nStages,1), ...
                        "payloadMass", payloadMass, ...
                        "nStages", nStages);                                   
    
                    
    originalDeltaV = zeros(nStages, 1);
    originalStageMass = zeros(nStages, 1);
    updatedDeltaV = zeros(nStages, 1);
    totalPropellant = 0;
    originalTotalPropellant = 0;
    totalDeltaV = 0;
                    
    for i=1:nStages              
    	iStage = nStages - i +1;
        
        Isp = BaseRocketData.Stage(iStage).Isp;
        
        m_structural = BaseRocketData.Stage(iStage).structuralMass;
        m_propellant = BaseRocketData.Stage(iStage).maxPropellantMass;
        
        if iStage == nStages
            m_payload = payloadMass;
            originalStageMass(iStage) = m_structural + m_propellant + payloadMass;
        else
            m_payload = RocketData.Stage(iStage+1).initialMass;
            originalStageMass(iStage) = m_structural + m_propellant + ...
                                originalStageMass(iStage+1);
        end
        
        
        originalDeltaV(iStage) = Isp * g * log((originalStageMass(iStage))/...
                                        (originalStageMass(iStage)-m_propellant));
        
        % k is the propellant ratio of the current stage
        if deltaVarray(iStage) == -1
            k = 1;
        elseif deltaVarray(iStage) == -2
            k = ((m_structural+m_payload)/m_propellant) * ...
                 (exp( originalDeltaV(iStage)/(Isp*g) ) - 1);
        else
            k  = ((m_structural+m_payload)/m_propellant) * ...
                 (exp( deltaVarray(iStage)/(Isp*g) ) - 1);
        end
         
        totalPropellant = totalPropellant + m_propellant * k;
        originalTotalPropellant = originalTotalPropellant + m_propellant;
        
        StageData.maxThrust = BaseRocketData.Stage(iStage).maxThrust;
        StageData.Isp = Isp;
        StageData.payloadRatio = m_payload/(m_structural+m_payload+k*m_propellant);
        StageData.structuralRatio = m_structural/(m_structural+k*m_propellant);
        StageData.surface = BaseRocketData.Stage(iStage).surface;
        StageData.C_D = BaseRocketData.Stage(iStage).C_D;
                                        
        StageData.initialMass = m_payload + m_structural + k * m_propellant;
        
        RocketData.Stage(iStage) = StageData;
        RocketData.propellantRatios(iStage) = k;
        
        
        
                                    
        updatedDeltaV(iStage) = Isp * g * log((k*m_propellant+m_structural+m_payload)/...
                                        (m_structural+m_payload));   
                                    
        totalDeltaV = totalDeltaV + updatedDeltaV(iStage);
    end
    
    RocketData.initialMass = RocketData.Stage(1).initialMass;
    %% Print information
    
    if printOutput
        fprintf("\nPayload: %.2f kg\n\n", payloadMass)
        fprintf("Stage\t\tOriginal Delta V (m/s)\t\tPropellant ratio (%%)\t\tDelta V (m/s)\n\n")
        for iStage=1:nStages
            fprintf("%d\t\t%.2f\t\t\t---->\t%.3f\t\t\t---->\t%.2f\n\n", ...
                    iStage, originalDeltaV(iStage), RocketData.propellantRatios(iStage)*100, updatedDeltaV(iStage))
        end
        fprintf("\t\t________________________________________________________________________\n\n")
        fprintf("\t\t%.2f / %.2f kg (%.3f %%)", ...
                totalPropellant, originalTotalPropellant, totalPropellant/originalTotalPropellant*100);
        fprintf("\t\t\t\t%.2f\n\n", totalDeltaV);
    end
    
end


function [BaseRocketData] = extract_rocket_data(rocketFilename)
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
    BaseRocketData = struct("nStages", 0);

    % The lines that contain text are skipped with fgetl, since they are
    % only used for making the text file more readable. Same occurs with
    % empty lines. The initial mass and the number of stages are obtained
    % here.

    fgetl(fID);
    BaseRocketData.nStages = str2double(fgetl(fID));
    fgetl(fID);
    fgetl(fID);
    fgetl(fID);
    

    %The information regarding each stage is stored in a line of a table. A
    %loop has been created so the information for each stage is obtained.

    for iStage = 1: BaseRocketData.nStages

        % The first number is the stage. Only used for making the file more
        % readable, skipped in the function.

        fscanf(fID, "%d", 1);

        % The following numbers in the line correspond to several
        % parameters of the stage. They are read and stored using fscanf

        StageData.maxThrust = fscanf(fID, "%f", 1);
        StageData.Isp = fscanf(fID, "%f", 1);
        StageData.maxPropellantMass = fscanf(fID, "%f", 1);
        StageData.structuralMass = fscanf(fID, "%f", 1);
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



        % The data of the stage is added to the ouput structure, and the
        % loop continues with the next stage

        BaseRocketData.Stage(iStage) = StageData;
    end
    
    fclose(fID);
end
