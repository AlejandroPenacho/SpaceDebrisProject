function [TriggerStruct] = parse_condition_string(conditionString)

    
    
    [conditions, fullMatch] = regexp(conditionString{1}, "(^|AND|OR)\s?([A-Za-z0-9_\.\*]+) ([><=]) ([A-Za-z0-9_\.\*]+)", ...
                                                        'tokens','match');
                                
                                                    
    nConditions = length(conditions{1});
    TriggerStruct = struct("nConditions", nConditions);
    
    if nConditions == 1
        conditions{1}{1}{1} = 'AND';
    else
        conditions{1}{1}{1}  = conditions{1}{2}{1};
    end
    
    for iCondition = 1:nConditions
        Condition = struct();
        Condition.leftSide = conditions{1}{iCondition}{2};
        Condition.rightSide = conditions{1}{iCondition}{4};
        Condition.sideRelation = conditions{1}{iCondition}{3};
        Condition.logicalOperator = conditions{1}{iCondition}{1};
        TriggerStruct.Condition(iCondition) = Condition;
    end
    
end

