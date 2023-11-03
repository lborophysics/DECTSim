classdef coordinates
    properties
        x double
        y double
        z double
    end
    
    methods
        function obj =  coordinates(x, y, z)
            if nargin == 0
                obj.x = 0; obj.y = 0; obj.z = 0; 
            elseif nargin == 1
                obj.x = x; obj.y = x; obj.z = x;
            else 
                obj.x = x; obj.y = y; obj.z = z;
            end
        end
        
        function res = eq(lhs, rhs)
            if isa(lhs, 'coordinates') 
                if isa(rhs, 'double')
                    res = lhs.x == rhs && lhs.y == rhs && lhs.z == rhs;
                elseif isa(rhs, 'coordinates')
                    res = lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z;
                else
                    error('coordinates:incorrectType', 'Cannot compare %s to type %s', class(lhs), class(rhs));
                end
            else
                res = rhs == lhs;
            end
        end
        
        function res = ne(lhs, rhs)
            % Does this function need to be fast? If not, we use above function
            res = ~(lhs == rhs);
        end

        function res = elementwise_op(op, lhs, rhs, anti_op)
            if isa(lhs, "coordinates")
                if isa(rhs, "coordinates")
                    res = coordinates(op(lhs.x, rhs.x), op(lhs.y, rhs.y), op(lhs.z, rhs.z));
                elseif isa(rhs, "double")
                    res = coordinates(op(lhs.x, rhs), op(lhs.y, rhs), op(lhs.z, rhs));
                else
                    error('coordinates:incorrectType', 'Cannot perform opertation %s on %s to type %s', func2str(op), class(lhs), class(rhs));
                end
            else
                res = anti_op(rhs, lhs); % If op is not commutative, we use the anti_op
            end
        end

        function res = plus(lhs, rhs)
            res = elementwise_op(@plus, lhs, rhs, @plus);
        end

        function res = uminus(obj)
            res = coordinates(-obj.x, -obj.y, -obj.z);
        end

        function res = minus(lhs, rhs)
            res = lhs + (-rhs);
        end
        
        function res = times(lhs, rhs)
            res = elementwise_op(@times, lhs, rhs, @times);
        end

        function res = rdivide(lhs, rhs)
            if isa(lhs, 'coordinates') && isa(rhs, 'coordinates') % Most common case, so we check it first for speed
                res = coordinates(lhs.x / rhs.x, lhs.y / rhs.y, lhs.z / rhs.z); 
            elseif isa(lhs, 'double') % rhs must be a coordinates
                res = coordinates(lhs / rhs.x, lhs / rhs.y, lhs / rhs.z); % Compute the inverse of rhs
            elseif isa(lhs, 'coordinates') % Should work for any inversable rhs 
                res = lhs .* (1./rhs);
            else
                error('coordinates:incorrectType', 'Cannot divide %s to type %s', class(lhs), class(rhs));
            end
        end      

        function res = floor(obj)
            res = coordinates(floor(obj.x), floor(obj.y), floor(obj.z));
        end

        function res = ceil(obj)
            res = coordinates(ceil(obj.x), ceil(obj.y), ceil(obj.z));
        end

        function distance = distance_to(obj, other)
            dx = obj.x - other.x;
            dy = obj.y - other.y;
            dz = obj.z - other.z;
            distance = sqrt(dx^2 + dy^2 + dz^2);
        end

        function res = dot(lhs, rhs)
            res = lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
        end

        function res = norm(obj)
            res = sqrt(obj.x^2 + obj.y^2 + obj.z^2);
        end

        function res = unit(obj)
            res = obj ./ norm(obj);
        end

        function res = zrot(obj, angle)
            res = coordinates(obj.x * cos(angle) - obj.y * sin(angle), obj.x * sin(angle) + obj.y * cos(angle), obj.z);
        end
    end
end
