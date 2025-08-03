%Parser inspired by this solution: https://leetcode.com/problems/valid-number/solutions/6946211/beats-100-finite-state-machine-fsm-o-n-time-clean-intuitive/
function [cellArray] = str2cell(stringInput, cellStack, complexStack, cellRow, cellCol, startPosition)
arguments
    stringInput{string, char}
    cellStack{complex} = [];
    complexStack{complex} = [];
    cellRow{int8} = 1;
    cellCol{int8} = 1;
    startPosition{int16} = 1;
end
    %type cast the string to a character array so that we can index into it
    %character by character
    if(isstring(stringInput))
        stringInput = char(stringInput);
    end

    %Preallocate a variable for the return variable
    cellArray = {};

    %Keep track of the current state that we are in while we traverse the
    %string input
    stringStateMachine = "Initial State";

    %initialize a variable to keep track of the previous comma index.
    previousCommaIndex = 0; %Set to a value that it could never be at first.

    for i = startPosition:size(stringInput, 2)
        %The string will probably start with a curly brace. Can have
        %multiple curly braces inside.
        if(stringInput(i) == '{')
            stringStateMachine = "Cell Array Start";
            cellStack = [cellStack i];
        
        %For a valid cell string, there will be enough ending curly braces
        %to match the number of starting curly braces. 
        elseif(stringInput(i) == '}')
            startIdx = cellStack(end) + 1;
            endIdx = i - 1;

            %Pop from cell stack
            cellStack = cellStack(1:end-1);
            
            stringStateMachine = "Cell Array End";
            

        %There should be an equal number of starting square brackets to
        %ending square brackets. 
        elseif(stringInput(i) == '[')
            stringStateMachine = "Complex Array Begin";
            complexStack = [complexStack i];

        elseif(stringInput(i) == ']')
            %The index stored on the stack is the index of the starting
            %'[' brace.
            startIdx = complexStack(end)+1;
            %The index of the ith position is a ']' brace. 
            endIdx = i-1;
            
            %pop from the stack
            complexStack = complexStack(1:end-1);

            cellArray = addToCellArray(stringInput, cellArray, startIdx, endIdx, cellRow, cellCol);
            
            %Reached the end of the current matrix if the stack is empty
            if(isempty(complexStack))
                stringStateMachine = "Complex Array End";
            end

        %There can be a comma inside a cell or complex array.
        %There can also be a comma inside a cell array but not inside a
        %complex array. 
        %There cannot be a comma inside a complex array but not inside a
        %cell array. 
        elseif(stringInput(i) == ',' || stringInput(i) == " ")
            if(stringStateMachine ~= "Complex Array Begin")
                %this is the case were a single element is added to the
                %cell array but it is not in a matrix (i.e. {1, ...}).

                %Increment the column only if the comma is not afer a space
                %and not within a matrix
                if(stringStateMachine ~= "Comma" && stringStateMachine ~= "Semicolon")
                    if(stringStateMachine == "Cell Array Start" || stringStateMachine == "Floating Number")
                        %Get the proper indices
                        startIdx = max(previousCommaIndex + 1, cellStack(end) + 1);
                        endIdx = i-1;
    
                        %Update the cell array
                        cellArray = addToCellArray(stringInput, cellArray, startIdx, endIdx, cellRow, cellCol);
                    end
                    
                    %Update these pointers
                    cellCol = cellCol + 1;
                    previousCommaIndex = i;
                end

                stringStateMachine = "Comma";
                
            end

        %This is similar to a comma but is a different character that is
        %valid.
        %elseif(stringInput(i) == ' ')
            %Refer to comma logic
        
        %This follows the same rules as the comma but creates a new row
        %rather than a new column
        elseif(stringInput(i) == ';')
            if(stringStateMachine ~= "Complex Array Begin")
                if(stringStateMachine == "Cell Array Start" || stringStateMachine == "Floating Number")
                    %Get the proper indices
                    startIdx = max(previousCommaIndex + 1, cellStack(end) + 1);
                    endIdx = i-1;

                    %Update the cell array
                    cellArray = addToCellArray(stringInput, cellArray, startIdx, endIdx, cellRow, cellCol);
                end

                %Increment if this is not preceded by a space
                if(stringStateMachine ~= "Comma")
                    stringStateMachine = "Semicolon";
                end
                cellRow = cellRow + 1;
                cellCol = 1;
                previousCommaIndex = i;
            end

        elseif(~isempty(str2num(stringInput(i))))
            if(stringStateMachine ~= "Complex Array Begin" &&  stringStateMachine ~= "Cell Array Begin")
                stringStateMachine = "Floating Number";
            end
        end

    end

    %This is an error checking condition. Throw an error if the string is
    %not valid. 
    if(~isempty(cellStack) || ~isempty(complexStack))
        ME = MException('string:inputError', "The string entered is not a valid cell array.");
        throw(ME);
    end
end

%% Helper functions
function [cellArray] = addToCellArray(stringInput, cellArray, startIdx, endIdx, cellRow, cellCol)
arguments
    stringInput{char}
    cellArray{cell}
    startIdx{int8}
    endIdx{int8}
    cellRow{int8}
    cellCol{int8}
end

    %Get the number to add to the cell array
    num2add = stringInput(startIdx:endIdx);
    num2add = str2num(num2add);

    %If the cell array is empty, create a cell array where the only
    %value in the cell array is the matrix
    if(isempty(cellArray))                
        cellArray = {num2add};

    %Else, place the matrix in the appropriate cell array location
    else
        cellArray{cellRow, cellCol} = num2add;
    end
end

