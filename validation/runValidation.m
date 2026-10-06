function runValidation(Trajectory, Data, C)
%RUNVALIDATION Run validation tests for the orbital dynamics model.
%
% Each physical perturbation is validated using an isolated
% propagation containing only the required perturbation.
%
% Full dynamics validation uses the original simulation trajectory.

fprintf('\n');
fprintf('=====================================================\n');
fprintf('                 MODEL VALIDATION\n');
fprintf('=====================================================\n');

%% Initialize results

results = struct();

%% J2 validation

if Data.Model.J2

    DataJ2 = Data;

    DataJ2.Model.J2   = true;
    DataJ2.Model.drag = false;
    DataJ2.Model.SRP  = false;
    DataJ2.Model.sun  = false;
    DataJ2.Model.moon = false;

    TrajectoryJ2 = propagateOrbit(DataJ2, C);

    results.J2 = ...
        validateJ2(TrajectoryJ2, DataJ2, C);

end

%% Atmospheric drag validation

if Data.Model.drag

    DataDrag = Data;

    DataDrag.Model.J2   = false;
    DataDrag.Model.drag = true;
    DataDrag.Model.SRP  = false;
    DataDrag.Model.sun  = false;
    DataDrag.Model.moon = false;

    TrajectoryDrag = propagateOrbit(DataDrag, C);

    results.Drag = ...
        validateDrag(TrajectoryDrag, DataDrag, C);

end

%% Solar radiation pressure validation

if Data.Model.SRP

    DataSRP = Data;

    DataSRP.Model.J2   = false;
    DataSRP.Model.drag = false;
    DataSRP.Model.SRP  = true;
    DataSRP.Model.sun  = false;
    DataSRP.Model.moon = false;

    TrajectorySRP = propagateOrbit(DataSRP, C);

    results.SRP = ...
        validateSRP(TrajectorySRP, DataSRP, C);

    results.SRPShadow = ...
        validateSRPShadow(TrajectorySRP, DataSRP, C);

end

%% Sun gravity validation

if Data.Model.sun

    DataSun = Data;

    DataSun.Model.J2   = false;
    DataSun.Model.drag = false;
    DataSun.Model.SRP  = false;
    DataSun.Model.sun  = true;
    DataSun.Model.moon = false;

    TrajectorySun = propagateOrbit(DataSun, C);

    results.SunGravity = ...
        validateSunGravity(TrajectorySun, DataSun, C);

end

%% Moon gravity validation

if Data.Model.moon

    DataMoon = Data;

    DataMoon.Model.J2   = false;
    DataMoon.Model.drag = false;
    DataMoon.Model.SRP  = false;
    DataMoon.Model.sun  = false;
    DataMoon.Model.moon = true;

    TrajectoryMoon = propagateOrbit(DataMoon, C);

    results.MoonGravity = ...
        validateMoonGravity(TrajectoryMoon, DataMoon, C);

end

%% Full dynamics validation

results.FullDynamics = ...
    validateFullDynamics(Trajectory, Data, C);

%% Final summary

fprintf('\n');
fprintf('=====================================================\n');
fprintf('              VALIDATION SUMMARY\n');
fprintf('=====================================================\n');

fields = fieldnames(results);

allPassed = true;

for k = 1:length(fields)

    name = fields{k};
    passed = results.(name);

    if passed

        fprintf('%-20s PASS\n', name);

    else

        fprintf('%-20s FAIL\n', name);

        allPassed = false;

    end

end

fprintf('-----------------------------------------------------\n');

if allPassed

    fprintf('ALL TESTS PASSED\n');

else

    fprintf('SOME TESTS FAILED\n');

end

fprintf('=====================================================\n');

end