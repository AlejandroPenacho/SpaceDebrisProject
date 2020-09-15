function [Control] = parse_control_options(filename)

    TriggerStruct = struct("nConditions", 0, "Condition", "");
    ValueStruct = struct("type", 0);

    Control(1:50) = struct("name","", "Trigger", TriggerStruct, "controlVariable", "", "Value", ValueStruct);
    nOrders = 0;
    orderStep = 0;

    fID = fopen(filename);
    
    while ~feof(fID)
        
        currentLine = fgetl(fID);
        
        
        if orderStep == 0
            [orderName, fullMatch] = regexp(currentLine, "^Name:[\t\s]*([A-Za-z]+)$", 'tokens','match');
            
            if ~isempty(fullMatch)
                nOrders = nOrders + 1;
                orderStep = 1;

                Control(nOrders).name = orderName;    
            end
        end
        
        if orderStep == 1
            [conditionString, fullMatch] = regexp(currentLine, "^Trigger condition:[\t\s]*(.+)$", 'tokens','match');
            
            if ~isempty(fullMatch)
                orderStep = 2;
                Control(nOrders).Trigger = parse_condition_string(conditionString);        
            end
        end

        if orderStep == 2
            [variableString, fullMatch] = regexp(currentLine, "^Control variable:[\t\s]*(.+)$", 'tokens','match');
            
            if ~isempty(fullMatch)
                orderStep = 3;
                Control(nOrders).controlVariable = variableString;        
            end
        end

        if orderStep == 3
            [valueString, fullMatch] = regexp(currentLine, "^Value:[\t\s]*(.+)$", 'tokens','match');
            
            if ~isempty(fullMatch)
                orderStep = 0;
                Control(nOrders).Trigger.Value.type = valueString;        
            end
        end
        
    end

    Control = Control(1:nOrders);
    
end

