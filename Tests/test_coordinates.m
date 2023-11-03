

% Test case for coordinates.m tc -> test case
classdef test_coordinates < matlab.unittest.TestCase
    properties
        epsilon = 1e-16;
    end
    methods (Test)
        function test_initialization(tc)
            % Test initialization
            coords = coordinates(4, 2, 3);
            tc.verifyEqual(coords.x, 4)
            tc.verifyEqual(coords.y, 2)
            tc.verifyEqual(coords.z, 3)

            coords2 = coordinates(1.3, 2.4, 3.5);
            tc.verifyEqual(coords2.x, 1.3)
            tc.verifyEqual(coords2.y, 2.4)
            tc.verifyEqual(coords2.z, 3.5)
        end

        function test_equal(tc)
            % Test equal
            coords = coordinates(4, 2, 3);
            coords2 = coordinates(4, 2, 3);
            tc.verifyEqual(coords, coords2)
            tc.verifyTrue(coords == coords2)
            tc.verifyFalse(coords ~= coords2)

            coords3 = coordinates(1.3, 2.4, 3.5);
            tc.verifyNotEqual(coords, coords3)
            tc.verifyTrue(coords ~= coords3)
            tc.verifyFalse(coords == coords3)
            tc.verifyFalse(coords == 2.4)

            coords4 = coordinates(3, 3, 3);
            tc.verifyTrue(coords4 == 3)
            tc.verifyTrue(3 == coords4)
            tc.verifyFalse(coords4 ~= 3)
            tc.verifyFalse(3 ~= coords4)

            coords5 = coordinates(0.12, 0.12, 0.12);
            tc.verifyTrue(coords5 == 0.12)
            tc.verifyTrue(0.12 == coords5)
            tc.verifyFalse(coords5 ~= 0.12)
            tc.verifyFalse(0.12 ~= coords5)

            throw_error = @() coords == "a";
            tc.verifyError(throw_error, 'coordinates:incorrectType')

            throw_error = @() coords ~= "a";
            tc.verifyError(throw_error, 'coordinates:incorrectType')
        end

        function test_addition(tc)
            % Test addition
            coords = coordinates(4, 2, 3);
            coords2 = coordinates(1.3, 2.4, 3.5);
            coords3 = coords + coords2;
            tc.verifyEqual(coords3, coordinates(5.3, 4.4, 6.5))

            coords4 = coords + 3.2;
            tc.verifyEqual(coords4, coordinates(7.2, 5.2, 6.2))
            
            coords5 = 3.4 + coords;
            tc.verifyEqual(coords5, coordinates(7.4, 5.4, 6.4))

            throw_error = @() coords + "a";
            tc.verifyError(throw_error, 'coordinates:incorrectType')
        end

        function test_unary_minus(tc)
            % Test unary minus
            coords = coordinates(4, 2, 3);
            coords2 = -coords;
            tc.verifyEqual(coords2, coordinates(-4, -2, -3))
            
            coords3 = -coordinates(1.3, 2.4, 3.5);
            tc.verifyEqual(coords3, coordinates(-1.3, -2.4, -3.5))

        end

        function test_subtraction(tc)
            % Test subtraction
            coords = coordinates(4, 2, 3);
            coords2 = coordinates(1.3, 2.4, 3.5);
            coords3 = coords - coords2;
            tc.verifyEqual(coords3.x,  2.7, 'AbsTol', 2*tc.epsilon)
            tc.verifyEqual(coords3.y, -0.4, 'AbsTol', 2*tc.epsilon)
            tc.verifyEqual(coords3.z, -0.5, 'AbsTol', 2*tc.epsilon)

            coords4 = coords - 3.2;
            tc.verifyEqual(coords4.x,  0.8, 'AbsTol', 3*tc.epsilon)
            tc.verifyEqual(coords4.y, -1.2, 'AbsTol', 3*tc.epsilon)
            tc.verifyEqual(coords4.z, -0.2, 'AbsTol', 2*tc.epsilon)

            coords5 = 3.4 - coords;
            tc.verifyEqual(coords5.x, -0.6, 'AbsTol', 2*tc.epsilon)
            tc.verifyEqual(coords5.y,  1.4, 'AbsTol', 2*tc.epsilon)
            tc.verifyEqual(coords5.z,  0.4, 'AbsTol', 2*tc.epsilon)

            throw_error = @() "a" - coords;
            tc.verifyError(throw_error, 'coordinates:incorrectType')
        end

        function test_times(tc)
            % Test element-wise multiplication
            coords = coordinates(4, 2, 3);
            coords2 = coordinates(1.3, 2.4, 3.5);
            coords3 = coords .* coords2;
            tc.verifyEqual(coords3, coordinates(4*1.3, 2*2.4, 3*3.5))

            coords4 = coords .* 3.2;
            tc.verifyEqual(coords4, coordinates(4*3.2, 2*3.2, 3*3.2))

            coords5 = 3.4 .* coords;
            tc.verifyEqual(coords5, coordinates(4*3.4, 2*3.4, 3*3.4))

            throw_error = @() coords .* "a";
            tc.verifyError(throw_error, 'coordinates:incorrectType')
        end

        function test_rdivide(tc)
            % Test element-wise division
            coords = coordinates(4, 2, 3);
            coords2 = coordinates(1.3, 2.4, 3.5);
            coords3 = coords ./ coords2;
            tc.verifyEqual(coords3, coordinates(4/1.3, 2/2.4, 3/3.5))

            coords4 = coords ./ 3.2;
            tc.verifyEqual(coords4, coordinates(4/3.2, 2/3.2, 3/3.2))

            coords5 = 3.4 ./ coords;
            tc.verifyEqual(coords5, coordinates(3.4/4, 3.4/2, 3.4/3))

            throw_error = @() coords ./ "a";
            tc.verifyError(throw_error, 'MATLAB:UndefinedFunction')

            throw_error = @() "a" ./ coords;
            tc.verifyError(throw_error, 'coordinates:incorrectType')
        end

        function test_floor(tc)
            % Test floor
            coords = coordinates(4.3, 2.6, 3.9);
            coords2 = floor(coords);
            tc.verifyEqual(coords2, coordinates(4, 2, 3))
        end

        function test_ceil(tc)
            % Test ceil
            coords = coordinates(4.3, 2.6, 3.9);
            coords2 = ceil(coords);
            tc.verifyEqual(coords2, coordinates(5, 3, 4))
        end

        function test_distance_to(tc)
            % Test distance_to
            coords = coordinates(4, 2, 3);
            coords2 = coordinates(1.3, 2.4, 3.5);
            res = sqrt((4-1.3)^2 + (2-2.4)^2 + (3-3.5)^2);
            tc.verifyEqual(coords.distance_to(coords2), res)
            tc.verifyEqual(coords2.distance_to(coords), res)

            coords3 = coordinates(1.3, 2.4, 3.5);
            tc.verifyEqual(coords2.distance_to(coords3), 0)
        end

        function test_norm(tc)
            % Test norm
            coords = coordinates(4, 2, 3);
            tc.verifyEqual(norm(coords), sqrt(4^2 + 2^2 + 3^2))
        end

        function test_unit(tc)
            % Test unit
            coords = coordinates(4, 2, 3);
            tc.verifyEqual(coords.unit(), coordinates(4, 2, 3) ./ norm(coords))
        end
    end
end