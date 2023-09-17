%{
classdef Vehicle
    properties
        ID
        X
        Y
        Lane
        Type
    end
    
    methods
        function obj = Vehicle(id, x, y, lane, type)
            obj.ID = id;
            obj.X = x;
            obj.Y = y;
            obj.Lane = lane;
            obj.Type = type;
        end
    end
end
%}
